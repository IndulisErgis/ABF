
CREATE PROCEDURE dbo.trav_InSlowFastMovementSummaryReport_proc
@HistoryPeriod smallint = 12,
@FiscalYear  smallint = 2008,
@SuppressZeroQtyItem  bit = 0,
@ReportUom tinyint = 0 -- 0, Reporting;1, Base;
AS
SET NOCOUNT ON
Set ANSI_WARNINGS OFF
BEGIN TRY

	SELECT l.ItemId,MAX(l.DateLastSale) AS DateLastSale,MAX(l.DateLastPurch) AS DateLastPurch
	INTO #tmpInSlowFastMoveSumSubRpt
	FROM #tmpItemLocationList m INNER JOIN dbo.tblInItemLoc l (NOLOCK) ON m.ItemId = l.ItemId AND m.LocId = l.LocId
	GROUP BY l.ItemId

	SELECT s.ItemId,Sum(s.QtySold-s.QtyRetSold) AS YTDQty,Sum(s.TotSold-s.TotRetSold) AS YTDSales,Sum((s.TotSold-s.TotRetSold)-(s.CostSold-s.CostRetSold)) AS YTDProfit
	INTO #tmpInSlowFastMoveYTDZeroSumRpt
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod <= @HistoryPeriod
    GROUP BY s.ItemId
    HAVING (@SuppressZeroQtyItem = 0 OR Sum(s.QtySold-s.QtyRetSold) <> 0)

	SELECT s.ItemId,Sum(s.QtySold-s.QtyRetSold) AS PTDQty,Sum(s.TotSold-s.TotRetSold) AS PTDSales,Sum((s.TotSold-s.TotRetSold)-(s.CostSold-s.CostRetSold)) AS PTDProfit
	INTO #tmpInSlowFastMovePTDZeroSumSubRpt
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @HistoryPeriod
	GROUP BY s.ItemId
	HAVING (@SuppressZeroQtyItem = 0 OR Sum(s.QtySold-s.QtyRetSold) <> 0)
  
	SELECT i.ItemId,i.Descr,a.AddlDescr,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,
         ts.PTDQty,ts.PTDSales,ts.PTDProfit
	INTO #tmpInSlowFastMovePTDZeroSumRpt
	FROM tblInItem i (NOLOCK)  LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId 
		INNER JOIN #tmpInSlowFastMovePTDZeroSumSubRpt ts ON i.ItemId = ts.ItemId

	SELECT tp.ItemId,tp.Descr,tp.AddlDescr,tp.ProductLineZls,tp.UsrFld1Zls,tp.UsrFld2Zls,
		 ISNULL(tp.PTDQty,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS PTDQty,
         tp.PTDSales,tp.PTDProfit,
		 ISNULL(ty.YTDQty,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS YTDQtyAmt,
		 ISNULL(ty.YTDSales,0) AS YTDSalesAmt,ISNULL(ty.YTDProfit,0) AS YTDProfitAmt, ts.DateLastSale, ts.DateLastPurch,
		 CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,u.Uom) ELSE base.Uom END AS Uom
	FROM #tmpInSlowFastMovePTDZeroSumRpt tp INNER JOIN #tmpInSlowFastMoveYTDZeroSumRpt ty ON tp.ItemId = ty.ItemId
		INNER JOIN #tmpInSlowFastMoveSumSubRpt ts ON ts.ItemId = ty.ItemId
		INNER JOIN dbo.tblInItem i ON i.ItemId = tp.ItemId 
		INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSlowFastMovementSummaryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSlowFastMovementSummaryReport_proc';

