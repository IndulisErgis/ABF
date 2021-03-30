
-- =============================================
-- from ufxJm_Q021_ActualHrsNAllocPts_Q019_Q020, outputs ActualHrs and AllocPts
-- =============================================
CREATE FUNCTION [dbo].[ufxJm_Q020_ActualHrsAndAllocPtsByJobAndTech] 
(	
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
DEPT.Dept,
Sum(TC.Points) AS AllocPts,
-- Sum(Round( ((EndTime-StartTime)/60), 2 ) ) AS ActualHrs 
SUM( ((EndTime-StartTime)/60) + ((EndTime-StartTime) % 60) /60.00) AS ActualHrs

FROM 
ALP_tblJmTimeCard AS TC 
INNER JOIN ALP_tblJmTech AS TECH
	ON TC.TechID = TECH.TechId 
INNER JOIN ALP_tblArAlpDept AS DEPT 
	ON TECH.DeptId = DEPT.DeptId

WHERE TC.TicketId Is Not Null and TC.TicketId <>0

GROUP BY 
TC.TicketId, 
TECH.Tech,
TECH.TechId, 
DEPT.Dept
--,
--TC.EndTime,
--TC.StartTime


--HAVING tblJmTimeCard.TicketId Is Not Null
--ORDER BY TC.TicketId
)