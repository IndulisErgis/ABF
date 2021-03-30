
CREATE PROCEDURE [dbo].[trav_BrBankAcctRegReport_proc]

@TransDateFrom datetime ,
@TransDateThru datetime ,
@BaseCurrency pCurrency ,
@FiscalYear smallint,
@BrGlYn bit = 1 ,
@IncludeUnposted bit = 1,-- Obsolete
@IncludeClearedTransaction bit=0

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpBrBankRegRpt
	(
		BankID pBankId,
		TransType smallint,
		SourceID nvarchar (10),
		Descr pDescription,
		TransDate datetime,
		Reference nvarchar (15),
		Amount pDecimal,
		DrAmountFgn pDecimal,
		CrAmountFgn pDecimal,
		AmountFgn pDecimal,
		CurrencyId nvarchar (6),
		ClearedYn bit,
		VoidStop tinyint,
		SourceApp nvarchar (2),
		BankName nvarchar (40),
		GlAcct pGlAcct,
		GlAcctBal pDecimal,
		LastStmtBal pDecimal,
		PostYn bit,
		AcctType tinyint
	)

	CREATE TABLE #AcctBal
	(
		GLAcct pglAcct NOT NULL, 
		GLAcctBal pDecimal NOT NULL
	)

	-- PET 0257622 To consider time part as well
	SET @TransDateFrom =  DATEADD(DAY, DATEDIFF(DAY, 0, @TransDateFrom), 0) -- with start of the day time
	SET @TransDateThru = DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @TransDateThru)+1, 0)) -- with end of the day time


	IF @BrGlYn = 1
	BEGIN
			INSERT #AcctBal (GlAcct, GlAcctBal)
			SELECT bal.AcctId, SUM(bal.Balance) 
			FROM
				(SELECT h.AcctId, ISNULL(SUM(h.Actual), 0) AS Balance FROM dbo.tblGlAcctDtl h 
					WHERE h.[Year] = @FiscalYear GROUP BY h.AcctId	
									
				UNION ALL
				
				SELECT j.AcctId, SUM(CASE WHEN dh.BalType < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END) AS Balance
					FROM dbo.tblGlJrnl j INNER JOIN tblGlAcctHdr dh ON j.AcctId = dh.AcctId
					WHERE (j.PostedYn = 0) AND (j.[Year] = @FiscalYear)
					GROUP BY j.AcctId
				) AS bal			 
			 INNER JOIN ( SELECT b.GlCashAcct FROM #tmpBankAcctList t INNER JOIN dbo.tblSmBankAcct b ON t.BankId = b.BankId GROUP BY GlCashAcct) b ON bal.AcctId = b.GlCashAcct 			
			GROUP BY bal.AcctId		
	END		
	
	INSERT #tmpBrBankRegRpt (BankID, TransType, SourceID, Descr, TransDate, Reference, Amount, DrAmountFgn, CrAmountFgn, AmountFgn
			, CurrencyId, ClearedYn, VoidStop, SourceApp, BankName, GlAcct, GlAcctBal, LastStmtBal, PostYn, AcctType) 
	SELECT j.BankID, j.TransType, j.SourceID, j.Descr, j.TransDate, j.Reference, j.Amount 
		, CASE WHEN AmountFgn * TransType >= 0 THEN ABS(CASE WHEN j.CurrencyID = @BaseCurrency THEN Amount ELSE AmountFgn END) ELSE 0 END 
		, CASE WHEN AmountFgn * TransType < 0 THEN ABS(CASE WHEN j.CurrencyID = @BaseCurrency THEN Amount ELSE AmountFgn END) ELSE 0 END 
		, j.AmountFgn, j.CurrencyId, 0 AS ClearedYn, CASE WHEN (VoidYn > 0 AND (VoidReinstateStat IS NULL)) THEN 1 ELSE 0 END
		, 'BR', b.[Name], b.GlCashAcct, b.GlAcctBal, b.LastStmtBal, 0 ,b.AcctType
	FROM dbo.tblSmBankAcct b 
	INNER JOIN dbo.tblBrJrnlHeader j ON b.BankId = j.BankID 
	WHERE ((j.VoidYn <>0) AND (j.VoidReinstateStat IS NULL)) OR (j.VoidYn = 0 ) AND j.TransDate BETWEEN @TransDateFrom AND @TransDateThru

	--if @TransDateThru is >= voiddate or voiddate isnull, use amt
	INSERT #tmpBrBankRegRpt (BankID, TransType, SourceID, Descr, TransDate, Reference, Amount, DrAmountFgn, CrAmountFgn, AmountFgn, CurrencyId, 
			ClearedYn, VoidStop, SourceApp, BankName, GlAcct, GlAcctBal, LastStmtBal, PostYn,AcctType)
	SELECT m.BankID, m.TransType, m.SourceID, m.Descr, m.TransDate, m.Reference, m.Amount 
		, CASE WHEN AmountFgn >= 0 THEN ABS(CASE WHEN m.CurrencyID = @BaseCurrency THEN Amount ELSE AmountFgn END) ELSE 0 END 
		, CASE WHEN AmountFgn < 0 THEN ABS(CASE WHEN m.CurrencyID = @BaseCurrency THEN Amount ELSE AmountFgn END) ELSE 0 END 
		, m.AmountFgn, m.CurrencyId, m.ClearedYn, m.VoidStop, m.SourceApp, b.[Name] , b.GlCashAcct, b.GlAcctBal, b.LastStmtBal, 1 ,b.AcctType
	FROM dbo.tblSmBankAcct b (NOLOCK) 
	INNER JOIN dbo.tblBrMaster m (NOLOCK) ON b.BankId = m.BankID AND m.TransDate BETWEEN @TransDateFrom AND @TransDateThru
	WHERE  @TransDateThru >= m.VoidDate OR ISNULL(m.VoidDate, '') = ''

	--if @TransDateThru is < voiddate, use voidamt
	INSERT #tmpBrBankRegRpt (BankID, TransType, SourceID, Descr, TransDate, Reference, Amount, DrAmountFgn, CrAmountFgn, AmountFgn, CurrencyId, 
			ClearedYn, VoidStop, SourceApp, BankName, GlAcct, GlAcctBal, LastStmtBal, PostYn, AcctType)
	SELECT m.BankID, m.TransType, m.SourceID, m.Descr, m.TransDate, m.Reference, m.Amount
		, CASE WHEN m.VoidAmtFgn >= 0 THEN ABS(CASE WHEN m.CurrencyID = @BaseCurrency THEN m.VoidAmt ELSE m.VoidAmtFgn END) ELSE 0 END
		, CASE WHEN m.VoidAmtFgn < 0 THEN ABS(CASE WHEN m.CurrencyID = @BaseCurrency THEN 	m.VoidAmt ELSE m.VoidAmtFgn END) ELSE 0 END
		, m.AmountFgn, m.CurrencyId, m.ClearedYn, 0, m.SourceApp--set voidstop value to 0 when @transDateThru < VoidDate for reporting purposes.
		, b.[Name] , b.GlCashAcct, b.GlAcctBal, b.LastStmtBal, 1 ,b.AcctType
	FROM dbo.tblSmBankAcct b (NOLOCK) 
	INNER JOIN dbo.tblBrMaster m (NOLOCK) ON b.BankId = m.BankID AND m.TransDate BETWEEN @TransDateFrom AND @TransDateThru
	WHERE @TransDateThru < m.VoidDate

	INSERT #tmpBrBankRegRpt (BankID, TransType, SourceID, Descr, TransDate, Reference, Amount, DrAmountFgn, CrAmountFgn, AmountFgn, CurrencyId, 
			ClearedYn, VoidStop, SourceApp, BankName, GlAcct, GlAcctBal, LastStmtBal, PostYn, AcctType) 
	SELECT b.BankId, h.TransType, h.SourceID, j.Descr, h.TransDate, j.Reference, h.Amount, 
		CASE WHEN b.CurrencyID = @BaseCurrency THEN j.DebitAmt ELSE j.DebitAmtFgn END, 
		CASE WHEN b.CurrencyID = @BaseCurrency THEN j.CreditAmt ELSE j.CreditAmtFgn END, 
		h.AmountFgn, h.CurrencyId, 0 , 0 , 'BR', b.[Name], b.GlCashAcct, b.GlAcctBal, b.LastStmtBal, 0 ,b.AcctType
	FROM dbo.tblSmBankAcct b (NOLOCK) 
	INNER JOIN 
	(
		dbo.tblBrJrnlHeader h (NOLOCK) 
		INNER JOIN dbo.tblBrJrnlDetail j (NOLOCK) ON h.TransID = j.TransID
	) ON b.BankId = j.BankIDXferTo
	WHERE h.TransDate BETWEEN @TransDateFrom AND @TransDateThru

	SELECT r.BankID, TransType, SourceID, Descr, TransDate, Reference, Amount, DrAmountFgn, CrAmountFgn, AmountFgn,CurrencyId, 
            ClearedYn, VoidStop, SourceApp, BankName, r.GlAcct, r.GlAcctBal AS GlAcctBal, 
            LastStmtBal, PostYn, AcctType, ab.GLAcctBal AS ActGlAcctBal, CASE WHEN ClearedYn = 0 THEN (DrAmountFgn - CrAmountFgn) ELSE 0 END AS BalanceAdjustment 
    FROM #tmpBrBankRegRpt r 
    INNER JOIN #tmpBankAcctList t ON r.BankID = t.BankID
    LEFT JOIN #AcctBal AS ab  ON ab.GLAcct =r.GlAcct
    WHERE ClearedYn = 0 OR @IncludeClearedTransaction = 1


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrBankAcctRegReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrBankAcctRegReport_proc';

