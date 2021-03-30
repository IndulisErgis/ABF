
CREATE PROCEDURE dbo.trav_BrReconciliationReport_proc
@BankId pBankId = 'FNB001',
@IncludeOption tinyint = 0, --0, Transaction date range;1, Fiscal Period & Year;
@TransactionDateFrom datetime = '19000101',
@TransactionDateThru datetime = '29991231',
@FiscalPeriod smallint = 2,
@FiscalYear smallint = 2009,
@BrGlYn bit = 0,
@IncludeUnposted bit = 0,
@SelectOption tinyint = 2, --0, Cleared;1, Outstanding;2 All;
@BaYn bit = 1
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @GlAcct pGlAcct
	DECLARE @GlTotal pCurrDecimal
	DECLARE @GlTotalExclude pCurrDecimal
	DECLARE @CurrentYearPeriod int
	DECLARE @FiscalYearPeriod int
	DECLARE @AccountType tinyint

	-- return at least one record with totals for the summary page
	CREATE TABLE #Trans
	(	
		BankId pBankId NULL, 
		TransType smallint NULL, 
		SourceId nvarchar (10) NULL, 
		Descr pDescription NULL, 
		Reference nvarchar (15) NULL, 
		SourceApp nvarchar (2) NULL, 
		Amount pDecimal NULL, 
		AmountFgn pDecimal NULL, 
		TransDate datetime NULL, 
		ClearedYn bit NULL, 
		VoidTransId pTransId NULL, 
		CurrencyId pCurrency NULL, 
		VoidStop bit NULL
	)

	-- PET 0257622 To consider time part as well
	SET @TransactionDateFrom =  DATEADD(DAY, DATEDIFF(DAY, 0, @TransactionDateFrom), 0) -- with start of the day time
	SET @TransactionDateThru = DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @TransactionDateThru)+1, 0)) -- with end of the day time

	SET @FiscalYearPeriod = @FiscalYear * 1000 + @FiscalPeriod

	SET @GlTotal = 0
	IF @BrGlYn = 1
	BEGIN
		SELECT @GlAcct = GLCashAcct FROM dbo.tblSmBankAcct WHERE BankId = @BankId

		SELECT @GlTotal = ISNULL(SUM(h.Actual), 0) FROM dbo.tblGlAcctDtl h 
		WHERE h.[Year] = @FiscalYear AND h.Period <= @FiscalPeriod AND h.AcctId = @GlAcct

		-- get posted total of unrealized gain/loss
		SELECT @GlTotalExclude = COALESCE(SUM(CASE WHEN h.BalType < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END), 0) 
		FROM dbo.tblGlAcctHdr h INNER JOIN dbo.tblGlJrnl j ON h.AcctId = j.AcctId 
		WHERE h.AcctId = @GlAcct AND j.PostedYn = -1 AND j.SourceCode IN ('G1', 'G2') 
			AND j.[Year] = @FiscalYear AND j.period <= @FiscalPeriod

		SET @GlTotal = @GlTotal - @GlTotalExclude

		IF @IncludeUnposted <> 0
		BEGIN
			SELECT @GlTotal = @GlTotal + ISNULL(SUM(CASE WHEN h.BalType < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END), 0) 
			FROM dbo.tblGlAcctHdr h INNER JOIN dbo.tblGlJrnl j ON h.AcctId = j.AcctId 
			WHERE (h.AcctId = @GlAcct) AND (j.PostedYn = 0) 
				AND j.SourceCode NOT IN ('G1', 'G2') -- exclude unrealized gain/loss entries
				AND (j.[Year] = @FiscalYear) AND (j.period <= @FiscalPeriod)
		END

		IF @BaYn = 1
		BEGIN
			SELECT @AccountType = AcctType FROM dbo.tblSmBankAcct WHERE BankID = @BankId
			IF @AccountType = 1 -- credit card
			BEGIN
				SET @GlTotal = - @GlTotal
			END
		END
	END

	-- capture list of bank transactions
	-- if @TransactionDateThru is < VoidDate then use VoidAmt
	-- return at least one record with totals for the summary page
	INSERT INTO #Trans(BankId, TransType, SourceId, Descr, Reference
		, SourceApp, Amount, AmountFgn, TransDate, ClearedYn, VoidTransId, CurrencyId, VoidStop) 
	SELECT m.BankId, m.TransType, m.SourceID, m.Descr, m.Reference, m.SourceApp
		, CASE WHEN Amount >= 0 THEN (CASE WHEN (@IncludeOption = 0 AND @TransactionDateThru < m.Voiddate) OR (@IncludeOption = 1 AND @FiscalYearPeriod < m.VoidYear * 1000 + m.VoidPd) 
			THEN m.VoidAmt ELSE Amount END) ELSE 
			CASE WHEN Amount < 0 THEN (CASE WHEN (@IncludeOption = 0 AND @TransactionDateThru <  m.Voiddate) OR (@IncludeOption = 1 AND @FiscalYearPeriod  < m.VoidYear * 1000 + m.VoidPd) 
				THEN m.VoidAmt ELSE Amount END) END END AS Amount
		, CASE WHEN AmountFgn >= 0 THEN (CASE WHEN (@IncludeOption = 0 AND @TransactionDateThru <  m.Voiddate) OR (@IncludeOption = 1 AND @FiscalYearPeriod  < m.VoidYear * 1000 + m.VoidPd) 
			THEN m.VoidAmtFgn ELSE AmountFgn END) ELSE
			CASE WHEN AmountFgn < 0 THEN (CASE WHEN (@IncludeOption = 0 AND @TransactionDateThru < m.Voiddate) OR (@IncludeOption = 1 AND @FiscalYearPeriod < m.VoidYear * 1000 + m.VoidPd) 
				THEN m.VoidAmtFgn ELSE AmountFgn END) END END AS AmountFgn
		, m.TransDate
		, CASE WHEN (@IncludeOption = 0 AND @TransactionDateThru < m.Voiddate) OR (@IncludeOption = 1 AND @FiscalYearPeriod < m.VoidYear * 1000 + m.VoidPd) 
			THEN 0 ELSE m.ClearedYn END AS ClearedYn
		, m.VoidTransID, m.CurrencyId, m.VoidStop 
	FROM dbo.tblSmBankAcct b INNER JOIN dbo.tblBrMaster m ON b.BankId = m.BankID 
	WHERE b.BankId = @BankId AND m.ACHBatch IS NULL
		AND ((@IncludeOption = 0 AND m.TransDate BETWEEN @TransactionDateFrom AND @TransactionDateThru) 
				OR (@IncludeOption = 1 AND (m.FiscalYear * 1000 + m.GlPeriod) <= @FiscalYearPeriod))

	-- ACH Grouped
	INSERT INTO #Trans(BankId, TransType, SourceId, Descr, Reference, SourceApp, 
		Amount, AmountFgn, TransDate, ClearedYn, VoidTransId, CurrencyId, VoidStop) 
	SELECT @BankId, -1, 'ACH', 'Authorized Debit', 'AP Payment', 'AP'
		, SUM(CASE WHEN (@IncludeOption = 0 AND @TransactionDateThru < m.Voiddate) OR (@IncludeOption = 1 AND @FiscalYearPeriod < m.VoidYear * 1000 + m.VoidPd) 
			THEN m.VoidAmt ELSE Amount END) AS Amount
		, SUM(CASE WHEN (@IncludeOption = 0 AND @TransactionDateThru <  m.Voiddate) OR (@IncludeOption = 1 AND @FiscalYearPeriod  < m.VoidYear * 1000 + m.VoidPd) 
			THEN m.VoidAmtFgn ELSE AmountFgn END) AS AmountFgn
		, MAX(m.TransDate) AS TransDate
		,MIN( Convert(tinyint,m.ClearedYn )) ClearedYn
		, NULL, MIN(m.CurrencyId), NULL
	FROM dbo.tblSmBankAcct b INNER JOIN dbo.tblBrMaster m ON b.BankId = m.BankID 
	WHERE b.BankId = @BankId AND m.ACHBatch IS NOT NULL
		AND ((@IncludeOption = 0 AND m.TransDate BETWEEN @TransactionDateFrom AND @TransactionDateThru) 
				OR (@IncludeOption = 1 AND (m.FiscalYear * 1000 + m.GlPeriod) <= @FiscalYearPeriod))
	GROUP BY m.ACHBatch

	IF (SELECT COUNT(*) FROM #Trans WHERE @SelectOption = 2 OR (@SelectOption = 0 AND ClearedYn <> 0) OR (@SelectOption = 1 AND ClearedYn = 0)) > 0
	BEGIN
		-- return the detail recordset with totals
		SELECT b.BankId, CASE WHEN @BrGlYn = 0 THEN b.GlAcctBal ELSE @GlTotal END AS GlAcctBal
			, b.LastStmtBal, b.LastStmtDate, m.TransType, m.SourceID
			, m.Descr, m.Reference, m.SourceApp, m.AmountFgn, m.TransDate
			, m.ClearedYn
			, ISNULL(t.TotDisbursements, 0) AS TotDisbursements, ISNULL(t.TotDeposits, 0) AS TotDeposits
			, ISNULL(t.TotTransfers, 0) AS TotTransfers, ISNULL(t.TotAdjustments, 0) AS TotAdjustments 
		FROM dbo.tblSmBankAcct b INNER JOIN #Trans m ON b.BankId = m.BankID 
			LEFT JOIN (SELECT BankId
					, CAST(SUM(CASE WHEN TransType = -1 THEN AmountFgn ELSE 0 END) AS float) AS TotDisbursements
					, CAST(SUM(CASE WHEN TransType = 2 THEN AmountFgn ELSE 0 END) AS float) AS TotDeposits
					, CAST(SUM(CASE WHEN TransType = -3 THEN AmountFgn ELSE 0 END) AS float) AS TotTransfers
					, CAST(SUM(CASE WHEN TransType = 4 THEN AmountFgn ELSE 0 END) AS float) AS TotAdjustments 
				FROM #Trans WHERE BankId = @BankId AND ClearedYn = 0 
				GROUP BY BankId) t ON b.BankId = t.BankId 
		WHERE b.BankId = @BankId 
			AND (@SelectOption = 2 OR (@SelectOption = 0 AND m.ClearedYn <> 0) OR (@SelectOption = 1 AND m.ClearedYn = 0))
	END
	ELSE
	BEGIN
		-- return a blank record with totals
		SELECT b.BankId, CASE WHEN @BrGlYn = 0 THEN b.GlAcctBal ELSE @GlTotal END AS GlAcctBal
			, b.LastStmtBal, b.LastStmtDate, NULL AS TransType, NULL AS SourceID
			, NULL AS Descr, NULL AS Reference, NULL AS SourceApp, NULL AS AmountFgn, NULL AS TransDate
			, NULL AS ClearedYn
			, ISNULL(t.TotDisbursements, 0) TotDisbursements, ISNULL(t.TotDeposits, 0) TotDeposits
			, ISNULL(t.TotTransfers, 0) TotTransfers, ISNULL(t.TotAdjustments, 0) TotAdjustments
			FROM dbo.tblSmBankAcct b 
			LEFT JOIN (SELECT BankId
					, CAST(SUM(CASE WHEN TransType = -1 THEN AmountFgn ELSE 0 END) AS float) AS TotDisbursements
					, CAST(SUM(CASE WHEN TransType = 2 THEN AmountFgn ELSE 0 END) AS float) AS TotDeposits
					, CAST(SUM(CASE WHEN TransType = -3 THEN AmountFgn ELSE 0 END) AS float) AS TotTransfers
					, CAST(SUM(CASE WHEN TransType = 4 THEN AmountFgn ELSE 0 END) AS float) AS TotAdjustments
				FROM #Trans WHERE BankId = @BankId AND ClearedYn = 0 
				GROUP BY BankId) t ON b.BankId = t.BankId 
		WHERE b.BankId = @BankId
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrReconciliationReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrReconciliationReport_proc';

