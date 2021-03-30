CREATE FUNCTION [dbo].[ufxALP_R_AR_In_Q704_QtyOnHand]()
RETURNS TABLE 
AS
RETURN 
(
SELECT 
QOH.ItemId, 
QOH.LocId, 
IItem.UomDflt, 
Sum([Qty]-[InvoicedQty]-[RemoveQty]) AS QtyOnHand

FROM 
(ALP_tblInItem_view AS IItem 
	INNER JOIN ALP_tblInItemLocation_view AS ILoc	
	ON IItem.ItemId = ILoc.AlpItemId) 
	INNER JOIN tblInQtyOnHand AS QOH
		ON ((ILoc.LocId = QOH.LocId) AND
		   (ILoc.ItemId = QOH.ItemId) )
	
GROUP BY 
QOH.ItemId, 
QOH.LocId, 
IItem.UomDflt

)