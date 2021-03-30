
CREATE VIEW dbo.trav_BmKitHistoryItemLocation_view
AS
SELECT h.HistSeqNum, h.TransId, h.ItemId, h.LocId, h.TransDate, i.Descr, i.ProductLine, i.SalesCat, 
	i.PriceId, i.TaxClass, h.SumYear, h.GLPeriod
FROM dbo.tblBmKitHistSumm h	LEFT JOIN dbo.tblInItem i ON h.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BmKitHistoryItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BmKitHistoryItemLocation_view';

