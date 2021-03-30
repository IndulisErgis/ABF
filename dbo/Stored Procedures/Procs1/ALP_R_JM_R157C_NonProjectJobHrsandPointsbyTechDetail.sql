




CREATE PROCEDURE [dbo].[ALP_R_JM_R157C_NonProjectJobHrsandPointsbyTechDetail]
	@StartDate dateTime,
	@EndDate dateTime,
	@Tech varchar(10)
AS
BEGIN
SET NOCOUNT ON;
--Created from R157B - 04/11/16 - ER

SELECT 
TECH.Tech, 
SITE.[SiteName],
SvcTkt.TicketID,
TC.TimeCardComment,
CASE WHEN SITE.AlpFirstName Is Null THEN '' ELSE SITE.AlpFirstName END as AlpFirstName,
CAST (SvcTkt.WorkDesc AS NVARCHAR(200)) WorkDesc, 
CASE WHEN SvcTkt.Status = 'New' Or SvcTkt.Status='Targeted' Or SvcTkt.Status='Scheduled' THEN 'O' ELSE 'C' END AS OC,
SvcTkt.TotalPts, 
Sum(Qry19.ActualHrsByDate) AS ActualHoursForPeriod, 
Sum(Qry19.AllocPtsByDate) AS AllocPointsForPeriod, 
Qry20.ActualHrs AS ActualHours, 
Qry20.AllocPts

FROM
ALP_tblArAlpSite AS SITE 
INNER JOIN ALP_tblJmSvcTkt AS SvcTkt
ON SITE.[SiteId] = SvcTkt.[SiteId] 
LEFT JOIN ALP_tblJmTimeCard AS TC
ON SvcTkt.TicketId = TC.TicketId 
LEFT JOIN ufxJm_Q020_ActualHrsAndAllocPtsByJobAndTech() AS Qry20
ON SvcTkt.TicketId = Qry20.TicketId AND TC.TechId = Qry20.TechId
LEFT JOIN ufxJm_Q019_ActualHrsAndAllocPtsByJobTechDate(@StartDate,@EndDate) AS Qry19 
ON SvcTkt.[TicketId] = Qry19.[TicketId] AND Qry19.Date101 = TC.StartDate AND TC.TechID=Qry19.TechId AND Qry19.MinOfStartTime = TC.StartTime
INNER JOIN ALP_tblJmTech AS TECH
ON TC.TechID = TECH.TechId

WHERE SvcTkt.ProjectId IS NULL AND(@Tech like '<ALL>' OR Tech.Tech=@Tech)

GROUP BY TECH.Tech, 
SvcTkt.TicketID, 
SITE.[SiteName],
Qry20.ActualHrs,
SvcTkt.TotalPts,
Qry20.AllocPts,
CAST (SvcTkt.WorkDesc AS NVARCHAR(200)),
TC.TimeCardComment,
CASE WHEN SITE.AlpFirstName Is Null THEN '' ELSE SITE.AlpFirstName END,
CASE WHEN SvcTkt.Status = 'New' Or SvcTkt.Status='Targeted' Or SvcTkt.Status='Scheduled' THEN 'O' ELSE 'C' END

HAVING 
(((Sum(Qry19.ActualHrsByDate))>0)) OR (((Sum(Qry19.AllocPtsByDate))>0))

END