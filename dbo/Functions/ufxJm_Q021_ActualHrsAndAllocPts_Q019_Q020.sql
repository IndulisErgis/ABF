-- =============================================
-- from qryJm-Q021-ActualHoursANdAllocPts-Q019-Q020
-- =============================================
CREATE FUNCTION [dbo].[ufxJm_Q021_ActualHrsAndAllocPts_Q019_Q020] 
(	
@StartDate datetime,
@EndDate datetime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
Q19.Tech, 
Q19.StartDate, 
Q19.DATE101,
Q19.MinOfStartTime, 
Q19.TicketId, 
Q19.Dept, 
Q20.ActualHrs,			-- COL1
Q19.ActualHrsByDate, -- COL2
Q20.AllocPts,			-- COL3
Q19.AllocPtsByDate	-- COL4

FROM ufxJm_Q019_ActualHrsAndAllocPtsByJobTechDate(@StartDate,@EndDate) AS Q19
	INNER JOIN ufxJm_Q020_ActualHrsAndAllocPtsByJobAndTech() AS Q20
	ON Q19.TicketId = Q20.TicketId
		AND Q19.Tech = Q20.Tech
		AND Q19.Dept = Q20.Dept

)