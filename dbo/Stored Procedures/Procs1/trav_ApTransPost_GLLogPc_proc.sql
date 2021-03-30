
CREATE PROCEDURE dbo.trav_ApTransPost_GLLogPc_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint, @WksDate datetime,@CompId nvarchar(3),
		@SourceCode nvarchar(2), @ApDetail bit

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @ApDetail = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApDetail'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @ApDetail IS NULL
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
		[BatchId] pBatchId NOT NULL,
		[LinkID] [nvarchar](15) NULL,
		[LinkIDSub] [nvarchar](15) NULL,
		[LinkIDSubLine] [int] NULL DEFAULT (0)
	)

	SET @SourceCode = 'AP'
	--WIP Account 
	BEGIN
		--Income: General, Billable and non Fixed Fee
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,LinkID,LinkIDSub,LinkIDSubLine)
		SELECT th.FiscalYear,th.GlPeriod, 801 AS [Grouping], a.GLAcctWIP, a.ExtIncome, th.VendorId, 
			CASE WHEN ISNULL(td.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE td.GLDesc END AS [Description], 
			CASE WHEN a.ExtIncome > 0 THEN a.ExtIncome ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtIncome < 0 THEN ABS(a.ExtIncome) ELSE 0 END AS CreditAmount,
			th.InvoiceDate, th.DistCode, th.BatchId, th.TransId, th.InvoiceNum, td.EntryNum
		FROM #PostTransList l INNER JOIN dbo.tblApTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
			INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
			INNER JOIN dbo.tblPcActivity a ON p.ActivityId = a.Id 
			INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject j ON d.ProjectId = j.Id 
		WHERE j.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.ExtIncome <> 0
		
		--Cost: Job Cost
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,LinkID,LinkIDSub,LinkIDSubLine)
		SELECT th.FiscalYear,th.GlPeriod, 801 AS [Grouping], a.GLAcctWIP, a.ExtCost, th.VendorId, 
			CASE WHEN ISNULL(td.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE td.GLDesc END AS [Description],
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost < 0 THEN ABS(a.ExtCost) ELSE 0 END AS CreditAmount,
			th.InvoiceDate, a.DistCode, th.BatchId, th.TransId, th.InvoiceNum, td.EntryNum
		FROM #PostTransList l INNER JOIN dbo.tblApTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
			INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
			INNER JOIN dbo.tblPcActivity a ON p.ActivityId = a.Id 
			INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject j ON d.ProjectId = j.Id 
		WHERE j.[Type] = 1 AND a.ExtCost <> 0
	END
	
	--Cost Account
	BEGIN
		--General, Administrative
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,LinkID,LinkIDSub,LinkIDSubLine)
		SELECT th.FiscalYear,th.GlPeriod, 802 AS [Grouping], td.GLAcct, a.ExtCost, th.VendorId, --Use GL account from line item
			CASE WHEN ISNULL(td.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE td.GLDesc END AS [Description],
			CASE WHEN a.ExtCost > 0 THEN a.ExtCost ELSE 0 END AS DebitAmount,
			CASE WHEN a.ExtCost < 0 THEN ABS(a.ExtCost) ELSE 0 END AS CreditAmount,
			th.InvoiceDate, a.DistCode, th.BatchId, th.TransId, th.InvoiceNum, td.EntryNum
		FROM #PostTransList l INNER JOIN dbo.tblApTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
			INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
			INNER JOIN dbo.tblPcActivity a ON p.ActivityId = a.Id 
			INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject j ON d.ProjectId = j.Id 
		WHERE (j.[Type] = 0 OR j.[Type] = 2) AND a.ExtCost <> 0-- skip for drop shipped
	END
	
	--Accrued Income Account
	BEGIN
		--General, Billable and non Fixed Fee
		INSERT INTO #TransPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,BatchId,LinkID,LinkIDSub,LinkIDSubLine)
		SELECT th.FiscalYear,th.GlPeriod, 803 AS [Grouping], a.GLAcctAccruedIncome, -a.ExtIncome, 
			j.ProjectName, ISNULL(j.CustId,'') + '/' + j.ProjectName AS [Description], 
			CASE WHEN -a.ExtIncome > 0 THEN -a.ExtIncome ELSE 0 END AS DebitAmount,
			CASE WHEN -a.ExtIncome < 0 THEN ABS(-a.ExtIncome) ELSE 0 END AS CreditAmount,
			th.InvoiceDate, a.DistCode, th.BatchId, th.TransId, th.InvoiceNum, td.EntryNum
		FROM #PostTransList l INNER JOIN dbo.tblApTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
			INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
			INNER JOIN dbo.tblPcActivity a ON p.ActivityId = a.Id 
			INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject j ON d.ProjectId = j.Id 
		WHERE j.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.ExtIncome <> 0
	END	
	
	IF @ApDetail = 1
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,BatchId, 
			LinkId,LinkIDSub,LinkIDSubLine)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, Amount, Reference, [Description], DebitAmount, 
			CreditAmount,DebitAmount, CreditAmount, @SourceCode, @WksDate, TransDate, @CurrBase, 1, @CompId, DistCode, BatchId,
			LinkId,LinkIDSub,LinkIDSubLine
		FROM #TransPostLog
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(Amount), 'AP', 
			CASE WHEN [Grouping] = 801 THEN 'Work in process' WHEN [Grouping] = 802 THEN 'Cost' 
				WHEN [Grouping] = 803 THEN 'Accrued Income' ELSE '??????' END,
			CASE WHEN SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END DR, 
			CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END CR, 
			CASE WHEN SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END DR, 
			CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END CR, 
			'AP', @WksDate, @WksDate, @CurrBase, 1, @CompId
		FROM #TransPostLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_GLLogPc_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_GLLogPc_proc';

