
CREATE VIEW dbo.pvtInSumHist
AS

SELECT h.SumYear, h.SumPeriod, h.ItemId, i.Descr, h.LocId, h.QtyPurch, h.QtyRetPurch, h.QtySold, 
	h.QtyRetSold, h.QtyAdj, h.CostPurch, h.CostRetPurch, h.CostSold, h.CostRetSold, h.CostAdj, 
	h.TotSold, h.TotRetSold
FROM dbo.trav_InHistoryByYearPeriodItemLocation_view h INNER JOIN dbo.tblInItem i ON h.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInSumHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInSumHist';

