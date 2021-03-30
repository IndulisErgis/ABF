
CREATE PROCEDURE dbo.trav_SvServiceOrderPost_GlLog_proc
AS
BEGIN TRY

	DECLARE @PostDtlYn bit, @PostRun pPostRun, @SourceCode nvarchar(2), @CurrBase pCurrency, @WrkStnDate datetime, @CompId nvarchar(3)


	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @SourceCode = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'SourceCode'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'

	IF @PostRun IS NULL OR @CurrBase IS NULL  OR @WrkStnDate IS NULL 
		 OR @CompId IS NULL OR @SourceCode IS NULL OR @PostDtlYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #PostLog
	(
		[FiscalYear] smallint NOT NULL,
		[FiscalPeriod] smallint NOT NULL,
		[TransDate] [datetime] NULL,
		[Grouping] smallint NOT NULL,
		[GlAccount] [pGlAcct] NULL,
		[Amount] [pDecimal] NOT NULL,
		[DebitAmount] [pDecimal] NOT NULL,
		[CreditAmount] [pDecimal] NOT NULL,
		[DebitAmountFgn] [pDecimal] NOT NULL,
		[CreditAmountFgn] [pDecimal] NOT NULL,
		[Reference] [nvarchar](15) NULL,
		[Description] [nvarchar](30) NULL,
		[LinkID] nvarchar(255) Null, 
		[LinkIDSub] nvarchar(255) Null 
	)
	--For SD
	-- Credit account
	INSERT #PostLog(FiscalYear, FiscalPeriod
		, [Grouping]
		, GlAccount, Amount, Reference, [Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate, LinkId,LinkIDSub)
	SELECT tr.FiscalYear, tr.FiscalPeriod
		, CASE WHEN tr.TransType = 0 THEN 10 WHEN tr.TransType = 1 THEN 20 WHEN tr.TransType = 2 THEN 30 WHEN tr.TransType = 3 THEN 40 END
		, tr.GLAcctCredit, -(tr.CostExt), o.SiteID, LEFT(tr.Description,30)
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END
		, tr.TransDate, o.ID,d.DispatchNo
	FROM #TransactionListToProcessTable t	
		INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
		INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
		LEFT JOIN dbo.tblSmTransLink k ON tr.LinkSeqNum = k.SeqNum
		LEFT JOIN dbo.tblSvWorkOrderDispatch d ON tr.DispatchID = d.ID
	WHERE tr.CostExt <> 0 AND ISNULL(k.DropShipYn,0) = 0 AND o.BillVia = 0-- skip for drop shipped

	-- Debit account
	INSERT #PostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate,LinkId,LinkIDSub)
	SELECT tr.FiscalYear,tr.FiscalPeriod, 50, tr.GLAcctDebit, tr.CostExt, o.SiteID, LEFT(tr.Description,30)
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, tr.TransDate, o.ID,d.DispatchNo
	FROM #TransactionListToProcessTable t	
		INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
		INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
		LEFT JOIN dbo.tblSmTransLink k ON tr.LinkSeqNum = k.SeqNum
		LEFT JOIN dbo.tblSvWorkOrderDispatch d ON tr.DispatchID = d.ID
	WHERE tr.CostExt <> 0 AND ISNULL(k.DropShipYn,0) = 0 AND o.BillVia = 0-- skip for drop shipped

	-- For PC
	-- WIP for transtype 0,1
	INSERT #PostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount
		, Amount
		, Reference,[Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate,LinkId,LinkIDSub)
	SELECT tr.FiscalYear,tr.FiscalPeriod, 100 AS [Grouping], dc.GLAcctWIP
		, tr.PriceExt
		, o.SiteID, tr.Description	
		, CASE WHEN tr.PriceExt > 0 THEN tr.PriceExt ELSE 0 END		
		, CASE WHEN tr.PriceExt < 0 THEN ABS(tr.PriceExt) ELSE 0 END
		, CASE WHEN tr.PriceExt > 0 THEN tr.PriceExt ELSE 0 END
		, CASE WHEN tr.PriceExt < 0 THEN ABS(tr.PriceExt) ELSE 0 END
		, tr.TransDate, o.ID,dis.DispatchNo
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	INNER JOIN dbo.tblPcProjectDetail d ON o.ProjectDetailID = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	INNER JOIN dbo.tblPcDistCode dc ON d.DistCode = dc.DistCode
	LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON tr.DispatchID = dis.ID
	WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND o.BillVia = 1 AND tr.TransType in( 0,1)

	-- WIP for other transtype
	INSERT #PostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount
		, Amount
		, Reference,[Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate,LinkId,LinkIDSub)
	SELECT tr.FiscalYear,tr.FiscalPeriod, 100 AS [Grouping], dc.GLAcctWIP
		, tr.CostExt 
		, o.SiteID, tr.Description	
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END		
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, tr.TransDate, o.ID,dis.DispatchNo
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	INNER JOIN dbo.tblPcProjectDetail d ON o.ProjectDetailID = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	INNER JOIN dbo.tblPcDistCode dc ON d.DistCode = dc.DistCode
	LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON tr.DispatchID = dis.ID
	WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND o.BillVia = 1 AND tr.TransType <> 0 AND tr.TransType <> 1


	-- Accrued Income for transtype 0,1
	INSERT #PostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount
		, Amount
		, Reference,[Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate,LinkId,LinkIDSub)
	SELECT tr.FiscalYear,tr.FiscalPeriod, 110 AS [Grouping], dc.GLAcctAccruedIncome
		, -(tr.PriceExt) 
		, o.SiteID, tr.Description	
		, CASE WHEN tr.PriceExt < 0 THEN ABS(tr.PriceExt) ELSE 0 END		
		, CASE WHEN tr.PriceExt > 0 THEN (tr.PriceExt) ELSE 0 END
		, CASE WHEN tr.PriceExt < 0 THEN ABS(tr.PriceExt) ELSE 0 END
		, CASE WHEN tr.PriceExt > 0 THEN (tr.PriceExt) ELSE 0 END
		, tr.TransDate, o.ID,dis.DispatchNo
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	INNER JOIN dbo.tblPcProjectDetail d ON o.ProjectDetailID = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	INNER JOIN dbo.tblPcDistCode dc ON d.DistCode = dc.DistCode
	LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON tr.DispatchID = dis.ID
	WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND o.BillVia = 1  AND tr.TransType in( 0,1)

	-- Accrued Income for other transtype
	INSERT #PostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount
		, Amount
		, Reference,[Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate,LinkId,LinkIDSub)
	SELECT tr.FiscalYear,tr.FiscalPeriod, 110 AS [Grouping], dc.GLAcctAccruedIncome
		, -(tr.CostExt) 
		, o.SiteID, tr.Description	
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END		
		, CASE WHEN tr.CostExt > 0 THEN (tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN (tr.CostExt) ELSE 0 END
		, tr.TransDate, o.ID,DispatchNo
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	INNER JOIN dbo.tblPcProjectDetail d ON o.ProjectDetailID = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	INNER JOIN dbo.tblPcDistCode dc ON d.DistCode = dc.DistCode
	LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON tr.DispatchID = dis.ID
	WHERE p.Type = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND o.BillVia = 1  AND tr.TransType <> 0 AND tr.TransType <> 1

	--Debit Account
	INSERT #PostLog(FiscalYear,FiscalPeriod
		, [Grouping]
		, GlAccount
		, Amount
		, Reference,[Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate,LinkId,LinkIDSub)
	SELECT tr.FiscalYear,tr.FiscalPeriod
		, CASE WHEN p.Type = 1 THEN 100 ELSE 50 END AS [Grouping]
		, CASE WHEN p.Type = 1 THEN dc.GLAcctWIP ELSE tr.GLAcctDebit END
		, tr.CostExt
		, o.SiteID, tr.Description	
		, CASE WHEN tr.CostExt > 0 THEN (tr.CostExt) ELSE 0 END		
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN (tr.CostExt) ELSE 0 END		
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, tr.TransDate, o.ID, dis.DispatchNo
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	INNER JOIN dbo.tblPcProjectDetail d ON o.ProjectDetailID = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	INNER JOIN dbo.tblPcDistCode dc ON d.DistCode = dc.DistCode
	LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON tr.DispatchID = dis.ID
	WHERE o.BillVia = 1 AND tr.TransType = 0

	INSERT #PostLog(FiscalYear,FiscalPeriod
		, [Grouping]
		, GlAccount
		, Amount
		, Reference,[Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate,LinkId,LinkIDSub)
	SELECT tr.FiscalYear,tr.FiscalPeriod
		, CASE WHEN p.Type = 1 THEN 100 ELSE 50 END AS [Grouping]
		, tr.GLAcctDebit
		, tr.CostExt
		, o.SiteID, tr.Description	
		, CASE WHEN tr.CostExt > 0 THEN (tr.CostExt) ELSE 0 END		
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN (tr.CostExt) ELSE 0 END		
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, tr.TransDate, o.ID, dis.DispatchNo
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	INNER JOIN dbo.tblPcProjectDetail d ON o.ProjectDetailID = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	INNER JOIN dbo.tblPcDistCode dc ON d.DistCode = dc.DistCode
	LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON tr.DispatchID = dis.ID
	WHERE o.BillVia = 1 AND tr.TransType = 1

	--Credit Account
	INSERT #PostLog(FiscalYear, FiscalPeriod
		, [Grouping]
		, GlAccount
		, Amount
		, Reference, [Description]
		, DebitAmount
		, CreditAmount
		, DebitAmountFgn
		, CreditAmountFgn
		, TransDate, LinkId,LinkIDSub)
	SELECT tr.FiscalYear, tr.FiscalPeriod
		, CASE WHEN tr.TransType = 0 THEN 10 WHEN tr.TransType = 1 THEN 20 END
		, tr.GLAcctCredit
		, -tr.CostExt
		, o.SiteID, LEFT(tr.Description,30)
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END
		, CASE WHEN tr.CostExt < 0 THEN ABS(tr.CostExt) ELSE 0 END
		, CASE WHEN tr.CostExt > 0 THEN tr.CostExt ELSE 0 END
		, tr.TransDate, o.ID,DispatchNo
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON tr.DispatchID = dis.ID
	WHERE o.BillVia = 1 AND (tr.TransType = 0 OR tr.TransType = 1 )

	IF(@PostDtlYn = 1)
	BEGIN

		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,LinkId,LinkIdSub,LinkIdSubLine)
		SELECT @PostRun, FiscalYear,FiscalPeriod,[Grouping],GlAccount, Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn, @SourceCode, @WrkStnDate, TransDate, @CurrBase, 1, @CompId, LinkId, LinkIDSub,NULL
		FROM #PostLog
	
	END
	ELSE
	BEGIN
		--Summarize credit/debit entries separately
		--Credit entry
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear,FiscalPeriod,[Grouping],GlAccount, -SUM(CreditAmountFgn),'SD', 
			CASE [Grouping] WHEN 10 THEN 'Labor' WHEN 20 THEN 'Part' WHEN 30 THEN 'Freight' WHEN 40 THEN 'Misc Charges' WHEN 50 THEN 'Maintenance Expense' WHEN 100 THEN 'WIP' WHEN 110 THEN 'Accrued Income'  END,
			0,	SUM(CreditAmount), 0, SUM(CreditAmountFgn), @SourceCode, @WrkStnDate, @WrkStnDate, @CurrBase, 1, @CompId
		FROM #PostLog
		WHERE CreditAmountFgn <> 0
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
		

		--Debit entry
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear,FiscalPeriod,[Grouping],GlAccount, SUM(DebitAmountFgn),'SD', 
			CASE [Grouping] WHEN 10 THEN 'Labor' WHEN 20 THEN 'Part' WHEN 30 THEN 'Freight' WHEN 40 THEN 'Misc Charges' WHEN 50 THEN 'Maintenance Expense' WHEN 100 THEN 'WIP' WHEN 110 THEN 'Accrued Income' END,
			SUM(DebitAmountFgn), 0, SUM(DebitAmountFgn), 0, @SourceCode, @WrkStnDate, @WrkStnDate, @CurrBase, 1, @CompId
		FROM #PostLog
		WHERE DebitAmountFgn <> 0
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
		

	END

	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GlLog_proc';

