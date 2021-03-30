
CREATE VIEW dbo.trav_InItemOnHandLot_view
AS
SELECT ItemId, LocId, LotNum, Sum(Qty - InvoicedQty - RemoveQty) AS QtyOnHand, 
    Sum((Qty - InvoicedQty - RemoveQty) * Cost) AS Cost
FROM dbo.tblInQtyOnHand
GROUP BY ItemId, LocId, LotNum
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemOnHandLot_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemOnHandLot_view';

