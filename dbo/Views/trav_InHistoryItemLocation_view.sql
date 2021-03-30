
CREATE VIEW dbo.trav_InHistoryItemLocation_view
AS
SELECT h.HistSeqNum, h.ItemId, h.LocId, h.TransType, h.TransDate, h.GLPeriod, 
	h.SumYear, h.AppId, h.RefId, h.SrceID, h.Source, i.Descr, i.ProductLine, 
	i.SalesCat, i.PriceId, i.TaxClass, l.ABCClass, h.LotNum
FROM dbo.tblInHistDetail h LEFT JOIN dbo.tblInItem i ON h.ItemId = i.ItemId 
	LEFT JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InHistoryItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InHistoryItemLocation_view';

