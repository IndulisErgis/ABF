





CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q004f_ProjDatesMax]  
(   
	@EndDate dateTime
)  
--converted from access qryJm-004f-ProjDatesMax - 12/17/14 - ER
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
qry4c.ProjectId, 
Max(qry4e.CompDate) AS ProjCompDate, 
Max(qry4e.ClosedDate) AS ProjClosedDate

FROM
ufxALP_R_AR_Jm_Q004_OpenProjJobsWIP(@EndDate) AS qry4c
INNER JOIN ufxALP_R_AR_Jm_Q004E_ProjDates() AS qry4e
ON qry4c.[ProjectId] = qry4e.[ProjectId]
  
GROUP BY qry4c.ProjectId
  
)