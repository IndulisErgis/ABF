
CREATE VIEW dbo.pvtInQtyDetails
AS

SELECT q.ItemId, q.LocId, i.Descr, q.EntryDate, q.Cost, q.LotNum, 
	(q.Qty - q.InvoicedQty - q.RemoveQty) AS QtyOnHand, 
	(q.Qty - q.InvoicedQty - q.RemoveQty) * q.Cost AS ExtCost
FROM dbo.tblInQtyOnHand q INNER JOIN dbo.tblInItem i ON q.ItemId = i.ItemId
WHERE q.Qty - q.InvoicedQty - q.RemoveQty > 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInQtyDetails';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInQtyDetails';

