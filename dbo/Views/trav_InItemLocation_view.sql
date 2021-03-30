
CREATE VIEW dbo.trav_InItemLocation_view
AS
SELECT i.ItemId, i.Descr, i.SuperId, i.ItemType, i.ItemStatus, i.ProductLine, i.SalesCat, COALESCE(l.DfltPriceId,i.PriceId) AS PriceId, i.TaxClass, 
	i.UomBase, i.UomDflt, i.LottedYN, i.AutoReorderYN, i.KittedYN, i.ResaleYN, i.CostMethodOverride, l.LocId,
	l.ItemLocStatus, l.GLAcctCode, l.ForecastId, l.ABCClass, i.HMRef,l.DfltVendId 
FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemLocation_view';

