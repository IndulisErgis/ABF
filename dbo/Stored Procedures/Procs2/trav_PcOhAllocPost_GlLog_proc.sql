
CREATE PROCEDURE dbo.trav_PcOhAllocPost_GlLog_proc
AS
BEGIN TRY
	--create activity before create gl log
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @WksDate datetime,@CompId nvarchar(3),
		@PostDtlYn bit, @SourceCode nvarchar(2), @Reference nvarchar(15), @Description nvarchar(30)

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	CREATE TABLE #OhAllocPostLog
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
		[ActivityId] int NULL
	)
	
	SELECT @SourceCode = 'JC', @Reference = 'Overhead Alloc', @Description = 'Overhead Allocation Summary'
	--WIP Account 
	BEGIN
		--Job Cost, non-zero overhead
		INSERT INTO #OhAllocPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT o.FiscalYear,o.FiscalPeriod, 501 AS [Grouping], c.GLAcctWIP, 
			o.CurrOH, @Reference, p.ProjectName + ' ' + ISNULL(p.CustId,'') ,
			CASE WHEN o.CurrOH > 0 THEN o.CurrOH ELSE 0 END AS DebitAmount,
			CASE WHEN o.CurrOH < 0 THEN ABS(o.CurrOH) ELSE 0 END AS CreditAmount,
			o.TransDate, d.DistCode, v.ActivityId
		FROM dbo.tblPcPrepareOverhead o INNER JOIN #PostTransList t ON o.Id = t.TransId
			INNER JOIN dbo.tblPcActivity a ON o.ActivityId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode 
			LEFT JOIN #tmpOverhead v ON o.Id = v.OverheadId
		WHERE p.Type = 1 AND o.CurrOH <> 0
	END
		
	--Cost Account
	BEGIN
		--General, Administrative, non-zero overhead
		INSERT INTO #OhAllocPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT o.FiscalYear,o.FiscalPeriod, 502 AS [Grouping], c.GLAcctCost, 
			o.CurrOH, @Reference, p.ProjectName + ' ' + ISNULL(p.CustId,'') ,
			CASE WHEN o.CurrOH > 0 THEN o.CurrOH ELSE 0 END AS DebitAmount,
			CASE WHEN o.CurrOH < 0 THEN ABS(o.CurrOH) ELSE 0 END AS CreditAmount,
			o.TransDate, d.DistCode, v.ActivityId
		FROM dbo.tblPcPrepareOverhead o INNER JOIN #PostTransList t ON o.Id = t.TransId
			INNER JOIN dbo.tblPcActivity a ON o.ActivityId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode
			LEFT JOIN #tmpOverhead v ON o.Id = v.OverheadId
		WHERE (p.Type = 0 OR p.Type = 2) AND o.CurrOH <> 0
	END
	
	--Overhead Account
	BEGIN
		--General, Administrative, non-zero overhead
		INSERT INTO #OhAllocPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,TransDate,DistCode,ActivityId)
		SELECT o.FiscalYear,o.FiscalPeriod, 503 AS [Grouping], c.GLAcctOverheadContra, 
			-o.CurrOH, @Reference, p.ProjectName + ' ' + ISNULL(p.CustId,'') ,
			CASE WHEN o.CurrOH < 0 THEN ABS(o.CurrOH) ELSE 0 END AS DebitAmount,
			CASE WHEN o.CurrOH > 0 THEN o.CurrOH ELSE 0 END AS CreditAmount,
			o.TransDate, d.DistCode, v.ActivityId
		FROM dbo.tblPcPrepareOverhead o INNER JOIN #PostTransList t ON o.Id = t.TransId
			INNER JOIN dbo.tblPcActivity a ON o.ActivityId = a.Id
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode
			LEFT JOIN #tmpOverhead v ON o.Id = v.OverheadId
		WHERE o.CurrOH <> 0
	END	
	
	IF @PostDtlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(Amount), @Reference, @Description,
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmount,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmount,
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmountFgn,
			@SourceCode, @WksDate, @WksDate, @CurrBase, 1, @CompId
		FROM #OhAllocPostLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,LinkId,LinkIDSubLine)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, Amount, Reference, [Description], DebitAmount, 
			CreditAmount,DebitAmount, CreditAmount, @SourceCode, @WksDate, TransDate, @CurrBase, 1, @CompId, DistCode, ActivityId, -1
		FROM #OhAllocPostLog
	END
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcOhAllocPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcOhAllocPost_GlLog_proc';

