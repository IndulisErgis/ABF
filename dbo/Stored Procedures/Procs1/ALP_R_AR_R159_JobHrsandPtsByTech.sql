

-- =============================================
-- FROM qryJm-R159-Q021
-- =============================================
CREATE PROCEDURE [dbo].[ALP_R_AR_R159_JobHrsandPtsByTech]
(
@StartDate datetime,
@EndDate datetime,
@Tech varchar(10)
)
AS
BEGIN
SET NOCOUNT ON;

SELECT 
Q21.Tech, 
CONVERT(varchar(10), Q21.StartDate, 101) AS StartDate101, 
Q21.MinOfStartTime, 
SVCTKT.TicketId, 
SVCTKT.ProjectId, 
SVCTKT.SiteId, 
SITE.SiteName,
CASE WHEN SITE.AlpFirstName Is Null THEN '' ELSE SITE.AlpFirstName END as AlpFirstName, 
SITE.Addr1, 
SVCTKT.Status, 
-- CASE WHEN Sum(Q21.ActualHrsByDate)>0 THEN Sum(Q21.ActualHrsByDate)
-- ELSE 0 END AS ActualHoursForPeriod, 
Sum(Q21.ActualHrsByDate) AS ActualHoursForPeriod,
Sum(Q21.AllocPtsByDate) AS AllocPointsForPeriod, 
Sum(Q21.ActualHrs) AS ActualHours, 
Sum(Q21.AllocPts) AS AllocPoints,
TC.TimeCardComment

FROM 
ALP_tblArAlpSite AS SITE
	INNER JOIN ALP_tblJmSvcTkt AS SVCTKT
	INNER JOIN ufxJm_Q021_ActualHrsAndAllocPts_Q019_Q020(@StartDate, @EndDate) AS Q21
		ON SVCTKT.TicketId = Q21.TicketId 
		ON SITE.SiteId = SVCTKT.SiteId
	INNER JOIN ALP_tblJmTech AS TECH
		ON TECH.Tech = Q21.Tech
	INNER JOIN ALP_tblJmTimeCard AS TC
		ON TC.TicketId = Q21.TicketId AND Q21.StartDate = TC.StartDate 
		AND Q21.MinOfStartTime = TC.StartTime AND TC.TechID = TECH.TechId
		
WHERE  (@Tech like '<ALL>' OR Q21.Tech=@Tech)

-- Including these conditions does not change report 3-12-2014
-- AND Q21.ActualHrsByDate>0 OR Q21.AllocPtsByDate>0 

--select ActualHrsByDate from ufxJm_Q021_ActualHrsAndAllocPts_Q019_Q020('11-01-2013','11-30-2013')
--where ActualHrsByDate>0 
--OR 
--select AllocPtsByDate from ufxJm_Q021_ActualHrsAndAllocPts_Q019_Q020('11-01-2013','11-30-2013')
--where AllocPtsByDate>0
--AND (Sum(Q21.AllocPtsByDate)>0 OR Sum(Q21.AllocPtsByDate)>0)
	/*.Net SqlClient Data Provider: Msg 147, Level 15, State 1, 
	Procedure ALP_R_AR_R159_JobHrsandPtsByTech, Line 38
	An aggregate may not appear in the WHERE clause 
	unless it is in a subquery contained in 
	a HAVING clause or a select list, and 
	the column being aggregated is an outer reference.
	*/
GROUP BY 
Q21.tech,
Q21.StartDate, 
Q21.MinOfStartTime, 
SVCTKT.TicketId, 
SVCTKT.ProjectId, 
SVCTKT.SiteId,
SITE.SiteName,
AlpFirstName,
SITE.Addr1, 
SVCTKT.Status,
TC.TimeCardComment
-- removing or using has no effect on the results
--HAVING (Sum(Q21.ActualHrsByDate)>0 OR Sum(Q21.AllocPtsByDate)>0)

-- Sum(Q21.ActualHrsByDate)>0 = SUM(ActualHoursForPeriod)>0
-- OR Sum(Q21.AllocPtsByDate)>0) = SUM(AllocPointsForPeriod)>0
END