/****** Object:  UserDefinedFunction [dbo].[ufxALP_R_AR_In_Q707_QtyOnOrder]    
	Script Date: 01/17/2013 16:51:24 ******/
CREATE FUNCTION [dbo].[ufxALP_R_AR_In_Q707_QtyOnOrder] ()
RETURNS TABLE 
AS
RETURN 
(
SELECT 
ILoc.ItemId, 
ILoc.LocId, 
IQ.TransType, 
Sum(IQ.Qty) AS QtyOnOrder

FROM ALP_tblInItemLocation_view AS ILoc
	INNER JOIN tblInQty AS IQ
	ON (ILoc.LocId = IQ.LocId AND 
		ILoc.ItemId = IQ.ItemId)
	
GROUP BY 
ILoc.ItemId, 
ILoc.LocId, 
IQ.TransType

HAVING IQ.TransType=2

	--ORDER BY tblInItemLoc.ItemId, 
	--tblInItemLoc.LocId
)