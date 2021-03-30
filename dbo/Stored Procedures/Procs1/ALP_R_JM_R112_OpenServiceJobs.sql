






CREATE PROCEDURE [dbo].[ALP_R_JM_R112_OpenServiceJobs]
(
@Date datetime = NULL,
@Branch VARCHAR(255)='<ALL>',
@Status VARCHAR(255)='<ALL>'
) 
AS
BEGIN
SET NOCOUNT ON
--converted from access qryJM-R112-Q005-Q023 - 3/26/2015 - ER

SELECT 
ST.TicketId, 
ST.ProjectId, 
ST.Status, 
ISNULL(TimeCardTech,IsNull((CONVERT(VARCHAR(15),TECH.Tech)),'Not Assigned')) AS LTech, 
DEPT.Dept, 
ST.SiteId, 
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END AS Site,  
ASite.Addr1 + ' ' + ASite.Addr2 AS Address, 
CASE WHEN ST.Status='new' THEN OrderDate WHEN ST.Status='targeted' THEN PrefDate ELSE FirstSchedDate END AS SrvcDate,
SS.SysDesc, 
ST.EstHrs, 
WC.WorkCode, 
CONVERT(VARCHAR(MAX),ST.WorkDesc) AS WorkDesc, 
qry52.JobPrice, 
BR.Branch, 
ST.CreateBy

FROM 
(ALP_tblArAlpBranch AS BR
INNER JOIN (((ALP_tblJmTech AS Tech
RIGHT JOIN (ALP_tblJmWorkCode AS WC
INNER JOIN (((ALP_tblJmSvcTkt AS ST
INNER JOIN ALP_tblArAlpSite AS ASite
ON ST.SiteId = ASite.SiteId) 
INNER JOIN ALP_tblArAlpSiteSys AS SS
ON ST.SysId = SS.SysId) 
INNER JOIN ALP_tblArAlpDept AS DEPT
ON ST.DeptId = DEPT.DeptId) 
ON WC.WorkCodeId = ST.WorkCodeId) 
ON TECH.TechId = ST.LeadTechId) 
INNER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS qry52
ON ST.TicketId = qry52.TicketId) 
LEFT JOIN ufxALP_R_JM_Q023_FirstTech() AS qry23
ON ST.TicketId = qry23.TicketId) 
ON BR.BranchId = ST.BranchId) 
LEFT JOIN ufxALP_R_JM_Q025_FirstSchedDate() AS qry25 
ON ST.TicketId = qry25.TicketId

WHERE 
ST.OrderDate<@Date

GROUP BY
ST.TicketId, 
ST.ProjectId, 
ST.Status, 
ISNULL(TimeCardTech,IsNull((CONVERT(VARCHAR(15),TECH.Tech)),'Not Assigned')), 
DEPT.Dept, 
ST.SiteId, 
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END,  
ASite.Addr1 + ' ' + ASite.Addr2, 
CASE WHEN ST.Status='new' THEN OrderDate WHEN ST.Status='targeted' THEN PrefDate ELSE FirstSchedDate END,
SS.SysDesc, 
ST.EstHrs, 
WC.WorkCode, 
CONVERT(VARCHAR(MAX),ST.WorkDesc), 
qry52.JobPrice, 
BR.Branch, 
ST.CreateBy

HAVING
((ST.ProjectId Is Null 
OR ST.ProjectId='') 
AND (@Status = '<ALL>' OR ST.Status = @Status)
AND (@Branch = '<ALL>' OR BR.Branch = @Branch)
AND (ST.Status<>'closed' AND ST.Status<>'canceled' AND ST.Status<>'completed'))

ORDER BY 
ST.TicketId
 
END