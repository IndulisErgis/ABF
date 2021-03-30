

CREATE PROCEDURE [dbo].[ALP_R_AR_R171B_TechSchedule] 
( 
	@StartDate datetime 
	,@EndDate datetime
	,@Branch varchar(255)
	,@Dept varchar(10)
	,@Tech varchar(3)
)
AS
BEGIN
SET NOCOUNT ON;
SELECT 
BR.Branch AS BranchName, 
TECH.Tech, 
DEPT.Dept AS DeptName,
TECH.Name AS TechName, 
TC.StartDate,
TC.StartTime,
TC.EndTime,
(TC.EndTime-TC.StartTime) as MinsWorked,
(TC.EndTime-TC.StartTime)/60 as HrsWorked,
(TC.EndTime-TC.StartTime) % 60 AS ModuloHrsWorked,
TICKET.TicketId, 
TICKET.CustId,
ALP_tblArAlpSiteSys.AlarmId, 
TICKET.SiteId, 
CASE 
	WHEN SITE.alpfirstname = SITE.SiteName 
	THEN SiteName + ', ' + alpfirstname 
	ELSE SiteName END AS Site,
SITE.Addr1 AS Addr1,
SITE.Addr2 AS Addr2,		 
SITE.City AS City,		
SITE.Region as Region,	 
SITE.PostalCode,
ALP_tblArAlpRepairPlan.RepPlan AS Replan, 
TICKET.WorkDesc,
--5/6/16 - ER
TICKET.TotalPts,
TICKET.SalesRepId 
	-- all derived time calcs,do in SSRS 
	-- original
	--TimeSerial([StartTime]\60,[StartTime] Mod 60,0) AS FormatStartTime, 
	--ROUND([EndTime]-[StartTime])/60,2) AS Hours, rounds to nearest half hour 
	--(TC.StartTime/60) as StartHour
	--MOD(TC.StartTime,60) AS StartMin OR TC.StartTime-60(INT(StartHour)) As StartMin
	--------------------------------------------------------------
	--TimeSerial ( hour, minute, second ) Access Function
	--TimeSerial (14, 6, 30)would return 2:06:30 PM
	--TimeSerial (20 - 8, 6, 30)would return 12:06:30 PM
	--TimeSerial (8, 6-2, 14)would return 8:04:14 AM
	--TimeSerial (7, -15, 50)would return 6:45:50 AM



FROM ALP_tblJmTimeCard AS TC
	INNER JOIN ALP_tblJmTech AS TECH 
		ON TC.TechID = TECH.TechId 
	LEFT JOIN ALP_tblJmSvcTkt AS TICKET 
		ON TC.TicketId = TICKET.TicketId 
	LEFT JOIN ALP_tblArAlpSite AS SITE
		ON TICKET.SiteId = SITE.SiteId 
	INNER JOIN ALP_tblArAlpDept AS DEPT
		ON TECH.DeptId = DEPT.DeptId 
	INNER JOIN ALP_tblArAlpBranch AS BR
		ON TECH.BranchId = BR.BranchId 
	LEFT JOIN ALP_tblArAlpSiteSys
		ON TICKET.SysId = ALP_tblArAlpSiteSys.SysId
	LEFT JOIN ALP_tblArAlpRepairPlan 
		ON TICKET.RepPlanId = ALP_tblArAlpRepairPlan.RepPlanId
		
WHERE 
(TC.StartDate Between @StartDate And @EndDate) AND
(@Dept = 'ALL' OR DEPT.Dept = @Dept) 
AND (@Tech = 'ALL' OR TECH.Tech = @Tech) 
AND(@Branch = 'ALL' OR BR.Branch = @Branch) 	


ORDER BY 
	BR.Branch 
	,TECH.Tech 
	,DEPT.Dept
	,TC.StartDate
	,TC.StartTime 

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_R_AR_R171B_TechSchedule] TO PUBLIC
    AS [dbo];

