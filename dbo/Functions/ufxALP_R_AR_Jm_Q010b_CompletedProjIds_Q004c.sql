




CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c]  
(   
	@EndDate dateTime
)  
--converted from access qryJm-Q010b-CompletedProjIds-Q004c - 12/17/14 - ER
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
DISTINCT SvcTkt.ProjectId, 
Max(SvcTkt.CompleteDate) AS ProjCompleteDate, 
Max(SvcTkt.CloseDate) AS ProjCloseDate

FROM
ALP_tblJmSvcTkt AS SvcTkt
LEFT JOIN ufxALP_R_AR_Jm_Q004_OpenProjJobsWIP(@EndDate) AS qry4
ON SvcTkt.[ProjectId] = qry4.[ProjectId]
  
WHERE   
(((qry4.ProjectId) Is Null))

GROUP BY SvcTkt.ProjectId

HAVING SvcTkt.ProjectId IS NOT NULL
  
)