
CREATE PROCEDURE dbo.trav_GlConsolidateAccount_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @SysDb [sysname], @CompanyFrom [sysname], @StepFrom tinyint, @StepThru tinyint
	DECLARE @sql1 nvarchar(max)

	--Retrieve global values
	SELECT @SysDb = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'SysDb'
	SELECT @CompanyFrom = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CompanyFrom'
	SELECT @StepFrom = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StepFrom'
	SELECT @StepThru = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StepThru'

	IF @SysDb IS NULL OR @CompanyFrom IS NULL OR @StepFrom IS NULL OR @StepThru IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE #AccountDetail
	(
		AcctId pGlAcct, 
		FiscalYear smallint, 
		FiscalPeriod smallint, 
		Actual pCurrDecimal,
		ActualBase pCurrDecimal,  
		ConsolToAcct pGlAcct
	)

	CREATE TABLE #AccountSummary
	(
		ConsolToAcct pGlAcct, 
		FiscalYear smallint, 
		FiscalPeriod smallint, 
		Actual pCurrDecimal, 
		ActualBase pCurrDecimal
	)

	CREATE TABLE #BudgetForecastDetail
	(
		AcctId pGlAcct, 
		FiscalPeriod smallint,
		FiscalYear smallint, 
		BFRef int,
		Amount pCurrDecimal, 
		ConsolToAcct pGlAcct
	)

	CREATE TABLE #BudgetForecastSummary
	(
		ConsolToAcct pGlAcct, 
		FiscalPeriod smallint,
		FiscalYear smallint, 
		BFRef int,      
		Amount pCurrDecimal 
	)

	--capture the account balances to consolidate with the current company
	SELECT @sql1 = 'INSERT INTO #AccountDetail (AcctId, FiscalYear, FiscalPeriod, Actual, ActualBase, ConsolToAcct)'
		+ ' SELECT h.AcctId, d.[Year], d.Period, d.Actual, d.ActualBase, h.ConsolToAcct'
		+ ' FROM [' + @CompanyFrom + '].dbo.tblGlAcctHdr h'
		+ ' INNER JOIN [' + @CompanyFrom + '].dbo.tblGlAcctDtl d on h.AcctId = d.AcctId'
		+ ' WHERE h.ConsolToAcct IS NOT NULL AND (ConsolToStep Between ' + STR(@StepFrom) + ' And ' + STR(@StepThru) + ')'
	EXEC (@sql1)		

	--summarize the captured balances by the consolidate to account id
	INSERT INTO #AccountSummary (ConsolToAcct, FiscalYear, FiscalPeriod, Actual, ActualBase) 
		SELECT ConsolToAcct, FiscalYear, FiscalPeriod, Sum(Actual), Sum(ActualBase)
		FROM #AccountDetail 
		GROUP BY ConsolToAcct, FiscalYear, FiscalPeriod 

	--populate the list of invalid ConsolToAcct id values
	INSERT INTO #InvalidAccounts([AccountId])
	SELECT s.ConsolToAcct 
	FROM #AccountSummary s
	LEFT JOIN dbo.tblGlAcctHdr h on s.ConsolToAcct = h.AcctId
	WHERE h.AcctId IS NULL
	GROUP BY s.ConsolToAcct
	
	--abort if invalid accounts exist
	IF (@@RowCount > 0)
	BEGIN
		RAISERROR('InvalidGLAccountId',16,1)
	END

	--update the current company account balances
	UPDATE dbo.tblGlAcctDtl 
		SET Actual = dbo.tblGlAcctDtl.Actual + t.Actual
			, ActualBase = dbo.tblGlAcctDtl.ActualBase + t.ActualBase
		FROM dbo.tblGlAcctDtl INNER JOIN #AccountSummary t 
			ON dbo.tblGlAcctDtl.AcctId = t.ConsolToAcct
			AND dbo.tblGlAcctDtl.[Year] = t.FiscalYear
			AND dbo.tblGlAcctDtl.[Period] = t.FiscalPeriod 

	--create account detail records for those that don't exist
	INSERT INTO dbo.tblGlAcctDtl ([AcctId], [Year], [Period], [Actual], [ActualBase], [Budget], [Forecast], [Balance])
		SELECT t.ConsolToAcct, t.FiscalYear, t.FiscalPeriod, t.Actual, t.ActualBase, 0, 0, 0
		FROM #AccountSummary t
		LEFT JOIN dbo.tblGlAcctDtl d 
			ON d.[AcctId] = t.[ConsolToAcct] 
			AND d.[Year] = t.FiscalYear 
			AND d.[Period] = t.FiscalPeriod
		WHERE d.AcctId IS NULL

	--capture the budget/forecast amounts to consolidate with the current company
	SELECT @sql1 = 'INSERT INTO #BudgetForecastDetail (AcctId, FiscalPeriod, FiscalYear, BFRef, Amount, ConsolToAcct)'
		+ ' SELECT dbf.AcctID, dbf.GlPeriod, dbf.GlYear, dbf.BFRef, ISNULL(dbf.Amount, 0) Amount, a.ConsolToAcct'
		+ ' FROM [' + @CompanyFrom + '].dbo.tblGlAcctDtlBudFrcst dbf'
		+ ' INNER JOIN [' + @SysDb + '].dbo.tblGlBudFrcstComp c on dbf.BFRef = c.BFRef'
		+ ' INNER JOIN (SELECT AcctId, ConsolToAcct FROM #AccountDetail GROUP BY AcctId, ConsolToAcct) a on dbf.AcctId = a.AcctId'
		+ ' WHERE c.[Status] = 1 AND c.CompID = ''' + @CompanyFrom + ''''
	EXEC (@sql1)

	--summarize the captured budget/forecast amounts by the consolidate to account id
	INSERT INTO #BudgetForecastSummary (ConsolToAcct, FiscalPeriod, FiscalYear, BFRef, Amount)
		SELECT ConsolToAcct, FiscalPeriod, FiscalYear, BFRef, SUM(Amount)
		FROM #BudgetForecastDetail 
		GROUP BY ConsolToAcct, FiscalYear, FiscalPeriod, BFRef 

	--update the current company budget/forecast amounts for those that already exist
	UPDATE dbo.tblGlAcctDtlBudFrcst 
		SET Amount = dbo.tblGlAcctDtlBudFrcst.Amount + t.amount 
		FROM dbo.tblGlAcctDtlBudFrcst INNER JOIN #BudgetForecastSummary t 
			ON dbo.tblGlAcctDtlBudFrcst.AcctId = t.ConsolToAcct
			AND dbo.tblGlAcctDtlBudFrcst.GlYear  = t.FiscalYear 
			AND dbo.tblGlAcctDtlBudFrcst.GLPeriod = t.FiscalPeriod 
			AND dbo.tblGlAcctDtlBudFrcst.BFRef = t.BFRef

	--create budget/forecast amounts for those that don't exist
	INSERT INTO dbo.tblGlAcctDtlBudFrcst (AcctID, BFRef, GlPeriod, GlYear, Amount) 
		SELECT t.ConsolToAcct, t.BFRef, t.FiscalPeriod, t.FiscalYear, t.Amount 
		FROM #BudgetForecastSummary t LEFT JOIN dbo.tblGlAcctDtlBudFrcst 
			ON t.ConsolToAcct = dbo.tblGlAcctDtlBudFrcst.AcctId 
			AND t.FiscalYear = dbo.tblGlAcctDtlBudFrcst.GlYear
			AND t.FiscalPeriod = dbo.tblGlAcctDtlBudFrcst.GLPeriod 
			AND t.BFRef = dbo.tblGlAcctDtlBudFrcst.BFRef 
		WHERE dbo.tblGlAcctDtlBudFrcst.AcctId IS NULL
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlConsolidateAccount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlConsolidateAccount_proc';

