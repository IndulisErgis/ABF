
CREATE VIEW dbo.trav_InHistoryByYearPeriodItemLocation_view
AS
SELECT SumYear, GlPeriod AS SumPeriod, ItemId, LocId
		, SUM(CASE WHEN Source BETWEEN 10 AND 14 THEN Qty ELSE 0 END)  QtyPurch
		, SUM(CASE WHEN Source IN (10,11,12,14) THEN Qty ELSE 0 END)  QtyRcpt
		, SUM(CASE WHEN Source BETWEEN 70 AND 72 THEN Qty ELSE 0 END)  QtyRetRcpt
		, SUM(CASE WHEN Source IN (70,71,72,88) THEN Qty ELSE 0 END)  QtyRetPurch
		, SUM(CASE WHEN Source BETWEEN 80 AND 84 THEN Qty ELSE 0 END)  QtySold
		, SUM(CASE WHEN Source BETWEEN 30 AND 32 THEN Qty ELSE 0 END)  QtyRetSold
		, SUM(CASE WHEN Source IN (75, 87) THEN Qty WHEN Source IN (17, 22) THEN -Qty ELSE 0 END)  QtyMatReq
		, SUM(CASE WHEN Source IN (16,21) THEN Qty ELSE 0 END)  QtyXferIn
		, SUM(CASE WHEN Source IN (74,79) THEN Qty ELSE 0 END)  QtyXferOut
		, SUM(CASE WHEN Source IN (18,33,34) THEN Qty ELSE 0 END)  QtyBuilt
		, SUM(CASE WHEN Source IN (15,20) THEN Qty WHEN Source IN(73,78) THEN -Qty ELSE 0 END)  QtyAdj
		, SUM(CASE WHEN Source IN (76,85,86) THEN Qty ELSE 0 END)  QtyConsumed
		, 0  QtyIssued
		, SUM(CASE WHEN Source BETWEEN 10 AND 14 THEN CostExt ELSE 0 END)  CostPurch
		, SUM(CASE WHEN Source IN (70,71,72,88) THEN CostExt ELSE 0 END)  CostRetPurch
		, SUM(CASE WHEN Source BETWEEN 80 AND 84 THEN CostExt ELSE 0 END)  CostSold
		, SUM(CASE WHEN Source BETWEEN 30 AND 32 THEN CostExt ELSE 0 END)  CostRetSold
		, SUM(CASE WHEN Source IN (75, 87) THEN CostExt WHEN Source IN (17, 22) THEN -CostExt ELSE 0 END)  CostMatReq
		, SUM(CASE WHEN Source IN (16,21) THEN CostExt ELSE 0 END)  CostXferIn
		, SUM(CASE WHEN Source IN (74,79) THEN CostExt ELSE 0 END)  CostXferOut
		, SUM(CASE WHEN Source IN (18,33,34) THEN CostExt ELSE 0 END)  CostBuilt
		, SUM(CASE WHEN Source IN(15,20) THEN CostExt WHEN Source IN (73,78) THEN -CostExt ELSE 0 END)  CostAdj
		, SUM(CASE WHEN Source IN (76,85,86) THEN CostExt ELSE 0 END )  CostConsumed
		, 0  CostIssued
		, SUM(CASE WHEN Source BETWEEN 80 AND 84 THEN PriceExt ELSE 0 END)  TotSold
		, SUM(CASE WHEN Source BETWEEN 30 AND 32 THEN PriceExt ELSE 0 END)  TotRetSold
		, SUM(CASE WHEN Source BETWEEN 10 AND 14 THEN CostExt  ELSE 0 END)  ValPurch  -- IN Value
		, SUM(CASE WHEN Source BETWEEN 70 AND 72 THEN CostExt ELSE 0 END)  ValRetPurch  -- IN Value
		, SUM(CASE WHEN Source = 200 THEN CostExt ELSE 0 END) TotCogsAdj
		, SUM(CASE WHEN Source = 201 THEN CostExt ELSE 0 END) TotPurchPriceVar
FROM 
(
SELECT SumYear, GlPeriod, Source, ItemId, LocId, Qty * Convfactor AS Qty, CostExt, PriceExt
FROM dbo.tblInHistDetail 
UNION ALL 
SELECT a.SumYear, a.GlPeriod, a.Source, a.ItemId, a.LocId, -(a.Qty * a.Convfactor)AS Qty, -(a.Qty * b.CostUnit) AS CostExt, a.PriceExt 
FROM dbo.tblInHistDetail a INNER JOIN dbo.tblInHistDetail b ON a.HistSeqNum_Rcpt = b.HistSeqNum 
) a	
GROUP BY SumYear, GlPeriod, ItemId, LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InHistoryByYearPeriodItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InHistoryByYearPeriodItemLocation_view';

