

CREATE PROCEDURE [dbo].[ALP_R_JM_R111_TimeCardEntries] 
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

--converted from access qryJm-R111 - 4/3/2015 - ER
SELECT 
TECH.Name, 
TC.StartDate, 
TC.StartTime/60 AS Start,
CASE WHEN TCODE.TimeType=0 THEN 'Job' ELSE TCODE.TimeCode END AS CodeType, 
CASE WHEN SvcJobYN='true' THEN 'Service' ELSE '' END AS ServiceTF, 
TC.TicketId, 
(TC.EndTime-TC.StartTime) AS Minutes,
(CONVERT(DECIMAL(10,2),TC.EndTime)-CONVERT(DECIMAL(10,2),TC.StartTime))/60 AS Hours,
TC.Points, 
BR.Branch, 
DEPT.Dept

FROM 
((ALP_tblJmTimeCode AS TCODE
INNER JOIN (ALP_tblJmTimeCard AS TC
INNER JOIN ALP_tblJmTech AS TECH  
ON TC.TechID = TECH.TechId) 
ON TCODE.TimeCodeID = TC.TimeCodeID) 
INNER JOIN ALP_tblArAlpBranch AS BR
ON TECH.BranchId = BR.BranchId ) 
INNER JOIN ALP_tblArAlpDept AS DEPT
ON TECH.DeptId = DEPT.DeptId 
		
WHERE 
((TC.StartDate Between @StartDate And @EndDate) 
AND (@Branch = 'ALL' OR BR.Branch = @Branch) 
AND (@Dept = 'ALL' OR DEPT.Dept = @Dept) 
AND (TC.PayBasedOn='0' Or TC.PayBasedOn='2') 
AND (@Tech = 'ALL' OR TECH.Tech = @Tech))

ORDER BY 
TC.StartDate,
[StartTime]/60

END