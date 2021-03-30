
CREATE PROCEDURE dbo.trav_PcRevenueAdjustPost_GlLog_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE
	@PostRun dbo.pPostRun,
	@BatchId pBatchID,
	@WksDate datetime,
	@PcGlDetailYn bit,
	@ArGlYn bit,
	@AdjustDate datetime,
	@CompId dbo.pCompId,
	@BaseCurrency dbo.pCurrency,
	@NextGlPeriod smallint,
	@NextGlYear smallint,
	@GlPeriod smallint,
	@GlYear smallint,
	@SourceCode nvarchar(2) = 'JC'

	--Retrieve Global Values
	SELECT @CompId = DB_NAME()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PcGlDetailYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PcGlDetailYn'
	SELECT @BatchId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'BatchId'
	SELECT @ArGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlYn'
	SELECT @AdjustDate = CONVERT(datetime, [Value]) FROM #GlobalValues WHERE [Key] = 'AdjustDate'
	SELECT @BaseCurrency = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'BaseCurrency'
	SELECT @WksDate = CONVERT(datetime, [Value]) FROM #GlobalValues WHERE [Key] = 'WksDate'
	SELECT @NextGlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'NextFiscalPeriod'
	SELECT @NextGlYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'NextFiscalYear'
	SELECT @GlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @GlYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	IF @PostRun IS NULL OR @PcGlDetailYn IS NULL OR @BatchId IS NULL OR @ArGlYn IS NULL OR @AdjustDate IS NULL OR @BaseCurrency IS NULL OR @NextGlPeriod IS NULL OR @NextGlYear IS NULL OR @WksDate IS NULL
	BEGIN  
		RAISERROR(90025,16,1)  
	END 


	CREATE TABLE #PcRevenueAdjLogDtl   
	(  
		[Counter] int Not Null Identity(1, 1),   
		[RevenueAdjustId] bigint NOT NULL,
		[PostRun] pPostRun Not Null,
		[ProjectId] bigint Null,
		[DetailId] int Null, --unused
		[Grouping] smallint Null,
		[Descr] nvarchar(255) Null,
		[DetailDescr] nvarchar(255) NULL,
		[SourceCode] nvarchar(2) Null,   
		[Reference] nvarchar(15) Null,   
		[GlAcct] pGlAcct Null,
		[ExchRate] pDecimal NOT NULL,
		[FiscalPeriod] smallint Null,
		[FiscalYear] smallint Null,
		[LinkID] nvarchar(255) Null,
		[LinkIDSub] nvarchar(15) Null,
		[LinkIDSubLine] int Null,
		[CurrencyId] pCurrency Null,
		[DebitAmt] pDecimal Null Default(0),
		[CreditAmt] pDecimal Null Default(0),
		[NetAdjustAmt] pDecimal NULL Default(0),
		[ExcessType] tinyint NOT NULL
	)

	CREATE TABLE #PcProjects
	(
		[ProjectId] bigint NOT NULL,
		[ExchRate] pDecimal NOT NULL,
		[ProjectName] nvarchar(20) NOT NULL,
		[CustId] dbo.pCustId NOT NULL,
		[AmountFgn] dbo.pDec NOT NULL,
		[NetAdjustAmount] dbo.pDec NOT NULL,
		[RevenueAdjustId] bigint NOT NULL,
		[FiscalYear] smallint NOT NULL,
		[FiscalPeriod] smallint NOT NULL,
		[AdjustDate] datetime NOT NULL,
		[CurrencyId] dbo.pCurrency NOT NULL,
		[GlAcctIncome] dbo.pGlAcct NOT NULL,
		[GlBillingsInExc] dbo.pGlAcct NOT NULL,
		[GlEarningsInExc] dbo.pGlAcct NOT NULL,
		[BillingsInExcess] bit NOT NULL,
		[EarningsInExcess] bit NOT NULL
	)

	INSERT INTO #PcProjects
	SELECT p.ID, 
			1 ExchRate,
			p.ProjectName, 
			p.CustId,
			a.NetAdjustAmount  as AmountFgn,
			a.NetAdjustAmount,
			a.Id as RevenueAdjustId,
			b.FiscalYear,
			b.FiscalPeriod,
			@AdjustDate AdjustDate,
			@BaseCurrency, 
			a.GLAcctIncome,
			a.GLAcctBillingExcess,
			a.GLAcctEarningExcess,
			CAST(CASE WHEN BilledAmount > EarnedIncome THEN 1 
			WHEN BilledAmount < EarnedIncome THEN 0
			WHEN BilledAmount = EarnedIncome THEN 
			(CASE WHEN PostedAdjustAmount > 0 THEN 1 ELSE 0 END) END as bit) BillingsInExcess,
			CAST(CASE WHEN BilledAmount > EarnedIncome THEN 0 
			WHEN BilledAmount < EarnedIncome THEN 1
			WHEN BilledAmount = EarnedIncome THEN 
			(CASE WHEN PostedAdjustAmount > 0 THEN 0 ELSE 1 END) END as bit) EarningsInExcess
	FROM dbo.tblPcProject p
	INNER JOIN dbo.tblPcRevenueAdjust a ON a.ProjectID = p.Id
	INNER JOIN #tmpRevenueAdjusts t ON t.Id = a.ProjectId
	INNER JOIN dbo.tblPcRevenueAdjustBatch b on a.AdjustBatchID = b.Id
	INNER JOIN dbo.tblGlAcctHdr glHdr ON a.GLAcctIncome = glHdr.AcctId

	--Income
	INSERT INTO #PcRevenueAdjLogDtl(PostRun, RevenueAdjustId, ProjectId, DetailId, CurrencyId, 
									FiscalPeriod, FiscalYear, GlAcct, ExchRate,
									CreditAmt, 
									DebitAmt,
									[Grouping], LinkID, LinkIDSub, LinkIDSubLine, 
									Reference, SourceCode,
									Descr, DetailDescr, ExcessType)  
	SELECT @PostRun as PostRun, RevenueAdjustId, p.ProjectId, null as DetailId, p.CurrencyId, 
			FiscalPeriod, FiscalYear, GlAcctIncome as GlAccount, p.ExchRate,
			CASE WHEN AmountFgn < 0 THEN ABS(AmountFgn) ELSE 0 END CreditAmount, 
			CASE WHEN AmountFgn >= 0 THEN ABS(AmountFgn) ELSE 0 END DebitAmount,
			10 as [Grouping], CONVERT(nvarchar, p.RevenueAdjustId) as LinkID, null as LinkIDSub, -3 as LinkIDSubLine,
			p.CustId as Reference, @SourceCode,
			CASE WHEN BillingsInExcess = 1 THEN 'Billings excess adj'
				WHEN EarningsInExcess = 1 THEN 'Earnings excess adj'
				ELSE 'Unknown' END [Description],
			SUBSTRING(CONVERT(nvarchar,p.RevenueAdjustId) + ' \ ' + CONVERT(nvarchar,p.ProjectId) + ' \ ' + p.ProjectName, 0, 30) as [DetailDescr], CASE WHEN BillingsInExcess = 1 THEN 1 WHEN EarningsInExcess = 1 THEN 2 ELSE 3 END
	FROM #PcProjects p
	
	--Offset
	INSERT INTO #PcRevenueAdjLogDtl(PostRun, RevenueAdjustId, ProjectId, DetailId, CurrencyId, 
								FiscalPeriod, FiscalYear, 
								GlAcct, ExchRate,
								CreditAmt, 
								DebitAmt, 
								[Grouping], LinkID, LinkIDSub, LinkIDSubLine, 
								Reference, SourceCode,
								Descr, DetailDescr, ExcessType)  
	SELECT @PostRun as PostRun, RevenueAdjustId, p.ProjectId, null as DetailId, p.CurrencyId, 
			FiscalPeriod, FiscalYear,
			CASE WHEN p.BillingsInExcess = 1 THEN p.GlBillingsInExc WHEN p.EarningsInExcess = 1 THEN p.GlEarningsInExc END as GlAccount, p.ExchRate,
			CASE WHEN (AmountFgn * -1) < 0 THEN ABS(AmountFgn * -1) ELSE 0 END CreditAmountFgn, 
			CASE WHEN (AmountFgn * -1) >= 0 THEN ABS(AmountFgn * -1) ELSE 0 END DebitAmountFgn,
			20 as [Grouping], CONVERT(nvarchar, p.RevenueAdjustId) as LinkID, null as LinkIDSub, -3 as LinkIDSubLine,
			p.CustId as Reference, @SourceCode
			, CASE WHEN BillingsInExcess = 1 THEN 'Billings excess adj'
					WHEN EarningsInExcess = 1 THEN 'Earnings excess adj'
					ELSE 'Unknown' END [Description]
			, SUBSTRING(CONVERT(nvarchar,p.RevenueAdjustId) + ' \ ' + CONVERT(nvarchar,p.ProjectId) + ' \ ' + p.ProjectName, 0, 30) as [DetailDescr], CASE WHEN BillingsInExcess = 1 THEN 1 WHEN EarningsInExcess = 1 THEN 2 ELSE 3 END
	FROM #PcProjects p
	
	---------------
	----Reverse----
	---------------
	-- Reverse Income
	INSERT INTO #PcRevenueAdjLogDtl(PostRun, RevenueAdjustId, ProjectId, DetailId, CurrencyId, 
									FiscalPeriod, FiscalYear, GlAcct, ExchRate,
									CreditAmt, 
									DebitAmt, 
									[Grouping], LinkID, LinkIDSub, LinkIDSubLine, 
									Reference, SourceCode,
									Descr, DetailDescr, ExcessType)  
	SELECT @PostRun as PostRun, RevenueAdjustId, p.ProjectId, null as DetailId, p.CurrencyId, 
			@NextGlPeriod, @NextGlYear, 
			CASE WHEN p.BillingsInExcess = 1 THEN p.GlBillingsInExc WHEN p.EarningsInExcess = 1 THEN p.GlEarningsInExc END as GlAccount, p.ExchRate,
			CASE WHEN AmountFgn < 0 THEN ABS(AmountFgn) ELSE 0 END CreditAmount, 
			CASE WHEN AmountFgn >= 0 THEN ABS(AmountFgn) ELSE 0 END DebitAmount,
			20 as [Grouping], CONVERT(nvarchar, p.RevenueAdjustId) as LinkID, null as LinkIDSub, -3 as LinkIDSubLine,
			p.CustId as Reference, @SourceCode
			, CASE WHEN BillingsInExcess = 1 THEN 'Billings excess adj'
					WHEN EarningsInExcess = 1 THEN 'Earnings excess adj'
					ELSE 'Unknown' END [Description]
			, SUBSTRING(CONVERT(nvarchar,p.RevenueAdjustId) + ' \ ' + CONVERT(nvarchar,p.ProjectId) + ' \ ' + p.ProjectName, 0, 30) as [DetailDescr], CASE WHEN BillingsInExcess = 1 THEN 1 WHEN EarningsInExcess = 1 THEN 2 ELSE 3 END
	FROM #PcProjects p

	--Reverse Offset
	INSERT INTO #PcRevenueAdjLogDtl(PostRun, RevenueAdjustId, ProjectId, DetailId, CurrencyId, 
									FiscalPeriod, FiscalYear, GlAcct, ExchRate,
									CreditAmt, 
									DebitAmt, 
									[Grouping], LinkID, LinkIDSub, LinkIDSubLine, 
									Reference, SourceCode,
									Descr, DetailDescr, ExcessType)  
	SELECT @PostRun as PostRun, RevenueAdjustId, p.ProjectId, null as DetailId, p.CurrencyId, 
			@NextGlPeriod, @NextGlYear, GlAcctIncome as GlAccount, p.ExchRate,
			CASE WHEN (AmountFgn * -1) < 0 THEN ABS(AmountFgn * -1) ELSE 0 END CreditAmount, 
			CASE WHEN (AmountFgn * -1) >= 0 THEN ABS(AmountFgn * -1) ELSE 0 END DebitAmount,
			10 as [Grouping], CONVERT(nvarchar, p.RevenueAdjustId) as LinkID, null as LinkIDSub, -3 as LinkIDSubLine,
			p.CustId as Reference, @SourceCode,
			CASE WHEN BillingsInExcess = 1 THEN 'Billings excess adj'
				WHEN EarningsInExcess = 1 THEN 'Earnings excess adj'
				ELSE 'Unknown' END [Description],
			SUBSTRING(CONVERT(nvarchar,p.RevenueAdjustId) + ' \ ' + CONVERT(nvarchar,p.ProjectId) + ' \ ' + p.ProjectName, 0, 30) as [DetailDescr], CASE WHEN BillingsInExcess = 1 THEN 1 WHEN EarningsInExcess = 1 THEN 2 ELSE 3 END
	FROM #PcProjects p
	
	IF @PcGlDetailYn = 1
	BEGIN
		INSERT INTO #GlPostLogs(PostRun,CompId,GlAccount,FiscalYear,FiscalPeriod, [Grouping], 
			[Description],Reference,SourceCode,
			CreditAmount,DebitAmount,CreditAmountFgn,DebitAmountFgn, AmountFgn, ExchRate,
			CurrencyId,TransDate,PostDate,LinkId,LinkIDSub,LinkIdSubLine)  
		SELECT PostRun, @CompId as [CompId], GlAcct, FiscalYear, FiscalPeriod , [Grouping]
		, CASE @PcGlDetailYn WHEN 0 THEN 'Revenue Adj summary' ELSE [Descr] END, CASE @PcGlDetailYn WHEN 0 THEN 'Revenue Adjust' ELSE Reference END Reference, SourceCode
		, CreditAmt, DebitAmt, CreditAmt, DebitAmt, ABS(DebitAmt - CreditAmt) as AmountFgn, 1 as ExchRate
		, CurrencyId, @AdjustDate as TransDate, @WksDate as PostDate, CASE @PcGlDetailYn WHEN 0 THEN NULL ELSE LinkID END LinkId, null as LinkIDSub, CASE @PcGlDetailYn WHEN 0 THEN NULL ELSE LinkIDSubLine END LinkIdSubLine
		FROM #PcRevenueAdjLogDtl r
	END 
	ELSE 
	BEGIN
		INSERT INTO #GlPostLogs(PostRun,CompId,GlAccount,FiscalYear,FiscalPeriod, [Grouping], 
			[Description],Reference,SourceCode,
			CreditAmount,DebitAmount,CreditAmountFgn,DebitAmountFgn, AmountFgn, ExchRate,
			CurrencyId,TransDate,PostDate,LinkId,LinkIDSub,LinkIdSubLine)  
		SELECT @PostRun, @CompId as [CompId], GlAcct, FiscalYear, FiscalPeriod , [Grouping]
		, 'Revenue Adj summary' as [Descr], 'Revenue Adjust' as Reference, @SourceCode
		, SUM(CreditAmt) as CreditAmount, SUM(DebitAmt) as DebitAmount, SUM(CreditAmt) as CreditAmountFgn, SUM(DebitAmt) as DebitAmountFgn, ABS(SUM(DebitAmt) - SUM(CreditAmt)) as AmountFgn, 1 as ExchRate
		, @BaseCurrency, @AdjustDate as TransDate, @WksDate as PostDate, NULL as LinkId, null as LinkIDSub, NULL as LinkIdSubLine
		FROM #PcRevenueAdjLogDtl r
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAcct
	END

	--update the transaction summary log table  
	INSERT INTO #PostSummary ([ProjectId], [BatchId], [CurrencyId], [ProjectName], 
		[CustomerId], [FixedFeeAmt], [BilledAmt], [PostedCosts], [EstimatedCosts], [PctCostsComplete], [OverridePct], 
		[EarnedIncome], [EarningsInExcess], [BillingsInExcess], 
		[Adjustment], [PostedAdjustment], [NetAdjust], [NetAdjustFgn])  
	SELECT p.ProjectId, @BatchId, t.CurrencyId, SUBSTRING(p.ProjectName, 0, 255), 
	p.CustId, p.FixedFeeAmount, p.BilledAmount, p.PostedCost, p.EstimatedCost, p.PercentCostCompletion, p.OverridePercent,
	p.EarnedIncome, (CASE WHEN t.EarningsInExcess = 1 THEN (p.EarnedIncome - p.BilledAmount) ELSE 0 END) [EarningsInExcess], (CASE WHEN t.BillingsInExcess = 1 THEN (p.BilledAmount - p.EarnedIncome) ELSE 0 END) [BillingsInExcess], 
	(ISNULL(p.BilledAmount,0) - p.EarnedIncome) as Adjustment, p.PostedAdjustAmount, t.NetAdjustAmount, t.AmountFgn
	FROM #PcProjects t
	INNER JOIN tblPcRevenueAdjust p ON p.ProjectID = t.ProjectId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcRevenueAdjustPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcRevenueAdjustPost_GlLog_proc';

