




CREATE PROCEDURE [dbo].[ALP_R_JM_R157SR_Q006_Q010b]
	@StartDate dateTime,
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;
--Converted from Access qryJM-SR157-Q006-Q010b 12/29 - ER
SELECT 
tech.CosOffset, 
Sum(qry6.LaborCostExt) AS SumOfLaborCostExt

FROM
((ufxALP_R_AR_Jm_Q006_TimeCards() AS qry6
INNER JOIN ALP_tblJmTech AS tech 
ON qry6.[TechID] = tech.[TechId]) 
INNER JOIN ALP_tblJmSvcTkt AS SvcTkt 
ON qry6.[TicketId] = SvcTkt.[TicketId]) 
INNER JOIN ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c(@EndDate) AS qry10b4
ON SvcTkt.[ProjectId] = qry10b4.[ProjectId]

WHERE
(((qry10b4.ProjCompleteDate) 
Between @StartDate 
And @EndDate)
AND ((SvcTkt.ProjectId) Is Not Null))

GROUP BY 
tech.CosOffset

END