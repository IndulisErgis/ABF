CREATE VIEW [dbo].[ALP_InItemOnHand_view_mah_TEST_122314]
AS
SELECT ItemId, LocId, Sum(Qty - InvoicedQty - RemoveQty) AS QtyOnHand,
	Sum((Qty - InvoicedQty - RemoveQty) * Cost) AS Cost
FROM dbo.tblInQtyOnHand
GROUP BY ItemId, LocId