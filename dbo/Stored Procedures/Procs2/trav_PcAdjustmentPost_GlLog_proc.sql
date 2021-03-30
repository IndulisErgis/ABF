
CREATE PROCEDURE dbo.trav_PcAdjustmentPost_GlLog_proc
AS
BEGIN TRY
	--create activity before create gl log
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @WksDate datetime,@CompId nvarchar(3),
		@PostDtlYn bit, @SourceCode nvarchar(2), @Reference nvarchar(15)

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	CREATE TABLE #AdjustmentPostLog
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
		[Description] pGLDesc NULL,
		[ActivityId] int NOT NULL
	)
	
	SELECT @SourceCode = 'JC', @Reference = 'Adjustment'
	--WIP Account 
	BEGIN
		--Income: General, Billable, non Fixed Fee, non-zero income, activity status is posted 
		--Activity type is Time, Material, Expense or Other
		INSERT INTO #AdjustmentPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 401 AS [Grouping], a.GLAcctWIP, 
			m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END AS ExtIncome, @Reference, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END > 0 THEN m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END ELSE 0 END AS DebitAmount,
			CASE WHEN m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END < 0 THEN ABS(m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, t.ActivityID
		FROM #PostTransList t INNER JOIN dbo.tblPcAdjustment m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode a ON d.DistCode = a.DistCode
		WHERE p.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND m.ExtIncome <> 0 AND m.[Status] = 0 AND m.[Type] < 4
		
		--Cost: Job Cost, non-zero cost, activity status is posted 
		--Activity type is Time, Material, Expense or Other
		INSERT INTO #AdjustmentPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 401 AS [Grouping], a.GLAcctWIP, 
			m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END AS ExtCost, @Reference, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END > 0 THEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END ELSE 0 END AS DebitAmount,
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END < 0 THEN ABS(m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, t.ActivityID
		FROM #PostTransList t INNER JOIN dbo.tblPcAdjustment m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode a ON d.DistCode = a.DistCode
		WHERE p.Type = 1 AND m.ExtCost <> 0 AND m.[Status] = 0 AND m.[Type] < 4
	END
		
	--Cost Account
	BEGIN
		--General, Administrative, non-zero cost, activity status is posted 
		--Activity type is Time, Material, Expense or Other
		INSERT INTO #AdjustmentPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 402 AS [Grouping], a.GLAcctCost, 
			m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END AS ExtCost, @Reference, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END > 0 THEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END ELSE 0 END AS DebitAmount,
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END < 0 THEN ABS(m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, t.ActivityID
		FROM #PostTransList t INNER JOIN dbo.tblPcAdjustment m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode a ON d.DistCode = a.DistCode
		WHERE (p.Type = 0 OR p.Type = 2) AND m.ExtCost <> 0 AND m.[Status] = 0 AND m.[Type] < 4
	END
	
	--Accrued Income Account
	BEGIN
		--Income: General, Billable, non Fixed Fee, non-zero income, activity status is posted 
		--Activity type is Time, Material, Expense or Other
		INSERT INTO #AdjustmentPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 403 AS [Grouping], a.GLAcctAccruedIncome, 
			-m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END AS ExtIncome, @Reference, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END < 0 THEN ABS(m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END) ELSE 0 END AS DebitAmount,
			CASE WHEN m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END > 0 THEN m.ExtIncome * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, t.ActivityID
		FROM #PostTransList t INNER JOIN dbo.tblPcAdjustment m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode a ON d.DistCode = a.DistCode
		WHERE p.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND m.ExtIncome <> 0 AND m.[Status] = 0 AND m.[Type] < 4
	END	
	
	--Payroll Clearing Account
	BEGIN
		--Non-zero cost, activity status is posted 
		--Activity type is Time
		INSERT INTO #AdjustmentPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 404 AS [Grouping], a.GLAcctPayrollClearing, 
			-m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END AS ExtCost, @Reference, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END < 0 THEN ABS(m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END) ELSE 0 END AS DebitAmount,
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END > 0 THEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, t.ActivityID
		FROM #PostTransList t INNER JOIN dbo.tblPcAdjustment m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode a ON d.DistCode = a.DistCode
		WHERE m.ExtCost <> 0 AND m.[Status] = 0 AND m.[Type] = 0
	END
	
	--Adjustment Account
	BEGIN
		--Non-zero cost, activity status is posted 
		--Activity type is Material, Expense or Other
		INSERT INTO #AdjustmentPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 405 AS [Grouping], a.GLAcctAdjustments, 
			-m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END AS ExtCost, @Reference, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END < 0 THEN ABS(m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END) ELSE 0 END AS DebitAmount,
			CASE WHEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END > 0 THEN m.ExtCost * CASE m.IncDec WHEN 0 THEN 1 ELSE -1 END ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, t.ActivityID
		FROM #PostTransList t INNER JOIN dbo.tblPcAdjustment m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode a ON d.DistCode = a.DistCode
		WHERE m.ExtCost <> 0 AND m.[Status] = 0 AND m.[Type] BETWEEN 1 AND 3
	END
	
	IF @PostDtlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(Amount), @Reference, 'Adjustments summary',
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmount,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmount,
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmountFgn,
			@SourceCode, @WksDate, @WksDate, @CurrBase, 1, @CompId
		FROM #AdjustmentPostLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,LinkId,LinkIDSubLine)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, Amount, Reference, [Description], DebitAmount, 
			CreditAmount,DebitAmount, CreditAmount, @SourceCode, @WksDate, TransDate, @CurrBase, 1, @CompId, DistCode, ActivityId, -1
		FROM #AdjustmentPostLog
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcAdjustmentPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcAdjustmentPost_GlLog_proc';

