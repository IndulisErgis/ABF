


CREATE PROCEDURE [dbo].[ALP_R_JM_R157B_JobHrsandPointsbyTechbyProjectDetail]
	@StartDate dateTime,
	@EndDate dateTime,
	@Tech varchar(10)
AS
BEGIN
SET NOCOUNT ON;
--Converted from Access qryJM-R157-Q004-Q015b-Q016-Q021 - 03/31/16 - ER

SELECT 
TECH.Tech, 
Proj.ProjectId, 
SITE.[SiteName],
SvcTkt.TicketID,
TC.TimeCardComment,
CASE WHEN SITE.AlpFirstName Is Null THEN '' ELSE SITE.AlpFirstName END as AlpFirstName,
Proj.[Desc], 
CASE WHEN Qry4.[ProjectId] Is Null THEN 'C' ELSE 'O' END AS OC, 
Qry15.[EstHrs_FromQM]*[FudgeFactorHrs]+[AdjHrs] AS EstProjHours, 
(SvcTkt.TotalPts*[FudgeFactor]+[AdjPoints]) AS ProjPoints, 
Sum(Qry19.ActualHrsByDate) AS ActualHoursForPeriod, 
Sum(Qry19.AllocPtsByDate) AS AllocPointsForPeriod, 
Qry20.ActualHrs AS ActualHours, 
Qry20.AllocPts

FROM
((ufxALP_R_AR_Jm_Q004_OpenProjIds() AS Qry4 
RIGHT JOIN (ALP_tblArAlpSite AS SITE 
INNER JOIN ((ALP_tblJmSvcTkt AS SvcTkt
RIGHT JOIN ALP_tblJmSvcTktProject AS Proj
ON SvcTkt.[ProjectId] = Proj.[ProjectId])) 
ON SITE.[SiteId] = Proj.[SiteId]) 
ON Qry4.[ProjectId] = Proj.[ProjectId])
LEFT JOIN ALP_tblJmTimeCard AS TC
ON SvcTkt.TicketId = TC.TicketId 
LEFT JOIN ufxJm_Q020_ActualHrsAndAllocPtsByJobAndTech() AS Qry20
ON SvcTkt.TicketId = Qry20.TicketId AND TC.TechId = Qry20.TechId)
LEFT JOIN ufxJm_Q019_ActualHrsAndAllocPtsByJobTechDate(@StartDate,@EndDate) AS Qry19 
ON SvcTkt.[TicketId] = Qry19.[TicketId] AND Qry19.Date101 = TC.StartDate AND TC.TechID=Qry19.TechId AND Qry19.MinOfStartTime = TC.StartTime
LEFT JOIN ufxJm_Q015_EstHoursByJob_FromQM() AS Qry15 
ON SvcTkt.[TicketId] = Qry15.[TicketId]
INNER JOIN ALP_tblJmTech AS TECH
ON TC.TechID = TECH.TechId

WHERE  (@Tech like '<ALL>' OR Tech.Tech=@Tech)

GROUP BY TECH.Tech, 
SvcTkt.TicketID,
Proj.ProjectId, 
SITE.[SiteName],
Qry20.ActualHrs,
Qry15.[EstHrs_FromQM]*[FudgeFactorHrs]+[AdjHrs],
(SvcTkt.TotalPts*[FudgeFactor]+[AdjPoints]),
Qry20.AllocPts,
TC.TimeCardComment,
CASE WHEN SITE.AlpFirstName Is Null THEN '' ELSE SITE.AlpFirstName END,
Proj.[Desc],
CASE WHEN Qry4.[ProjectId] Is Null THEN 'C' ELSE 'O' END

HAVING 
(((Sum(Qry19.ActualHrsByDate))>0)) OR (((Sum(Qry19.AllocPtsByDate))>0))

ORDER BY Proj.ProjectId;

END