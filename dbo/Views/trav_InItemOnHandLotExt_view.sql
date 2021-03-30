
CREATE VIEW dbo.trav_InItemOnHandLotExt_view
AS
SELECT  ItemId,LocId,LotNum,ExtLocA,ExtLocB,SUM(QtyOnHand) AS QtyOnHand
FROM 
(
SELECT ItemId,LocId,LotNum,NULL AS ExtLocA, NULL AS ExtLocB,
	SUM(Qty - InvoicedQty - RemoveQty) AS QtyOnHand
FROM dbo.tblInQtyOnHand 
GROUP BY ItemId,LocId,LotNum
UNION ALL
SELECT ItemId,LocId,LotNum,ExtLocA,ExtLocB,SUM(Qty) AS QtyOnHand
FROM dbo.tblInQtyOnHand_Ext
GROUP BY ItemId,LocId,LotNum,ExtLocA,ExtLocB 
UNION ALL
SELECT ItemId,LocId,LotNum,NULL AS ExtLocA,NULL AS ExtLocB,-SUM(Qty) AS QtyOnHand
FROM dbo.tblInQtyOnHand_Ext
GROUP BY ItemId,LocId,LotNum,ExtLocA,ExtLocB 
) q
GROUP BY ItemId,LocId,LotNum,ExtLocA,ExtLocB
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemOnHandLotExt_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemOnHandLotExt_view';

