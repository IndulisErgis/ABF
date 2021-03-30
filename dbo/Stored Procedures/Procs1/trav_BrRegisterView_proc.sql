
CREATE PROCEDURE [dbo].[trav_BrRegisterView_proc]
@BankAccountId pBankID, 
@DateFrom datetime, 
@DateThru datetime, 
@BrGlYn bit,
@FiscalYear smallint

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @GlAcctBalance pDecimal, @BeginningBalance pDecimal, @WrkstnDate datetime
	
	CREATE TABLE #tmpBrRegister
	(
		BankID pBankId, 
		TransType smallint, 
		SourceID nvarchar (10), 
		Descr pDescription, 
		TransDate datetime, 
		Reference nvarchar (15), 
		AmountFgn pDecimal, 
		CurrencyId nvarchar (6), 
		ClearedYn bit, 
		VoidStop tinyint, 
		GlPeriod smallint, 
		FiscalYear smallint, 
		SourceApp nvarchar (2), 
		BankName nvarchar (40), 
		PostYn bit
	)

	SET @DateFrom = DATEADD(DAY, DATEDIFF(DAY, 0, @DateFrom), 0) -- with start of the day time
	SET @DateThru = DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @DateThru) + 1, 0)) -- with end of the day time

	--get the current Bank Account Balance
	CREATE TABLE #AcctBal([BankAcctBalance] pCurrDecimal, [GlAcctBalance] pCurrDecimal)
	INSERT INTO #AcctBal EXEC dbo.trav_SmBankAcctBalance_proc @BankAccountId, @BrGlYn, null, @FiscalYear
	SELECT @GlAcctBalance = [GlAcctBalance] FROM #AcctBal

	-- journal transactions
	INSERT INTO #tmpBrRegister (BankID, TransType, SourceID, Descr, TransDate, Reference, AmountFgn
		, CurrencyId, ClearedYn, VoidStop, GlPeriod, FiscalYear, SourceApp, BankName, PostYn) 
	SELECT j.BankID, j.TransType, j.SourceID, j.Descr, j.TransDate, j.Reference
		, AmountFgn * SIGN(TransType) AS AmountFgn
		, j.CurrencyId, 0 AS ClearedYn
		, CASE WHEN (VoidYn > 0 AND (VoidReinstateStat IS NULL)) THEN 1 ELSE 0 END AS VoidStop
		, GlPeriod, FiscalYear, 'BR', b.[Name], 0 AS PostYn 
	FROM dbo.tblSmBankAcct b 
		INNER JOIN dbo.tblBrJrnlHeader j ON j.BankId = b.BankID 
	WHERE b.BankId = @BankAccountId AND (((j.VoidYn <> 0) AND (j.VoidReinstateStat IS NULL)) OR (j.VoidYn = 0))

	-- journal transfers
	INSERT INTO #tmpBrRegister (BankID, TransType, SourceID, Descr, TransDate, Reference, AmountFgn
		, CurrencyId, ClearedYn, VoidStop, GlPeriod, FiscalYear, SourceApp, BankName, PostYn) 
	SELECT b.BankId, h.TransType, h.SourceID, j.Descr, h.TransDate, j.Reference
		, h.AmountFgn, h.CurrencyId, 0 AS ClearedYn, 0 AS VoidStop
		, GlPeriod, FiscalYear, 'BR', b.[Name], 0 AS PostYn 
	FROM dbo.tblSmBankAcct b (NOLOCK) 
		INNER JOIN 
		(
			dbo.tblBrJrnlHeader h (NOLOCK) 
				INNER JOIN dbo.tblBrJrnlDetail j (NOLOCK) ON h.TransID = j.TransID
		) ON b.BankId = j.BankIDXferTo 
	WHERE b.BankId = @BankAccountId

	-- master records
	INSERT INTO #tmpBrRegister (BankID, TransType, SourceID, Descr, TransDate, Reference, AmountFgn
		, CurrencyId, ClearedYn, VoidStop, GlPeriod, FiscalYear, SourceApp, BankName, PostYn) 
	SELECT m.BankID, m.TransType, m.SourceID, m.Descr, m.TransDate, m.Reference
		, CASE WHEN VoidDate IS NULL THEN AmountFgn ELSE VoidAmtFgn END AS AmountFgn
		, m.CurrencyId, m.ClearedYn
		, CASE WHEN VoidDate IS NULL THEN m.VoidStop ELSE 0 END AS VoidStop
		, m.GlPeriod, m.FiscalYear
		, m.SourceApp, b.[Name], 1 
	FROM dbo.tblSmBankAcct b (NOLOCK) 
		INNER JOIN dbo.tblBrMaster m (NOLOCK) ON b.BankId = m.BankID 
	WHERE b.BankId = @BankAccountId

	-- master voids
	INSERT INTO #tmpBrRegister (BankID, TransType, SourceID, Descr, TransDate, Reference, AmountFgn
		, CurrencyId, ClearedYn, VoidStop, GlPeriod, FiscalYear, SourceApp, BankName, PostYn) 
	SELECT m.BankID, m.TransType, m.SourceID, m.Descr, m.VoidDate, m.Reference
		, -VoidAmtFgn AS AmountFgn
		, m.CurrencyId, m.ClearedYn, m.VoidStop, m.VoidPd, m.VoidYear
		, m.SourceApp, b.[Name], 1 
	FROM dbo.tblSmBankAcct b (NOLOCK) 
		INNER JOIN dbo.tblBrMaster m (NOLOCK) ON b.BankId = m.BankID 
	WHERE b.BankId = @BankAccountId AND VoidDate IS NOT NULL

	SELECT @BeginningBalance = b.LastStmtBal + m.EndingBal - BegBalAdjust 
	FROM
	(
		SELECT BankID, SUM(CASE WHEN ClearedYn = 0 THEN AmountFgn ELSE 0 END) AS EndingBal
			, SUM(CASE WHEN TransDate >= @DateFrom THEN AmountFgn ELSE 0 END) AS BegBalAdjust 
		FROM #tmpBrRegister 
		GROUP BY BankID
	) m 
		LEFT JOIN dbo.tblSmBankAcct b (NOLOCK) ON b.BankID = m.BankID

	-- header data
	SELECT CurrencyId AS BankCurrencyId, ISNULL(LastStmtBal, 0) AS LastStatementBalance, LastStmtDate AS LastStatementDate
		, GLAcctBal AS [BankAcctBalance], ISNULL(@GlAcctBalance, 0) AS GlBalance 
	FROM dbo.tblSmBankAcct WHERE BankId = @BankAccountId

	-- detail grid data
	SELECT BankID, Name AS BankName, NULL AS TransDate, 'BR' AS SourceID, 99 AS TransType, 'Beginning Balance' AS Descr, NULL AS Reference
		, 'BR' AS SourceApp, 0 AS Addition, 0 AS Deduction, ISNULL(@BeginningBalance, 0) AS AmountFgn, CAST(1 AS bit) AS ClearedYn, CAST(1 AS bit) AS PostYn
		, 0 AS VoidStop, NULL AS GlPeriod, NULL AS FiscalYear, CurrencyId 
	FROM dbo.tblSmBankAcct WHERE BankId = @BankAccountId
	UNION ALL
	SELECT r.BankID, r.BankName, TransDate, SourceID, TransType, Descr, Reference, SourceApp
		, CASE WHEN AmountFgn >= 0 THEN ABS(AmountFgn) ELSE 0 END AS Addition
		, CASE WHEN AmountFgn < 0 THEN ABS(AmountFgn) ELSE 0 END AS Deduction
		, AmountFgn
		, ClearedYn, PostYn
		, VoidStop, GlPeriod, FiscalYear, CurrencyId 
	FROM #tmpBrRegister r 
	WHERE TransDate BETWEEN @DateFrom AND @DateThru
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrRegisterView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrRegisterView_proc';

