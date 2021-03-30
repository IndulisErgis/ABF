
CREATE PROCEDURE dbo.trav_InSlowFastMovementReport_proc
@HistoryPeriod smallint = 12,
@FiscalYear  smallint = 2008,
@SuppressZeroQtyItem  bit = 0,
@ReportUom tinyint = 0 -- 0, Reporting;1, Base;
AS
SET NOCOUNT ON
BEGIN TRY
  
	SELECT s.ItemId,s.LocId,s.QtySold-s.QtyRetSold AS PTDQty,s.TotSold-s.TotRetSold AS PTDSales,(s.TotSold-s.TotRetSold)-(s.CostSold-s.CostRetSold) AS PTDProfit
	INTO #tmpInSlowFastMovePTDZeroDtlSubRpt
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @HistoryPeriod AND (@SuppressZeroQtyItem = 0 OR s.QtySold - s.QtyRetSold <> 0)
        
	SELECT s.ItemId
	INTO #tmpInSlowFastMovePTDZeroItemIds
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @HistoryPeriod
    GROUP BY s.ItemId
    HAVING  (@SuppressZeroQtyItem = 0 OR Sum(s.QtySold-s.QtyRetSold) <> 0)
  
	SELECT s.ItemId,s.LocId,Sum(s.QtySold-s.QtyRetSold) AS YTDQty,Sum(s.TotSold-s.TotRetSold) AS YTDSales,Sum(s.CostSold-s.CostRetSold) AS YTDCostSold
	INTO #tmpInSlowFastMoveYTDZeroDtlSubRpt
	FROM trav_InHistoryByYearPeriodItemLocation_view s (NOLOCK) INNER JOIN #tmpInSlowFastMovePTDZeroItemIds t ON s.ItemId = t.ItemId
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod <= @HistoryPeriod  
	GROUP BY s.ItemId, s.LocId
	HAVING (@SuppressZeroQtyItem = 0 OR Sum(s.QtySold-s.QtyRetSold) <> 0)
  
	SELECT i.ItemId,l.LocId,i.Descr,a.AddlDescr,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,
         l.CostAvg,l.CostLandedLast + l.CostLast AS CostLandedLast,l.DateLastSale,l.DateLastPurch,t.YTDQty,t.YTDSales,t.YTDSales-t.YTDCostSold AS YTDProfit
	INTO #tmpInSlowFastMoveYTDZeroDtlRpt
	FROM #tmpItemLocationList m INNER JOIN dbo.tblInItemLoc l ON m.ItemId = l.ItemId AND m.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
		INNER JOIN #tmpInSlowFastMoveYTDZeroDtlSubRpt t ON l.ItemId = t.ItemId AND l.LocId = t.LocId 
		LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
  
	SELECT i.ItemId,l.LocId,t.PTDQty,t.PTDSales,t.PTDProfit
	INTO #tmpInSlowFastMovePTDZeroDtlRpt
	FROM #tmpItemLocationList m INNER JOIN dbo.tblInItemLoc l ON m.ItemId = l.ItemId AND m.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
		INNER JOIN #tmpInSlowFastMovePTDZeroDtlSubRpt t ON l.ItemId = t.ItemId AND l.LocId = t.LocId
  
	SELECT ty.ItemId,ty.LocId,ty.Descr,ty.AddlDescr,ty.ProductLineZls,ty.UsrFld1Zls,ty.UsrFld2Zls,ty.CostAvg,ty.CostLandedLast,ty.DateLastSale,ty.DateLastPurch,
         ISNULL(ty.YTDQty,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS YTDQty,
		 ty.YTDSales,ty.YTDProfit,
		 ISNULL(tp.PTDQty,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS PTDQtyAmt,
		 ISNULL(tp.PTDSales,0) AS PTDSalesAmt,ISNULL(tp.PTDProfit,0) AS PTDProfitAmt,
		 CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,u.Uom) ELSE base.Uom END AS Uom
	FROM #tmpInSlowFastMoveYTDZeroDtlRpt ty LEFT JOIN  #tmpInSlowFastMovePTDZeroDtlRpt tp ON ty.ItemId = tp.ItemId AND ty.LocID = tp.LocID
		INNER JOIN dbo.tblInItem i ON i.ItemId = ty.ItemId 
		INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSlowFastMovementReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSlowFastMovementReport_proc';

