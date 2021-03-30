
CREATE PROCEDURE dbo.trav_InTrendAnalysisReport_proc
@HistoryPeriodFrom smallint = 12,
@HistoryPeriodThru smallint = 12,
@FiscalYearFrom  smallint = 2008,
@FiscalYearThru  smallint = 2008,
@PrintOption tinyint = 0, -- 0, Sales; 1, Purchases;
@PrintDetail  bit = 0,
@ReportUom tinyint = 1 -- 1, Reporting;2, Base;
AS
SET NOCOUNT ON
BEGIN TRY
  
IF @PrintDetail = 1
	SELECT i.ItemId,s.LocId,s.SumPeriod,i.Descr,ISNULL(i.ProductLine,'') AS ProductLineZls,cast(s.TotSold-s.TotRetSold as float) AS Revenue,
          s.SumYear,
		  CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.Uom,u.Uom) ELSE Base.Uom END AS UomDflt,
		  u.ConvFactor, CASE WHEN @PrintOption = 0 THEN (s.QtySold-s.QtyRetSold)/CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END
		 ELSE (s.QtyPurch-s.QtyRetPurch)/CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END END AS Qty, 
          CASE WHEN @PrintOption = 0 THEN s.CostSold-s.CostRetSold ELSE s.CostPurch-s.CostRetPurch END AS Cost,
          CASE WHEN @PrintOption = 0 THEN (CASE WHEN s.QtySold-s.QtyRetSold = 0 THEN 0 ELSE ((s.CostSold-s.CostRetSold)/(s.QtySold-s.QtyRetSold)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END) ELSE 
          (CASE WHEN s.QtyPurch-s.QtyRetPurch =0 THEN 0 ELSE ((s.CostPurch-s.CostRetPurch)/(s.QtyPurch-s.QtyRetPurch)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END) END AS AvgUnitCost, 
          (CASE WHEN s.QtyPurch-s.QtyRetPurch =0 THEN 0 ELSE ((s.CostPurch-s.CostRetPurch)/(s.QtyPurch-s.QtyRetPurch)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END) AS AvgUnitCostPurchases,
          (CASE WHEN s.QtySold-s.QtyRetSold = 0 THEN 0 ELSE ((s.CostSold-s.CostRetSold)/(s.QtySold-s.QtyRetSold)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END) AS AvgUnitCostSales, 
          CASE WHEN s.QtySold-s.QtyRetSold = 0 THEN 0 ELSE ((s.TotSold-s.TotRetSold)/(s.QtySold-s.QtyRetSold)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END)  END AS AvgUnitPriceSales
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
		INNER JOIN dbo.tblInItem i ON s.ItemId = i.ItemId
        INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
   WHERE s.SumYear*1000 + s.SumPeriod BETWEEN @FiscalYearFrom * 1000 + @HistoryPeriodFrom AND @FiscalYearThru * 1000 + @HistoryPeriodThru
ELSE 
	SELECT i.ItemId,s.LocId,i.Descr,ISNULL(i.ProductLine,'') AS ProductLineZls,
		CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.Uom,u.Uom) ELSE Base.Uom END AS UomDflt,
		SUM(s.TotSold-s.TotRetSold) AS Revenue,
        CASE WHEN @PrintOption = 0 THEN SUM((s.QtySold-s.QtyRetSold) / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) ELSE SUM((s.QtyPurch-s.QtyRetPurch) / CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END AS Qty, 
        CASE WHEN @PrintOption = 0 THEN SUM(s.CostSold-s.CostRetSold) ELSE SUM(s.CostPurch-s.CostRetPurch) END AS Cost,
        CASE WHEN @PrintOption = 0 THEN (CASE WHEN SUM(s.QtySold-s.QtyRetSold) = 0 THEN 0 ELSE (SUM(s.CostSold-s.CostRetSold)/SUM(s.QtySold-s.QtyRetSold)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END) 
			ELSE (CASE WHEN SUM(s.QtyPurch-s.QtyRetPurch) =0 THEN 0 ELSE (SUM(s.CostPurch-s.CostRetPurch)/SUM(s.QtyPurch-s.QtyRetPurch)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END) END AS AvgUnitCost, 
        CASE WHEN SUM(s.QtyPurch-s.QtyRetPurch) =0 THEN 0 ELSE (SUM(s.CostPurch-s.CostRetPurch)/SUM(s.QtyPurch-s.QtyRetPurch)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END AS AvgUnitCostPurchases,
        CASE WHEN SUM(s.QtySold-s.QtyRetSold) = 0 THEN 0 ELSE (SUM(s.CostSold-s.CostRetSold)/SUM(s.QtySold-s.QtyRetSold)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END AS AvgUnitCostSales, 
        CASE WHEN SUM(s.QtySold-s.QtyRetSold) = 0 THEN 0 ELSE (SUM(s.TotSold-s.TotRetSold)/SUM(s.QtySold-s.QtyRetSold)) * (CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) END AS AvgUnitPriceSales
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
		INNER JOIN dbo.tblInItem i ON s.ItemId = i.ItemId
        INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
	WHERE s.SumYear*1000 + s.SumPeriod BETWEEN @FiscalYearFrom * 1000 + @HistoryPeriodFrom AND @FiscalYearThru * 1000 + @HistoryPeriodThru
	GROUP BY i.ItemId,s.LocId,i.Descr,ISNULL(i.ProductLine,''), i.UsrFld1, i.UsrFld2, 
		CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.Uom,u.Uom) ELSE Base.Uom END, 
		CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTrendAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTrendAnalysisReport_proc';

