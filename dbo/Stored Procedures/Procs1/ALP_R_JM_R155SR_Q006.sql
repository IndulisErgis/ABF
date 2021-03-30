



CREATE PROCEDURE [dbo].[ALP_R_JM_R155SR_Q006]
	@StartDate dateTime,
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;
--Converted from Access qryJM-SR155-Q006 12/24 - ER
SELECT 
tech.CosOffset, 
Sum(qry6.LaborCostExt) AS SumOfLaborCostExt

FROM 
(ufxALP_R_AR_Jm_Q006_TimeCards() AS qry6
INNER JOIN ALP_tblJmTech AS tech 
ON qry6.[TechID] = tech.[TechId]) 
INNER JOIN ALP_tblJmSvcTkt AS SvcTkt 
ON qry6.[TicketId] = SvcTkt.[TicketId]

WHERE
(((SvcTkt.CompleteDate) 
Between @StartDate 
And @EndDate)
AND ((SvcTkt.ProjectId) 
Is Null Or (SvcTkt.ProjectId)=''))

GROUP BY 
tech.CosOffset

END