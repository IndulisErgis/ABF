



--converted from access qryJm-Q013-RmrBySysId - 07/31/18 - ER
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q013_RMRbySysId] 
()
RETURNS TABLE 
AS
RETURN 
(
SELECT 
SS.SysId, 
Sum(SRBS.ActivePrice) AS TotalRmr

FROM 
ALP_tblArAlpSiteSys AS SS
INNER JOIN ALP_tblArAlpSiteRecBillServ AS SRBS
ON SS.SysId = SRBS.SysId

WHERE
SRBS.Status='Active' Or SRBS.Status='New'

GROUP BY SS.SysId
)