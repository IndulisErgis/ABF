
CREATE PROCEDURE dbo.trav_PcCompeleteJobPost_GlLog_proc
AS
BEGIN TRY
	--todo, link fields
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @WksDate datetime,@CompId nvarchar(3),
		@PostDtlYn bit, @SourceCode nvarchar(2), @FiscalYear smallint, @FiscalPeriod smallint,
		@Reference nvarchar(15)

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
		
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL 
		OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	CREATE TABLE #CompleteJobPostLog
	(
		[FiscalYear] smallint NOT NULL,
		[FiscalPeriod] smallint NOT NULL,
		[TransDate] [datetime] NULL,
		[Grouping] smallint NOT NULL,
		[GlAccount] [pGlAcct] NULL,
		[Amount] [pDecimal] NOT NULL,
		[DebitAmount] [pDecimal] NOT NULL,
		[CreditAmount] [pDecimal] NOT NULL,
		[Reference] [nvarchar](15) NULL,
		[DistCode] [dbo].[pDistCode] NULL,	
		[Description] [nvarchar](30) NULL,
		[ActivityId] int NOT NULL
	)
	
	SELECT @SourceCode = 'JC', @Reference = 'Completed Job'
	
	--Cost 
	BEGIN
		--Cost Account
		INSERT INTO #CompleteJobPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear,@FiscalPeriod, 701 AS [Grouping], a.GLAcctCost, a.ExtCost, @Reference, 
			ISNULL(p.CustId,'') + '/' + p.ProjectName AS [Description], 
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost < 0 THEN ABS(a.ExtCost) ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcProjectDetail d ON t.TransId = d.Id
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
		WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4 AND a.ExtCost <> 0--Activity type is Time, Material, Expense, Other; Activity status is billed.
		
		--WIP Account
		INSERT INTO #CompleteJobPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear,@FiscalPeriod, 702 AS [Grouping], a.GLAcctWIP, -a.ExtCost, @Reference, 
			ISNULL(p.CustId,'') + '/' + p.ProjectName AS [Description], 
			CASE WHEN a.ExtCost < 0 THEN ABS(a.ExtCost) ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcProjectDetail d ON t.TransId = d.Id
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
		WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4 AND a.ExtCost <> 0--Activity type is Time, Material, Expense, Other; Activity status is billed.
	END
	
	--Income
	BEGIN
		--Fixed Fee Billings Account
		INSERT INTO #CompleteJobPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear,@FiscalPeriod, 703 AS [Grouping], a.GLAcctFixedFeeBilling, a.ExtIncome, @Reference, 
			ISNULL(p.CustId,'') + '/' + p.ProjectName AS [Description], 
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtIncome < 0 THEN ABS(a.ExtIncome) ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcProjectDetail d ON t.TransId = d.Id
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
		WHERE a.[Type] = 6 AND a.[Status] = 2 AND a.ExtIncome <> 0--Activity type is Fixed Fee Billing; Activity status is posted.
		
		--Income Account
		INSERT INTO #CompleteJobPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear,@FiscalPeriod, 704 AS [Grouping], a.GLAcctIncome, -a.ExtIncome, @Reference, 
			ISNULL(p.CustId,'') + '/' + p.ProjectName AS [Description], 
			CASE WHEN a.ExtIncome < 0 THEN ABS(a.ExtIncome) ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcProjectDetail d ON t.TransId = d.Id
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
		WHERE a.[Type] = 6 AND a.[Status] = 2 AND a.ExtIncome <> 0--Activity type is Fixed Fee Billing; Activity status is posted.
	END	
		
	IF @PostDtlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(Amount), @Reference, @Reference, 
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmount,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmount,
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmountFgn,
			@SourceCode, @WksDate, @WksDate, @CurrBase, 1, @CompId
		FROM #CompleteJobPostLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,LinkId,LinkIDSubLine)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, Amount, Reference, [Description], DebitAmount, 
			CreditAmount,DebitAmount, CreditAmount, @SourceCode, @WksDate, TransDate, @CurrBase, 1, @CompId, DistCode, ActivityId, -1
		FROM #CompleteJobPostLog
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompeleteJobPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompeleteJobPost_GlLog_proc';

