CREATE FUNCTION [dbo].[ufxALP_R_AR_In_Q705_QtyCommitted] ()
RETURNS TABLE 
AS
RETURN 
(
SELECT 
ILoc.ItemId, 
ILoc.LocId, 
IQ.TransType, 
Sum(IQ.Qty) AS QtyCommitted

FROM ALP_tblInItemLocation_view AS ILoc
	INNER JOIN tblInQty AS IQ
		ON (ILoc.ItemId = IQ.ItemId AND 
			ILoc.LocId = IQ.LocId)
--MAH modification 12/17/14  - added following line:
WHERE IQ.LinkID = 'JM' and IQ.LinkIDSubLine = 0	AND IQ.TransType=0
GROUP BY 
ILoc.ItemId, 
ILoc.LocId, 
IQ.TransType

)