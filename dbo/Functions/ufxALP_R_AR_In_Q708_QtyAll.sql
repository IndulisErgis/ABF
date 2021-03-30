
CREATE FUNCTION [dbo].[ufxALP_R_AR_In_Q708_QtyAll]()
RETURNS TABLE 
AS
RETURN 
(
SELECT 
IL.ItemId, 
IL.LocId, 
--Replaced UsrFld1 with ALPMFG 01/08/16 - ER   
IsNull(IItem.AlpMFG,'') AS MFG,
IsNull(AV.VendorID,'') AS VendorID,
IsNull(AV.Name,'') AS Name,
IsNull(Q704.QtyOnHand,0) AS OnHand, 
IsNull(Q705.QtyCommitted,0) AS Committed, 
IsNull(Q706.QtyInUse,0) AS InUse, 
IsNull(Q707.QtyOnOrder,0) AS OnOrder, 
IsNull(Q704.QtyOnHand,0)-IsNull(Q706.QtyInUse,0) AS InStock, 
IsNull(Q704.QtyOnHand,0)-IsNull(Q706.QtyInUse,0)-IsNull(Q705.QtyCommitted,0) AS Available, 
IL.CostBase, 
IL.CostStd, 
IL.CostLast, 
IL.CostAvg

FROM 
ALP_tblInItemLocation_view AS IL 
	LEFT JOIN ufxALP_R_AR_In_Q704_QtyOnHand() AS Q704
	ON (IL.AlpItemId = Q704.ItemId AND 
		IL.AlpLocId = Q704.LocId)
	 
	LEFT JOIN ufxALP_R_AR_In_Q706_QtyInUse() AS Q706
	ON (IL.AlpItemId = Q706.ItemId AND 
		--IL.LocId = Q706.LocId)
		IL.AlpLocId = Q706.LocId)  
	
	LEFT JOIN ufxALP_R_AR_In_Q705_QtyCommitted() AS Q705
	ON (IL.AlpItemId = Q705.ItemId AND 
		IL.AlpLocId = Q705.LocId) 
	
	LEFT JOIN ufxALP_R_AR_In_Q707_QtyOnOrder() AS Q707
	ON (IL.AlpItemId = Q707.ItemId AND 
		IL.AlpLocId = Q707.LocId)
		
	LEFT OUTER JOIN tblApVendor AS AV 
		ON IL.DfltVendId=AV.VendorID
	--Refering to ALP_tblInItem_view instead of tblInItem - 01/08/16 - ER
	LEFT OUTER JOIN ALP_tblInItem_view AS IItem
		ON IL.AlpItemId=IItem.ItemId
)