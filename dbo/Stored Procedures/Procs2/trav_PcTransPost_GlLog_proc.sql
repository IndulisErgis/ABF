
CREATE PROCEDURE dbo.trav_PcTransPost_GlLog_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint, @WksDate datetime,@CompId nvarchar(3),
		@PostDtlYn bit, @SourceCode nvarchar(2)

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	CREATE TABLE #TransPostLog
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
		[ActivityId] int NOT NULL,
		[BatchId] pBatchId NOT NULL
	)

	SET @SourceCode = 'JC'
	--WIP Account 
	BEGIN
		--Income: General, Billable and non Fixed Fee
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 801 AS [Grouping], a.GLAcctWIP, a.ExtIncome, p.ProjectName, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtIncome < 0 THEN ABS(a.ExtIncome) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, m.BatchId, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON m.ActivityId = a.Id
		WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.ExtIncome <> 0
		
		--Cost: Job Cost
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 801 AS [Grouping], a.GLAcctWIP, a.ExtCost, p.ProjectName, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost < 0 THEN ABS(a.ExtCost) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, m.BatchId, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON m.ActivityId = a.Id
			LEFT JOIN dbo.tblSmTransLink l ON m.LinkSeqNum = l.SeqNum 
		WHERE p.Type = 1 AND ISNULL(l.DropShipYn,0) = 0 AND a.ExtCost <> 0-- skip for drop shipped
	END
	
	--Cost Account
	BEGIN
		--General, Administrative
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 802 AS [Grouping], a.GLAcctCost, a.ExtCost, p.ProjectName, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost < 0 THEN ABS(a.ExtCost) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, m.BatchId, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON m.ActivityId = a.Id
			LEFT JOIN dbo.tblSmTransLink l ON m.LinkSeqNum = l.SeqNum 
		WHERE (p.Type = 0 OR p.Type = 2) AND ISNULL(l.DropShipYn,0) = 0 AND a.ExtCost <> 0-- skip for drop shipped
	END
	
	--Accrued Income Account
	BEGIN
		--General, Billable and non Fixed Fee
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 803 AS [Grouping], a.GLAcctAccruedIncome, -a.ExtIncome, p.ProjectName, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN -a.ExtIncome > 0 THEN -a.ExtIncome ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtIncome < 0 THEN ABS(-a.ExtIncome) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, m.BatchId, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON m.ActivityId = a.Id
		WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.ExtIncome <> 0
	END	
	
	--Credit Account
	BEGIN
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,ActivityId)
		SELECT m.FiscalYear,m.FiscalPeriod, 804 AS [Grouping], m.GLAcct, -a.ExtCost, p.ProjectName, 
			CASE WHEN ISNULL(m.[Description],'') = '' THEN ISNULL(p.CustId,'') + '/' + p.ProjectName ELSE LEFT(m.[Description],30) END AS [Description],			
			CASE WHEN -a.ExtCost > 0 THEN -a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtCost < 0 THEN ABS(-a.ExtCost) ELSE 0 END AS CreditAmount,
			m.TransDate, a.DistCode, m.BatchId, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
			INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON m.ActivityId = a.Id 
			LEFT JOIN dbo.tblSmTransLink l ON m.LinkSeqNum = l.SeqNum 
		WHERE ISNULL(l.DropShipYn,0) = 0 AND a.ExtCost <> 0 -- skip for drop shipped
	END
	
	IF @PostDtlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(Amount), 'Transaction', 'Transaction Entries', 
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmount,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmount,
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmountFgn,
			@SourceCode, @WksDate, @WksDate, @CurrBase, 1, @CompId
		FROM #TransPostLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,BatchId, 
			LinkId, LinkIDSubLine)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, Amount, Reference, [Description], DebitAmount, 
			CreditAmount,DebitAmount, CreditAmount, @SourceCode, @WksDate, TransDate, @CurrBase, 1, @CompId, DistCode, BatchId,
			ActivityId, -1 
		FROM #TransPostLog
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_GlLog_proc';

