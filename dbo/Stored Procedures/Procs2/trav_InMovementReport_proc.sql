
CREATE PROCEDURE dbo.trav_InMovementReport_proc
@HistoryPeriod smallint = 1,
@HistoryPeriodThru smallint = 12, 
@FiscalYear  smallint = 2013,
@FiscalYearThru smallint = 2014,
@ReportUom tinyint = 1, -- 1;Reporting;2;Base
@PrecQty tinyint = 4
--todo, user defined fields
AS
SET NOCOUNT ON
BEGIN TRY
	--PET:http://webfront:801/view.php?id=242013
	--use temp tables to capture the beginning quantity for the items
	CREATE TABLE #InBegBal
	(
		ItemId pItemId  NOT NULL,
		LocId pLocId NOT NULL,
		BeginQty pDecimal NOT NULL,
		BeginCost pDecimal NOT NULL
	)
	CREATE INDEX [IX_InValue] ON #InBegBal(ItemId, LocId)
	
	--use temp table to capture the final quantity and cost totals for the items
	CREATE TABLE #InQtyCostTotals
	(
		ItemId pItemId  NOT NULL,
		LocId pLocId NOT NULL,
		QtySoldDflt pDecimal NOT NULL, 
		CostSoldDflt pDecimal NOT NULL, 
		QtyRetSoldDflt pDecimal NOT NULL, 
		CostRetSoldDflt pDecimal NOT NULL, 
		QtyPurchDflt pDecimal NOT NULL, 
		CostPurchDflt pDecimal NOT NULL, 
		QtyRetPurchDflt pDecimal NOT NULL, 
		CostRetPurchDflt pDecimal NOT NULL, 
		QtyXferInDflt pDecimal NOT NULL, 
		CostXferInDflt pDecimal NOT NULL, 
		QtyXferOutDflt pDecimal NOT NULL, 
		CostXferOutDflt pDecimal NOT NULL, 
		QtyAdjDflt pDecimal NOT NULL, 
		CostAdjDflt pDecimal NOT NULL, 
		QtyMatReqDflt pDecimal NOT NULL, 
		CostMatReqDflt pDecimal NOT NULL, 
		QtyBuiltDflt pDecimal NOT NULL, 
		CostBuiltDflt pDecimal NOT NULL, 
		QtyConsumedDflt pDecimal NOT NULL, 
		CostConsumedDflt pDecimal NOT NULL
	)
	CREATE INDEX [IX_InValue] ON #InQtyCostTotals(ItemId, LocId)

	--build a list of item/loc ids to process
	INSERT INTO #InBegBal (ItemId, LocId, BeginQty, BeginCost)
	SELECT i.ItemId, l.LocId, 0, 0
	FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
	WHERE i.KittedYN = 0

	--capture current serialized quantities
	UPDATE #InBegBal SET #InBegBal.BeginQty = #InBegBal.BeginQty + ISNULL(tmp.Qty, 0), #InBegBal.BeginCost = #InBegBal.BeginCost + ISNULL(tmp.Cost, 0)
	FROM (SELECT s.ItemId, s.LocId, SUM(s.QtyOnHand) Qty, SUM(s.Cost) Cost
		FROM dbo.trav_InItemOnHandSer_view s INNER JOIN #InBegBal b ON s.ItemId = b.ItemId AND s.LocId = b.LocId
		GROUP BY s.ItemId, s.LocId) tmp
	WHERE #InBegBal.ItemId = tmp.ItemId AND #InBegBal.LocId = tmp.LocId

	--capture current non-serialized quantities
	UPDATE #InBegBal SET #InBegBal.BeginQty = #InBegBal.BeginQty + ISNULL(tmp.Qty, 0), #InBegBal.BeginCost = #InBegBal.BeginCost + ISNULL(tmp.Cost, 0)
	FROM (SELECT s.ItemId, s.LocId, SUM(s.QtyOnHand) Qty, SUM(s.Cost) Cost
		FROM dbo.trav_InItemOnHand_view s INNER JOIN #InBegBal b ON s.ItemId = b.ItemId AND s.LocId = b.LocId
		GROUP BY s.ItemId, s.LocId) tmp
	WHERE #InBegBal.ItemId = tmp.ItemId AND #InBegBal.LocId = tmp.LocId
	
	--back out transactions going into Inventory/add in transactions coming out of Inventory
	--	for dates later than the date being processed
	UPDATE #InBegBal SET #InBegBal.BeginQty = #InBegBal.BeginQty + ISNULL(tmp.Qty, 0), #InBegBal.BeginCost = #InBegBal.BeginCost + ISNULL(tmp.Cost, 0)
	FROM (SELECT ItemId, LocId, SUM(Qty) Qty, SUM(Cost) Cost
		FROM (
		--include value of all quantities
		SELECT d.ItemId, d.LocId
			, SUM(CASE WHEN Source < 70 THEN -ROUND(Qty * ConvFactor, @PrecQty) ELSE ROUND(Qty * ConvFactor, @PrecQty) END) Qty
			, SUM(CASE WHEN Source < 70 THEN -CostExt ELSE CostExt END) Cost			
			FROM dbo.tblInHistDetail d INNER JOIN #InBegBal b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
			WHERE ((d.SumYear > @FiscalYear) OR (d.SumPeriod >= @HistoryPeriod AND d.SumYear = @FiscalYear)) AND d.Source NOT IN (200, 201)
			GROUP BY d.ItemId, d.LocId
		UNION ALL
		--back out value of received quantities that have been invoiced (invoiced qty @ received cost)
		SELECT d.ItemId, d.LocId
			, SUM(CASE WHEN d.Source < 70 THEN ROUND(d.Qty * d.ConvFactor, @PrecQty) ELSE -ROUND(d.Qty * d.ConvFactor, @PrecQty) END) Qty
			, SUM(CASE WHEN d.Source < 70 THEN ROUND(d.Qty * r.CostUnit, @PrecQty) ELSE -ROUND(d.Qty * r.CostUnit, @PrecQty) End) Cost
			FROM dbo.tblInHistDetail d INNER JOIN #InBegBal b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
			INNER JOIN dbo.tblInHistDetail r ON d.HistSeqNum_Rcpt = r.HistSeqNum
			WHERE ((d.SumYear > @FiscalYear) OR (d.SumPeriod >= @HistoryPeriod AND d.SumYear = @FiscalYear)) 
			GROUP BY d.ItemId, d.LocId
		--include cogsadj
		UNION ALL
		SELECT d.ItemId, d.LocId, 0 AS Qty, SUM(d.CostExt) AS Cost
			FROM dbo.tblInHistDetail d INNER JOIN #InBegBal b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
			WHERE ((d.SumYear > @FiscalYear) OR (d.SumPeriod >= @HistoryPeriod AND d.SumYear = @FiscalYear)) AND d.Source = 200 	
			GROUP BY d.ItemId, d.LocId
		) InOut
		GROUP BY ItemId, LocId
		) tmp	
	WHERE #InBegBal.ItemId = tmp.ItemId AND #InBegBal.LocId = tmp.LocId

	INSERT INTO #InQtyCostTotals (ItemId, LocId, QtySoldDflt, CostSoldDflt, QtyRetSoldDflt, CostRetSoldDflt
		, QtyPurchDflt, CostPurchDflt, QtyRetPurchDflt, CostRetPurchDflt, QtyXferInDflt, CostXferInDflt
		, QtyXferOutDflt, CostXferOutDflt, QtyAdjDflt, CostAdjDflt, QtyMatReqDflt, CostMatReqDflt
		, QtyBuiltDflt, CostBuiltDflt, QtyConsumedDflt, CostConsumedDflt) 
	SELECT i.ItemId, l.LocId
		, SUM(s.QtySold / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtySoldDflt
		, SUM(s.CostSold + s.TotCogsAdj) AS CostSoldDflt
		, SUM(s.QtyRetSold / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyRetSoldDflt
		, SUM(s.CostRetSold) AS CostRetSoldDflt
		, SUM(s.QtyRcpt / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyPurchDflt
		, SUM(s.ValPurch) AS CostPurchDflt
		, SUM(s.QtyRetRcpt / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyRetPurchDflt
		, SUM(s.ValRetPurch) AS CostRetPurchDflt
		, SUM(s.QtyXferIn / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyXferInDflt
		, SUM(s.CostXferIn) AS CostXferInDflt
		, SUM(s.QtyXferOut / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyXferOutDflt
		, SUM(s.CostXferOut) AS CostXferOutDflt
		, SUM(s.QtyAdj /CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyAdjDflt
		, SUM(s.CostAdj) AS CostAdjDflt
		, SUM(s.QtyMatReq /CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyMatReqDflt
		, SUM(s.CostMatReq) AS CostMatReqDflt
		, SUM(s.QtyBuilt / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyBuiltDflt
		, SUM(s.CostBuilt) AS CostBuiltDflt
		, SUM(s.QtyConsumed / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyConsumedDflt
		, SUM(s.CostConsumed) AS CostConsumedDflt
	FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId  
		INNER JOIN dbo.tblInItem i ON i.ItemId = l.ItemId 
		INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON l.ItemId = s.ItemId AND l.LocId = s.LocId
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
		INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
	WHERE (s.SumYear * 1000 + s.SumPeriod BETWEEN @FiscalYear * 1000 + @HistoryPeriod AND @FiscalYearThru * 1000 + @HistoryPeriodThru) AND (i.KittedYN = 0)
	GROUP BY i.ItemId, l.LocId

	--return the resultset
	SELECT  i.ItemId, l.LocId, ISNULL(i.Productline,'') AS ProductLineZls
		, ISNULL(i.UsrFld1,'') AS UsrFld1Zls, ISNULL(i.UsrFld2,'') AS UsrFld2Zls
		, i.Descr, i.KittedYN, u.ConvFactor, s.QtySoldDflt, s.CostSoldDflt, s.QtyRetSoldDflt, s.CostRetSoldDflt
		, s.QtyPurchDflt, s.CostPurchDflt, s.QtyRetPurchDflt, s.CostRetPurchDflt, s.QtyXferInDflt, s.CostXferInDflt
		, s.QtyXferOutDflt, s.CostXferOutDflt, s.QtyAdjDflt, s.CostAdjDflt, s.QtyMatReqDflt, s.CostMatReqDflt
		, s.QtyBuiltDflt, s.CostBuiltDflt, s.QtyConsumedDflt, s.CostConsumedDflt
		, CAST((b.BeginQty / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END)AS FLOAT) AS QtyBeginBalDflt
		, CAST(b.BeginCost AS FLOAT) AS CostBeginBalDflt
	FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId  
		INNER JOIN dbo.tblInItem i ON i.ItemId = l.ItemId  
		INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		INNER JOIN #InQtyCostTotals s ON l.ItemId = s.ItemId AND l.LocId = s.LocId
		INNER JOIN #InBegBal b ON l.ItemId = b.ItemId AND l.LocId = b.LocId
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
		INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMovementReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMovementReport_proc';

