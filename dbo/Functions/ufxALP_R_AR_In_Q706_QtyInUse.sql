
/****** Object:  UserDefinedFunction [dbo].[ufxALP_R_AR_In_Q706_QtyInUse]    
	Script Date: 01/17/2013 16:53:13 ******/
CREATE FUNCTION [dbo].[ufxALP_R_AR_In_Q706_QtyInUse]()
RETURNS TABLE 
AS
RETURN 
(
SELECT 
ILoc.ItemId, 
ILoc.LocId, 
IQty.TransType, 
Sum(IQty.Qty) AS QtyInUse

FROM ALP_tblInItemLocation_view AS ILoc
	INNER JOIN tblInQty AS IQty 
	ON (ILoc.AlpLocId = IQty.LocId AND 
		ILoc.AlpItemId = IQty.ItemId)
--MAH modification 12/17/14 - due to poor data integrity, need to also check for TransType (0)
--MAH modification 12/4/14 - added following line:
WHERE IQty.LinkID = 'JM' and IQty.LinkIDSubLine = 1	AND IQty.TransType=0
GROUP BY 
ILoc.ItemId, 
ILoc.LocId, 
IQty.TransType
--MAH modification 12/4/14 - commented out following line
--HAVING IQty.TransType=1



)