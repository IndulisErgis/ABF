
CREATE VIEW dbo.pvtInQtyTotal
AS

SELECT i.ItemId, l.LocId, ISNULL(q.QtyCmtd, 0) AS cmtd, ISNULL(q.QtyInUse, 0) AS inuse, 
	ISNULL(q.QtyOnOrder, 0) AS onorder, ISNULL(h.QtyOnHand, 0) AS onhand, i.Descr
FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId 
	LEFT JOIN dbo.trav_InItemQtys_view q ON i.ItemId = q.ItemId AND l.LocId = q.LocId 
	LEFT JOIN dbo.trav_InItemOnHand_view h ON i.ItemId = h.ItemId AND l.LocId = h.LocId 
WHERE i.ItemType = 1
UNION ALL
SELECT i.ItemId, l.LocId, ISNULL(q.QtyCmtd, 0) AS cmtd, ISNULL(q.QtyInUse, 0) AS inuse, 
	ISNULL(q.QtyOnOrder, 0) AS onorder, ISNULL(h.QtyOnHand, 0) AS onhand, i.Descr
FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId 
	LEFT JOIN dbo.trav_InItemQtys_view q ON i.ItemId = q.ItemId AND l.LocId = q.LocId 
	LEFT JOIN dbo.trav_InItemOnHandSer_view h ON i.ItemId = h.ItemId AND l.LocId = h.LocId 
WHERE i.ItemType = 2
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInQtyTotal';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInQtyTotal';

