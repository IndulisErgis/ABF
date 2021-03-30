
CREATE PROCEDURE dbo.trav_BrReconciliationReport2_proc
@BankAccountID pBankID, 
@TransactionDateRangeOrPeriodYear tinyint = 0, --Obsolete Transaction date range (0 = by date, 1 = by fiscal period & year)
@TransactionDateFrom datetime = '19000101', --Obsolete user transaction start date 
@TransactionDateThru datetime = '19000101', --Obsolete user transaction end date
@FiscalPeriod smallint =0, --Obsolete
@FiscalYear smallint = 2016, --Obsolete
@BrGlYn bit, 
@IncludeUnpostedGLJournalEntries bit = 1, -- Obsolete
@IncludeTransactions tinyint, -- 0 = Cleared, 1 = Outstanding, 2 = All
@BaYn bit, 
@SortBy tinyint, -- Sort By (0 = Payment/Deposit Number, 1 = Transaction Date)
@StatementDate datetime ='19000101'

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @GlAcct pGlAcct
	DECLARE @GlTotal pCurrDecimal
	DECLARE @AccountType tinyint
	DECLARE @StatementEndingDate datetime
	DECLARE @StatementEndBalance pDecimal
	DECLARE @ReconcileFiscalPeriod smallint, @ReconcileFiscalYear smallint, @ReconcilePdYear int

	-- return at least one record with totals for the summary page
	CREATE TABLE #Trans
	(
		BankId pBankID, 
		TransType smallint, 
		SourceId nvarchar (10) NULL, 
		Descr pDescription NULL, 
		Reference nvarchar (15) NULL, 
		SourceApp nvarchar (2) NULL, 
		AmountFgn pDecimal, 
		TransDate datetime, 
		ClearedYn bit
	)

	CREATE TABLE #Reconiliation
	(
		BankId pBankID, 
		TransType smallint, 
		AmountFgn pDecimal
	)

	SELECT @StatementEndingDate = EndDate
		, @StatementEndBalance = ISNULL(EndBalance, 0)
		, @ReconcileFiscalPeriod = FiscalPeriod, @ReconcileFiscalYear = FiscalYear
		, @ReconcilePdYear = (FiscalYear * 1000) + FiscalPeriod
	FROM dbo.tblBrStatement 
	WHERE BankID = @BankAccountID AND StatementDate = @StatementDate		

	IF @StatementEndingDate  = '99991231' SET @StatementEndingDate = @StatementEndingDate - 1
	SET @StatementEndingDate = DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @StatementEndingDate)+1, 0)) 

	--get the GL Balance as of the Statement Ending Date (for reconciliation)
	CREATE TABLE #AcctBal([BankAcctBalance] pCurrDecimal, [GlAcctBalance] pCurrDecimal)
	INSERT INTO #AcctBal EXEC dbo.trav_SmBankAcctBalance_proc @BankAccountId, @BrGlYn, @ReconcileFiscalPeriod, @ReconcileFiscalYear
	SELECT @GlTotal = [GlAcctBalance] FROM #AcctBal

	--Reconciliation to GL (evaluate outstanding balances)
	--capture outstanding transactions as of the statement Fiscal Period/Year
	---entries voided after cutoff are outstanding
	---entries cleared on a future statement are outstanding
	INSERT INTO #Reconiliation(BankId, TransType, AmountFgn)
	SELECT b.BankId
		, CASE WHEN m.ACHBatch IS NULL THEN m.TransType ELSE -1 END --fixed type for ACHBatch
		, CASE WHEN m.VoidDate IS NULL THEN m.AmountFgn ELSE m.VoidAmtFgn END
	FROM dbo.tblSmBankAcct b 
	INNER JOIN dbo.tblBrMaster m ON b.BankId = m.BankID 
	LEFT JOIN dbo.tblBrStatement s ON m.StatementID = s.ID
	WHERE b.BankId = @BankAccountID
		AND ((m.FiscalYear * 1000) + m.GlPeriod) <= @ReconcilePdYear
		AND (CASE WHEN @ReconcilePdYear < ((m.VoidYear * 1000) + m.VoidPd) OR s.BeginDate > @StatementEndingDate THEN 0 ELSE m.ClearedYn END) = 0


	--capture transactions cleared to the current statement
	--capture outstanding transactions as of the statement Fiscal Period/Year
	---entries voided after cutoff are outstanding
	---entries cleared on a future statement are outstanding
	-- Non-ACH Grouped
	INSERT INTO #Trans(BankId, TransType, SourceId, Descr
		, Reference, SourceApp, TransDate, AmountFgn, ClearedYn) 
	SELECT m.BankId, m.TransType, m.SourceID, m.Descr
		, m.Reference, m.SourceApp, m.TransDate
		, CASE WHEN @ReconcilePdYear < ((m.VoidYear * 1000) + m.VoidPd) THEN m.VoidAmtFgn ELSE m.AmountFgn END
		, CASE WHEN s.StatementDate = @StatementDate THEN 1 ELSE 0 END
	FROM dbo.tblSmBankAcct b 
	INNER JOIN dbo.tblBrMaster m ON b.BankId = m.BankID 
	LEFT JOIN dbo.tblBrStatement s ON m.StatementID = s.ID
	WHERE b.BankId = @BankAccountID 
		AND m.ACHBatch IS NULL
		AND ((s.StatementDate = @StatementDate) --cleared to current statement
			OR (((m.FiscalYear * 1000) + m.GlPeriod) <= @ReconcilePdYear --outstanding and within pd/year cutoff
				AND (CASE WHEN @ReconcilePdYear < ((m.VoidYear * 1000) + m.VoidPd) OR s.BeginDate > @StatementEndingDate THEN 0 ELSE m.ClearedYn END) = 0))

	-- ACH Grouped
	INSERT INTO #Trans(BankId, TransType, SourceId, Descr
		, Reference, SourceApp, TransDate, AmountFgn, ClearedYn) 
	SELECT m.BankId, -1, 'ACH', 'Authorized Debit'
		, 'AP Payment', 'AP', Max(m.TransDate)
		, SUM(CASE WHEN @ReconcilePdYear < ((m.VoidYear * 1000) + m.VoidPd) THEN m.VoidAmtFgn ELSE m.AmountFgn END)
		, MIN(CASE WHEN s.StatementDate = @StatementDate THEN 1 ELSE 0 END)
	FROM dbo.tblSmBankAcct b 
	INNER JOIN dbo.tblBrMaster m ON b.BankId = m.BankID 
	LEFT JOIN dbo.tblBrStatement s ON m.StatementID = s.ID
	WHERE b.BankId = @BankAccountID 
		AND m.ACHBatch IS NOT NULL 
		AND ((s.StatementDate = @StatementDate) --cleared to current statement
			OR (((m.FiscalYear * 1000) + m.GlPeriod) <= @ReconcilePdYear --outstanding and within pd/year cutoff
				AND (CASE WHEN @ReconcilePdYear < ((m.VoidYear * 1000) + m.VoidPd) OR s.BeginDate > @StatementEndingDate THEN 0 ELSE m.ClearedYn END) = 0))
	GROUP BY m.BankId, m.ACHBatch

	-- return the detail recordset with totals
	-- Use RecordType of 1 when no transactional data is included (blank record with totals)
	SELECT CASE WHEN m.BankId IS NULL THEN 1 ELSE 0 END AS RecordType
		, b.BankId
		, @GlTotal AS GlAcctBal 
		, CASE @SortBy 
			WHEN 0 THEN m.SourceID 
			ELSE CONVERT(nvarchar(8), m.TransDate, 112) 
			END AS GrpId1
		, @StatementEndBalance AS LastStmtBal, @StatementDate AS LastStmtDate
		, m.TransType, m.SourceID, m.Descr, m.Reference
		, m.SourceApp, m.AmountFgn, m.TransDate, m.ClearedYn
		, ISNULL(t.TotDisbursements, 0) AS TotDisbursements, ISNULL(t.TotDeposits, 0) AS TotDeposits
		, ISNULL(t.TotTransfers, 0) AS TotTransfers, ISNULL(t.TotAdjustments, 0) AS TotAdjustments
		, ISNULL(-t.TotDisbursements, 0) TotDisbursementsBook, ISNULL(-t.TotDeposits, 0) TotDepositsBook
		, ISNULL(-t.TotTransfers, 0) TotTransfersBook, ISNULL(-t.TotAdjustments, 0) TotAdjustmentsBook
		, @StatementEndBalance + ISNULL(TotDeposits, 0) + ISNULL(TotDisbursements, 0) 
			+ ISNULL(TotAdjustments, 0) + ISNULL(t.TotTransfers, 0) AS AccumulatedBalanceBank
		, @StatementEndBalance + ISNULL(TotDeposits, 0) + ISNULL(TotDisbursements, 0) 
			+ ISNULL(TotAdjustments, 0) + ISNULL(t.TotTransfers, 0) 
			- @GlTotal AS UnreconciledAmountBank
		, @GlTotal
			- (ISNULL(TotDeposits, 0) + ISNULL(TotDisbursements, 0) + ISNULL(TotAdjustments, 0) 
			+ ISNULL(t.TotTransfers, 0)) AS AccumulatedBalanceBook
		, @GlTotal
			- (ISNULL(TotDeposits, 0) + ISNULL(TotDisbursements, 0) + ISNULL(TotAdjustments, 0) 
			+ ISNULL(t.TotTransfers, 0)) - @StatementEndBalance AS UnreconciledAmountBook 
	FROM dbo.tblSmBankAcct b 
	LEFT JOIN 
	(
		SELECT BankId
			, SUM(CASE WHEN TransType = -1 THEN AmountFgn ELSE 0 END) AS TotDisbursements
			, SUM(CASE WHEN TransType = 2 THEN AmountFgn ELSE 0 END) AS TotDeposits
			, SUM(CASE WHEN TransType = -3 THEN AmountFgn ELSE 0 END) AS TotTransfers
			, SUM(CASE WHEN TransType = 4 THEN AmountFgn ELSE 0 END) AS TotAdjustments 
		FROM #Reconiliation WHERE BankId = @BankAccountID
		GROUP BY BankId
	) t ON b.BankId = t.BankId 
	LEFT JOIN 
	(
		SELECT m1.BankId, m1.TransType, m1.SourceId, m1.Descr, m1.Reference
			, m1.SourceApp, m1.AmountFgn, m1.TransDate, m1.ClearedYn
		FROM #Trans m1
		WHERE (@IncludeTransactions = 2 
			OR (@IncludeTransactions = 0 AND m1.ClearedYn <> 0) 
			OR (@IncludeTransactions = 1 AND m1.ClearedYn = 0))
	) m ON b.BankId = m.BankID
	WHERE b.BankId = @BankAccountID 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrReconciliationReport2_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrReconciliationReport2_proc';

