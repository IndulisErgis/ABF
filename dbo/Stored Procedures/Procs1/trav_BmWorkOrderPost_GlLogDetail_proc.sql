
CREATE PROCEDURE dbo.trav_BmWorkOrderPost_GlLogDetail_proc 
AS
BEGIN TRY

	DECLARE @PostRun nvarchar(14), @CurrBase pCurrency, @WrkStnDate datetime,@CompId nvarchar(3),
		@PrecCurr tinyint

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @WrkStnDate IS NULL OR @CompId IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Components
	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkId, LinkIDSub, LinkIdSubLine)
	SELECT @PostRun,h.GlYear,h.GLPeriod,2,g.GLAcctInv,
		CASE WHEN h.WorkType = 1 THEN -1 ELSE 1 END * ROUND(d.UnitCost * d.ActQty, @PrecCurr),
		h.TransId + '(2)',d.ItemId,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(d.UnitCost * d.ActQty, @PrecCurr) END,
		CASE WHEN h.WorkType = 1 THEN ROUND(d.UnitCost * d.ActQty, @PrecCurr) ELSE 0 END,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(d.UnitCost * d.ActQty, @PrecCurr) END,
		CASE WHEN h.WorkType = 1 THEN ROUND(d.UnitCost * d.ActQty, @PrecCurr) ELSE 0 END,
		'BM',@WrkStnDate,h.TransDate,@CurrBase,1,@CompId,h.TransId,NULL,d.EntryNum
	FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrder h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblBmWorkOrderDetail d ON h.TransId = d.TransId 
		INNER JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
		LEFT JOIN dbo.tblInGlAcct g ON l.GlAcctCode = g.GlAcctCode 

	--Assembly
	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkId, LinkIDSub, LinkIdSubLine)
	SELECT @PostRun,h.GlYear,h.GLPeriod,0,g.GLAcctInv,
		CASE WHEN h.WorkType = 1 THEN 1 ELSE -1 END * ROUND(h.UnitCost * h.ActualQty, @PrecCurr),
		h.TransId + '(1)',
		CASE WHEN h.WorkType = 1 THEN h.ItemId + '/Build' ELSE h.ItemId + '/UnBld' END,
		CASE WHEN h.WorkType = 1 THEN ROUND(h.UnitCost * h.ActualQty, @PrecCurr) ELSE 0 END,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(h.UnitCost * h.ActualQty, @PrecCurr) END,
		CASE WHEN h.WorkType = 1 THEN ROUND(h.UnitCost * h.ActualQty, @PrecCurr) ELSE 0 END,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(h.UnitCost * h.ActualQty, @PrecCurr) END,
		'BM',@WrkStnDate,h.TransDate,@CurrBase,1,@CompId,h.TransId,NULL,-1
	FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrder h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId 
		LEFT JOIN dbo.tblInGlAcct g ON l.GlAcctCode = g.GlAcctCode 

	--PET:http://traversedev.internal.osas.com:8090/pets/view.php?id=13100
	--Adjustments 
	--	The cost of an assembly may not equal the sum of it's components for 
	--	build processing when building large quantities of assemblies 
	--	that use components with very small unit costs.
	--	Create an entry to the inventory PPV account for the difference
	INSERT #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount
		, AmountFgn, Reference, [Description]
		, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
		, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId, LinkId, LinkIDSub, LinkIdSubLine)
	SELECT @PostRun, h.GlYear, h.GLPeriod, 0, g.GLAcctPurchPriceVar
		, -(ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost)
		, h.TransId + '(1)', SUBSTRING(h.ItemId + '/PPV', 1, 30)
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) < 0 THEN -(ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) ELSE 0 END
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) < 0 THEN 0 ELSE (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) END
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) < 0 THEN -(ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) ELSE 0 END
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) < 0 THEN 0 ELSE (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) END
		, 'BM', @WrkStnDate, h.TransDate, @CurrBase, 1, @CompId, h.TransId, NULL, -1
	FROM #PostTransList t 
		INNER JOIN dbo.tblBmWorkOrder h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId 
		LEFT JOIN dbo.tblInGlAcct g ON l.GlAcctCode = g.GlAcctCode 
		INNER JOIN (SELECT t.TransId, SUM(ROUND(d.UnitCost * d.ActQty, @PrecCurr)) ComponentCost
			FROM #PostTransList t 
			INNER JOIN dbo.tblBmWorkOrderDetail d ON t.TransId = d.TransId 
			GROUP BY t.TransId) comp ON h.TransId = comp.TransId
	WHERE h.WorkType = 1 --Build only
		AND (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - comp.ComponentCost) <> 0
	
	--Adjustments 
	--	The cost of an assembly may not equal the sum of it's components for unbuild processing.
	--	Create an entry to the inventory adjustment account for the difference
	INSERT #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount
		, AmountFgn, Reference, [Description]
		, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
		, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId, LinkId, LinkIDSub, LinkIdSubLine)
	SELECT @PostRun, h.GlYear, h.GLPeriod, 0, g.GLAcctInvAdj
		, (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0))
		, h.TransId + '(1)', SUBSTRING(h.ItemId + '/Adjust', 1, 30)
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) < 0 THEN 0 ELSE (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) END
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) < 0 THEN -(ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) ELSE 0 END
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) < 0 THEN 0 ELSE (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) END
		, CASE WHEN (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) < 0 THEN -(ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) ELSE 0 END
		, 'BM', @WrkStnDate, h.TransDate, @CurrBase, 1, @CompId, h.TransId, NULL, -1
	FROM #PostTransList t 
		INNER JOIN dbo.tblBmWorkOrder h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId 
		LEFT JOIN dbo.tblInGlAcct g ON l.GlAcctCode = g.GlAcctCode 
		LEFT JOIN (SELECT t.TransId, SUM(ROUND(d.UnitCost * d.ActQty, @PrecCurr)) ComponentCost
			FROM #PostTransList t 
			INNER JOIN dbo.tblBmWorkOrderDetail d ON t.TransId = d.TransId   
			GROUP BY t.TransId) comp ON h.TransId = comp.TransId
	WHERE h.WorkType = 2 --Unbuild only
		AND (ROUND(h.UnitCost * h.ActualQty, @PrecCurr) - ISNULL(comp.ComponentCost,0)) <> 0
		

	--Labor cost
	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkId, LinkIDSub, LinkIdSubLine)
	SELECT @PostRun,h.GlYear,h.GLPeriod,1,
		CASE WHEN h.WorkType = 1 THEN g.GLInventoryLabour ELSE g.GLInventoryAppliedLabour END,
		CASE WHEN h.WorkType = 1 THEN 1 ELSE -1 END * ROUND(h.LaborCost * h.ActualQty, @PrecCurr),
		h.TransId,
		CASE WHEN h.WorkType = 1 THEN 'Inventory Labor' ELSE 'Applied Labor' END,
		CASE WHEN h.WorkType = 1 THEN ROUND(h.LaborCost * h.ActualQty, @PrecCurr) ELSE 0 END,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(h.LaborCost * h.ActualQty, @PrecCurr) END,
		CASE WHEN h.WorkType = 1 THEN ROUND(h.LaborCost * h.ActualQty, @PrecCurr) ELSE 0 END,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(h.LaborCost * h.ActualQty, @PrecCurr) END,
		'BM',@WrkStnDate,h.TransDate,@CurrBase,1,@CompId,h.TransId,NULL,-1
	FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrder h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId 
		LEFT JOIN dbo.tblBmAcctCode g ON l.GlAcctCode = g.GlAcctCode 
	WHERE h.LaborCost <> 0

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkId, LinkIDSub, LinkIdSubLine)
	SELECT @PostRun,h.GlYear,h.GLPeriod,1,
		CASE WHEN h.WorkType = 1 THEN g.GLInventoryAppliedLabour ELSE g.GLInventoryLabour END,
		CASE WHEN h.WorkType = 1 THEN -1 ELSE 1 END * ROUND(h.LaborCost * h.ActualQty, @PrecCurr),
		h.TransId,
		CASE WHEN h.WorkType = 1 THEN 'Applied Labor' ELSE 'Inventory Labor' END,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(h.LaborCost * h.ActualQty, @PrecCurr) END,
		CASE WHEN h.WorkType = 1 THEN ROUND(h.LaborCost * h.ActualQty, @PrecCurr) ELSE 0 END,
		CASE WHEN h.WorkType = 1 THEN 0 ELSE ROUND(h.LaborCost * h.ActualQty, @PrecCurr) END,
		CASE WHEN h.WorkType = 1 THEN ROUND(h.LaborCost * h.ActualQty, @PrecCurr) ELSE 0 END,
		'BM',@WrkStnDate,h.TransDate,@CurrBase,1,@CompId,h.TransId,NULL,-1
	FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrder h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId 
		LEFT JOIN dbo.tblBmAcctCode g ON l.GlAcctCode = g.GlAcctCode 
	WHERE h.LaborCost <> 0

	DELETE #GlPostLogs WHERE AmountFgn = 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_GlLogDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_GlLogDetail_proc';

