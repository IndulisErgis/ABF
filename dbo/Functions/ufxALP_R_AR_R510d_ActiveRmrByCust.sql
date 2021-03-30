CREATE FUNCTION [dbo].[ufxALP_R_AR_R510d_ActiveRmrByCust]
(	
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	RB.CustId, 
	Sum(RBS.ActivePrice) AS RMR, 
	MIN(RBS.ServiceStartDate) AS StartDate
	
FROM ALP_tblArAlpSiteRecBill_view AS RB
	INNER JOIN ALP_tblArAlpSiteRecBillServ_view AS RBS
		ON RB.RecBillId = RBS.RecBillId

WHERE (RBS.Status)='Active'

GROUP BY RB.CustId

HAVING Sum(RBS.ActivePrice)<>0

);