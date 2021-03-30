
CREATE VIEW dbo.trav_BmBomItemLocation_view
AS
SELECT b.BmBomId, i.ItemId, l.LocId, b.Descr, b.Uom, i.Descr AS ItemDescr, i.ProductLine, 
	i.SalesCat, i.PriceId, i.TaxClass, l.ABCClass, i.ItemType, i.ItemStatus, i.LottedYN,
	i.KittedYN, i.ResaleYN, HMRef, l.ItemLocStatus
FROM dbo.tblBmBom b INNER JOIN dbo.tblInItem i ON b.BmItemId = i.ItemId 
	INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId AND b.BmLocId = l.LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BmBomItemLocation_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BmBomItemLocation_view';

