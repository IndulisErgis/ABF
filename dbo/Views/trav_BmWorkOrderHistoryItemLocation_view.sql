
CREATE VIEW dbo.trav_BmWorkOrderHistoryItemLocation_view
AS
SELECT h.PostRun, h.TransId, h.ItemId, h.LocId, b.Descr, h.TransDate, 
	i.Descr AS ItemDescr, i.ProductLine, i.SalesCat, i.PriceId, i.TaxClass, 
	l.ABCClass, h.GlYear, h.GLPeriod
FROM dbo.tblBmWorkOrderHist h LEFT JOIN dbo.tblBmBom b ON h.BmBomId = b.BmBomId
	LEFT JOIN dbo.tblInItem i ON h.ItemId = i.ItemId 
	LEFT JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BmWorkOrderHistoryItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BmWorkOrderHistoryItemLocation_view';

