
CREATE VIEW dbo.pvtInLotDetail
AS

SELECT TOP 100 PERCENT 	i.ItemId, ld.LotNum, l.LocId, i.Descr, i.UomBase
	, Sum(ISNULL(ld.QtyOnHand, 0)) AS QtyOnHand
	, Sum(ISNULL(ld.QtyCmtd, 0)) AS QtyCmtd
	, Sum(ISNULL(ld.QtyInUse, 0)) AS QtyInUse
	, Sum(ISNULL(ld.QtyOnOrder, 0)) AS QtyOnOrder
FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
	LEFT JOIN (SELECT ItemId, LocId, LotNum, QtyCmtd, QtyInUse, QtyOnOrder, 0.0 QtyOnHand FROM trav_InItemQtysLot_view WHERE LotNum IS NOT NULL
				UNION ALL
				SELECT ItemId, LocId, LotNum, 0.0 QtyCmtd, 0.0 QtyInUse, 0.0 QtyOnOrder, QtyOnHand FROM dbo.trav_InItemOnHandLot_view WHERE LotNum IS NOT NULL
		) ld ON l.ItemId = ld.ItemId And l.LocId = ld.LocId
WHERE i.LottedYn = 1
GROUP BY i.ItemId, l.LocId, ld.LotNum, i.Descr, i.UomBase, ld.LotNum, ld.LotNum
ORDER BY i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInLotDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInLotDetail';

