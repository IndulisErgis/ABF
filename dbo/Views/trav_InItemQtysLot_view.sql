
CREATE VIEW dbo.trav_InItemQtysLot_view
AS
SELECT ItemId,LocId,LotNum,Sum(CASE WHEN TransType=0 THEN Qty ELSE 0 END ) AS QtyCmtd,
	Sum(CASE WHEN TransType=2 THEN Qty ELSE 0 END ) AS QtyOnOrder,
	Sum(CASE WHEN TransType=1 THEN Qty ELSE 0 END ) AS QtyInUse
FROM dbo.tblInQty
GROUP BY ItemId,LocId,LotNum
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemQtysLot_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemQtysLot_view';

