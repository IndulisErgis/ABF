
CREATE VIEW dbo.trav_InTransactionItemLocation_view
AS
SELECT h.TransId, h.TransType, h.BatchId, h.TransDate, h.SumYear, h.GLPeriod, h.ItemId, h.LocId, i.Descr, i.ProductLine, i.SalesCat, i.PriceId, i.TaxClass, l.ABCClass
FROM dbo.tblInTrans h LEFT JOIN dbo.tblInItem i ON h.ItemId = i.ItemId 
	LEFT JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InTransactionItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InTransactionItemLocation_view';

