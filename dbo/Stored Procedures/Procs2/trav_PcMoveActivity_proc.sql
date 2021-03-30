
CREATE PROCEDURE dbo.trav_PcMoveActivity_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint, @WksDate datetime,@CompId nvarchar(3),
		@PostDtlYn bit, @SourceCode nvarchar(2), @ProjectDetailId int, @FiscalYear smallint, @FiscalPeriod smallint,
		@Reference nvarchar(15), @Description nvarchar(30)

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @ProjectDetailId = Cast([Value] AS int) FROM #GlobalValues WHERE [Key] = 'ProjectDetailId'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
			
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL 
		OR @ProjectDetailId IS NULL OR @ProjectDetailId = 0 OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	CREATE TABLE #MoveActivityLog
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

	SELECT @SourceCode = 'JC', @Reference = 'Move activity', @Description = 'Overhead allocation'
	
	--Reverse Entries
	--WIP Account 
	BEGIN
		--Income: General, Billable and non Fixed Fee
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 801 AS [Grouping], a.GLAcctWIP, -a.ExtIncome, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],			
			CASE WHEN -a.ExtIncome > 0 THEN ABS(-a.ExtIncome) ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		WHERE p.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.[Source] <> 11--no po receipt
		
		--Cost: Job Cost
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 801 AS [Grouping], a.GLAcctWIP, -a.ExtCost, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN -a.ExtCost > 0 THEN ABS(-a.ExtCost) ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			LEFT JOIN dbo.tblSmTransLink l ON a.LinkSeqNum = l.SeqNum 
		WHERE p.Type = 1 AND ISNULL(l.DropShipYn,0) = 0 AND a.[Source] <> 11--skip for drop shipped,no po receipt
	END
	
	--Cost Account
	BEGIN
		--General, Administrative
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 802 AS [Grouping], a.GLAcctCost, -a.ExtCost, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN -a.ExtCost > 0 THEN ABS(-a.ExtCost) ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			LEFT JOIN dbo.tblSmTransLink l ON a.LinkSeqNum = l.SeqNum 
		WHERE (p.Type = 0 OR p.Type = 2) AND ISNULL(l.DropShipYn,0) = 0 AND a.[Source] <> 11--skip for drop shipped,no po receipt
	END
	
	--Accrued Income Account
	BEGIN
		--General, Billable and non Fixed Fee
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 803 AS [Grouping], a.GLAcctAccruedIncome, a.ExtIncome, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtIncome > 0 THEN ABS(-a.ExtIncome) ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.[Source] <> 11--no po receipt
	END	
	
	--Payroll Clearing Account
	BEGIN
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 805 AS [Grouping], a.GLAcctPayrollClearing, a.ExtCost, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtCost > 0 THEN ABS(-a.ExtCost) ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		WHERE a.[Type] = 0 AND a.[Source] <> 11--no po receipt
	END
	
	--reverse overhead posted
	INSERT INTO dbo.tblPcActivity(ProjectDetailId, [Source], [Type], ExtCost, [Description], ActivityDate, Reference,
		DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, 
		GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, [Status])
	SELECT a.ProjectDetailId, 2, a.[Type], -a.OverheadPosted, @Description, @WksDate, @Reference, a.DistCode, 
		a.GLAcctWIP, a.GLAcctPayrollClearing, a.GLAcctIncome, a.GLAcctCost, a.GLAcctAdjustments, a.GLAcctFixedFeeBilling,
		a.GLAcctOverheadContra, a.GLAcctAccruedIncome, a.TaxClass, @FiscalPeriod, @FiscalYear, 2
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
		INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	WHERE a.OverheadPosted <> 0
	
	--gl entries
	--Overhead Account
	INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
		CreditAmount,TransDate,DistCode,ActivityId)
	SELECT @FiscalYear, @FiscalPeriod, 806, a.GLAcctOverheadContra,a.OverheadPosted,@Reference,@Description,
		CASE WHEN a.OverheadPosted > 0 THEN a.OverheadPosted ELSE 0 END AS DebitAmount,
		CASE WHEN a.OverheadPosted < 0 THEN ABS(a.OverheadPosted) ELSE 0 END AS CreditAmount,
		a.ActivityDate, a.DistCode, a.Id
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
		INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	 WHERE a.OverheadPosted <> 0
	 
	 --WIP Account
	INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
		CreditAmount,TransDate,DistCode,ActivityId)
	SELECT @FiscalYear, @FiscalPeriod, 806, a.GLAcctWIP,-a.OverheadPosted,@Reference,@Description,
		CASE WHEN -a.OverheadPosted > 0 THEN -a.OverheadPosted ELSE 0 END AS DebitAmount,
		CASE WHEN -a.OverheadPosted < 0 THEN ABS(-a.OverheadPosted) ELSE 0 END AS CreditAmount,
		a.ActivityDate, a.DistCode, a.Id
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
		INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	 WHERE p.Type = 1 AND a.OverheadPosted <> 0 --Job Costing
	 	 
	 --Cost Account
	INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
		CreditAmount,TransDate,DistCode,ActivityId)
	SELECT @FiscalYear, @FiscalPeriod, 806, a.GLAcctCost,-a.OverheadPosted,@Reference,@Description,
		CASE WHEN -a.OverheadPosted > 0 THEN -a.OverheadPosted ELSE 0 END AS DebitAmount,
		CASE WHEN -a.OverheadPosted < 0 THEN ABS(-a.OverheadPosted) ELSE 0 END AS CreditAmount,
		a.ActivityDate, a.DistCode, a.Id
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
		INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	 WHERE p.Type IN (0,2) AND a.OverheadPosted <> 0 --Job Costing	 

	 --Remove prepared overhead
	 DELETE dbo.tblPcPrepareOverhead WHERE ActivityId IN (SELECT TransId FROM #PostTransList)
	 		
	--Update ProjectDetailId with new id of project/task and set OverheadPosted to 0.
	UPDATE dbo.tblPcActivity SET ProjectDetailId = @ProjectDetailId, OverheadPosted = 0
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id--include po receipt
	
	--Update distcode, gl accounts based on new project/task, recalcuate income
	--Do not recalculate tblPcActivity.ExtIncome if activity source is Bill via PC (Source = 14) 
	UPDATE dbo.tblPcActivity SET DistCode = d.DistCode, GLAcctAccruedIncome = c.GLAcctAccruedIncome, GLAcctAdjustments = c.GLAcctAdjustments,
		GLAcctCost = c.GLAcctCost, GLAcctFixedFeeBilling = c.GLAcctFixedFeeBilling, GLAcctIncome = c.GLAcctIncome,
		GLAcctOverheadContra = c.GLAcctOverheadContra, GLAcctPayrollClearing = c.GLAcctPayrollClearing, GLAcctWIP = c.GLAcctWIP,
		ExtIncome = CASE a.[Source] WHEN 3 THEN a.ExtIncome WHEN 14 THEN a.ExtIncome ELSE 
			ROUND(CASE WHEN d.OverrideRate > 0 THEN a.Qty * d.OverrideRate ELSE 
				CASE WHEN e.Rate IS NOT NULL THEN a.Qty * e.Rate ELSE a.ExtIncome END END, @PrecCurr) END --Do not recalcuate incomes for adjustment or no existing employee rate 
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
		INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id
		LEFT JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode 
		LEFT JOIN dbo.tblPcEmpRates e ON a.ResourceId = e.EmpId AND a.RateId = e.RateId
	WHERE a.[Type] = 0 
	
	--Do not recalculate tblPcActivity.ExtIncome if activity source is Bill via PC (Source = 14)
	UPDATE dbo.tblPcActivity SET DistCode = d.DistCode, GLAcctAccruedIncome = c.GLAcctAccruedIncome, GLAcctAdjustments = c.GLAcctAdjustments,
		GLAcctCost = c.GLAcctCost, GLAcctFixedFeeBilling = c.GLAcctFixedFeeBilling, GLAcctIncome = c.GLAcctIncome,
		GLAcctOverheadContra = c.GLAcctOverheadContra, GLAcctPayrollClearing = c.GLAcctPayrollClearing, GLAcctWIP = c.GLAcctWIP,
		ExtIncome = CASE a.[Source] WHEN 3 THEN a.ExtIncome WHEN 14 THEN a.ExtIncome ELSE CASE a.[Type] WHEN 1 THEN ROUND(a.ExtCost * ( 1 + d.MaterialMarkup/100), @PrecCurr) 
			WHEN 2 THEN ROUND(a.ExtCost * ( 1 + d.ExpenseMarkup/100), @PrecCurr) 
			WHEN 3 THEN ROUND(a.ExtCost * ( 1 + d.OtherMarkup/100), @PrecCurr) END END --Do not recalcuate incomes for adjustment
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
		INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id
		LEFT JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode 
	WHERE a.[Type] > 0  
	
	--New Entries
	--WIP Account 
	BEGIN
		--Income: General, Billable and non Fixed Fee
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 901 AS [Grouping], a.GLAcctWIP, a.ExtIncome, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtIncome > 0 THEN ABS(-a.ExtIncome) ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		WHERE p.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.[Source] <> 11--no po receipt
		
		--Cost: Job Cost
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 901 AS [Grouping], a.GLAcctWIP, a.ExtCost, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtCost > 0 THEN ABS(-a.ExtCost) ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			LEFT JOIN dbo.tblSmTransLink l ON a.LinkSeqNum = l.SeqNum 
		WHERE p.Type = 1 AND ISNULL(l.DropShipYn,0) = 0 AND a.[Source] <> 11--skip for drop shipped,no po receipt
	END
	
	--Cost Account
	BEGIN
		--General, Administrative
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 902 AS [Grouping], a.GLAcctCost, a.ExtCost, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtCost > 0 THEN ABS(-a.ExtCost) ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			LEFT JOIN dbo.tblSmTransLink l ON a.LinkSeqNum = l.SeqNum 
		WHERE (p.Type = 0 OR p.Type = 2) AND ISNULL(l.DropShipYn,0) = 0 AND a.[Source] <> 11--skip for drop shipped,no po receipt
	END
	
	--Accrued Income Account
	BEGIN
		--General, Billable and non Fixed Fee
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 903 AS [Grouping], a.GLAcctAccruedIncome, -a.ExtIncome, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN -a.ExtIncome > 0 THEN ABS(-a.ExtIncome) ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.[Source] <> 11--no po receipt
	END	
	
	--Payroll Clearing Account
	BEGIN
		INSERT INTO #MoveActivityLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT @FiscalYear, @FiscalPeriod, 905 AS [Grouping], a.GLAcctPayrollClearing, -a.ExtCost, @Reference, 
			CASE WHEN ISNULL(a.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(a.[Description],30) END AS [Description],
			CASE WHEN -a.ExtCost > 0 THEN ABS(-a.ExtCost) ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS CreditAmount,
			a.ActivityDate, a.DistCode, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcActivity a ON t.TransId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		WHERE a.[Type] = 0 AND a.[Source] <> 11--no po receipt
	END
	
	IF @PostDtlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(Amount), 'Move', 'Move Activities', SUM(DebitAmount), 
			SUM(CreditAmount), SUM(DebitAmount), SUM(CreditAmount), @SourceCode, @WksDate, @WksDate, @CurrBase, 1, @CompId
		FROM #MoveActivityLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
		HAVING SUM(DebitAmount) <> 0 OR SUM(CreditAmount) <> 0 
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode, 
			LinkId, LinkIDSubLine)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, Amount, Reference, [Description], DebitAmount, 
			CreditAmount,DebitAmount, CreditAmount, @SourceCode, @WksDate, TransDate, @CurrBase, 1, @CompId, DistCode,
			ActivityId, -1 
		FROM #MoveActivityLog
		WHERE CreditAmount <> 0 OR DebitAmount <> 0 
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcMoveActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcMoveActivity_proc';

