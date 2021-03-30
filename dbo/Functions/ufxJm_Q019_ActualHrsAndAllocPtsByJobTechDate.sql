

-- =============================================
-- from qryJm-Q019-ActualHoursAndAllocPtsByJobTechDate
-- =============================================
CREATE FUNCTION [dbo].[ufxJm_Q019_ActualHrsAndAllocPtsByJobTechDate] 
(	
@StartDate datetime,
@EndDate datetime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
TC.TicketId, 
TECH.Tech, 
--added to join on in R157SP - 4/6/16 - ER
TECH.TechId,
TC.StartDate,
convert(varchar(10),TC.StartDate,101) AS DATE101,
Min(TC.StartTime) AS MinOfStartTime, 
--TC.EndTime,
DEPT.Dept,
Sum(TC.Points) AS AllocPtsByDate, 

	--Sum( ((EndTime-StartTime)/60) ) AS ActualHrsByDate, -- way out
	--Sum(Round(((EndTime-StartTime)/60), 2 ) ) AS ActualHrsByDate1, -- way out
	--SUM((EndTime-StartTime)/60 + ((EndTime-StartTime) % 60) /60.00) as ActualHrsByDate2,
SUM( ((EndTime-StartTime)/60) + ((EndTime-StartTime) % 60) /60.00) AS ActualHrsByDate --SAME RESULT AS 2 ABOVE

FROM 
ALP_tblJmTimeCard AS TC 
INNER JOIN ALP_tblJmTech AS TECH 
ON TC.TechID = TECH.TechId 
INNER JOIN ALP_tblArAlpDept AS DEPT 
ON TECH.DeptId = DEPT.DeptId

WHERE 
TC.StartDate Between @StartDate And @EndDate
AND TC.TicketId Is Not Null -- moved from having
AND TC.TicketId <>0

GROUP BY 
TC.TicketId, 
TECH.Tech, 
TECH.TechId,
TC.StartDate,
DEPT.Dept
--,tc.endtime
--HAVING TC.TicketId Is Not Null

)