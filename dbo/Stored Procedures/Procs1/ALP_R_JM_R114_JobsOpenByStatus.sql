





CREATE PROCEDURE [dbo].[ALP_R_JM_R114_JobsOpenByStatus]
(
@Branch VARCHAR(255)='<ALL>',
@Department VARCHAR(255)='<ALL>'
) 
AS
BEGIN
SET NOCOUNT ON
--converted from access qryJM-R114-Q039-Q040 - 3/25/2015 - ER

SELECT 
BR.Branch, 
DEPT.Dept, 
ST.SiteId, 
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END AS Site,  
ASite.Addr1 + ' ' + ASite.Addr2 AS Address, 
ST.TicketId, 
ST.ProjectId, 
ST.Status, 
IsNull((CONVERT(VARCHAR(15),TECH.Tech)),'Not Assigned') AS LTech,
ISNULL(qry39.MaxSchDate,(ISNULL(ST.PrefDate, ST.OrderDate))) AS StatusDate,
ST.OrderDate AS Ordered, 
SS.SysDesc, 
WC.WorkCode, 
CONVERT(VARCHAR(MAX),ST.WorkDesc) AS WorkDesc, 
qry40.OldestDate

FROM 
((ALP_tblArAlpBranch AS BR
INNER JOIN (ALP_tblJmTech AS Tech
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
ON BR.BranchId = ST.BranchId) 
LEFT JOIN ufxALP_R_JM_Q039_MaxTimeCardDate() AS qry39
ON ST.TicketId = qry39.TicketId) 
INNER JOIN ufxALP_R_JM_Q040_OpenJobsOldestDate() AS qry40 
ON (ASite.SiteId = qry40.SiteId) 
AND (ST.Status = qry40.Status)

WHERE 
(@Branch='<ALL>' OR BR.Branch=@Branch)AND
(@Department='<ALL>' OR DEPT.Dept=@Department)

GROUP BY
BR.Branch, 
DEPT.Dept, 
ST.SiteId,
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END,  
ASite.Addr1 + ' ' + ASite.Addr2, 
ST.TicketId,
ST.ProjectId, 
ST.Status, 
IsNull((CONVERT(VARCHAR(15),TECH.Tech)),'Not Assigned'), 
ISNULL(qry39.MaxSchDate,(ISNULL(ST.PrefDate, ST.OrderDate))),
ST.OrderDate, 
SS.SysDesc, 
WC.WorkCode, 
CONVERT(VARCHAR(MAX),ST.WorkDesc), 
qry40.OldestDate

ORDER BY 
 BR.Branch, DEPT.Dept
 
END