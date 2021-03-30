
CREATE PROCEDURE dbo.trav_InGrossProfitAnalysisReport_proc
@HistoryPeriod smallint = 12,
@FiscalYear  smallint = 2008,
@ProfitPercentFrom  pDecimal = -9999.9999,
@ProfitPercentThru  pDecimal = 9999.9999
AS
SET NOCOUNT ON
BEGIN TRY
	
	SELECT i.ItemId,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,
	 i.Descr,cast(s.CostSold-s.CostRetSold as float) AS TotCost,cast(s.TotSold-s.TotRetSold as float) AS TotPrice,
	cast(s.TotSold-s.TotRetSold-s.CostSold+s.CostRetSold  as float)AS GrossProfit,
	cast(((s.TotSold-s.TotRetSold-s.CostSold+s.CostRetSold)/(CASE WHEN s.TotSold-s.TotRetSold = 0 THEN 1 
	ELSE s.TotSold-s.TotRetSold END))*100 as float) AS GrossProfitPct
	FROM #tmpItemLocationList t 
	INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId 
	INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
	INNER JOIN 
	( SELECT  SUM(CASE WHEN Source BETWEEN 80 AND 84 THEN CostExt ELSE 0 END)  CostSold
		, SUM(CASE WHEN Source BETWEEN 30 AND 32 THEN CostExt ELSE 0 END)  CostRetSold 
		, SUM(CASE WHEN Source BETWEEN 80 AND 84 THEN PriceExt ELSE 0 END)  TotSold
		, SUM(CASE WHEN Source BETWEEN 30 AND 32 THEN PriceExt ELSE 0 END)  TotRetSold
		, SumYear, GlPeriod AS SumPeriod, ItemId, LocId 
	  FROM dbo.tblInHistDetail d	
	  WHERE  d.TransType IN(3,4) AND (Qty <> 0 OR CostExt <> 0 OR PriceExt <> 0)
	  GROUP BY SumYear, GlPeriod, ItemId, LocId
	) s
	ON l.LocId = s.LocId AND l.ItemId = s.ItemId 
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @HistoryPeriod AND ((s.TotSold-s.TotRetSold-s.CostSold+s.CostRetSold)/(CASE WHEN s.TotSold-s.TotRetSold = 0 THEN 1 ELSE s.TotSold-s.TotRetSold END))*100 BETWEEN @ProfitPercentFrom AND @ProfitPercentThru
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InGrossProfitAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InGrossProfitAnalysisReport_proc';

