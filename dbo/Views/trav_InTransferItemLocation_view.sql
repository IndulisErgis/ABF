
CREATE VIEW dbo.trav_InTransferItemLocation_view
AS
SELECT h.TransId, h.BatchId, h.XferDate, h.SumYear, h.GLPeriod, h.ItemIdFrom AS ItemId, 
	h.LocIdFrom AS LocId, i.Descr, i.ProductLine, i.SalesCat, i.PriceId, i.TaxClass, l.ABCClass,
	l.ItemLocStatus, i.KittedYN 
FROM dbo.tblInXfers h LEFT JOIN dbo.tblInItem i ON h.ItemIdFrom = i.ItemId 
	LEFT JOIN dbo.tblInItemLoc l ON h.ItemIdFrom = l.ItemId AND h.LocIdFrom = l.LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InTransferItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InTransferItemLocation_view';

