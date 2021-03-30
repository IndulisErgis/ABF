

CREATE Function  [dbo].[ufxALP_R_Jm_R150_Q004_Q005](
	@Branch VARCHAR(255)='<ALL>',
	@Department VARCHAR(255)='<ALL>',
	@Division VARCHAR(255)='<ALL>',
	@Startdate Datetime ,
	@Enddate Datetime = null
)	
RETURNS TABLE 
AS
RETURN 
--converted from access qryJm-R150-Q004-Q005 - 4/7/2015 - ER	
(
SELECT 
ST.SalesRepId, 
MIN(ST.CreateDate) AS FirstDate, 
ST.ProjectId, 
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END AS Site,
MC.MarketCode, 
SYST.SysType, 
Sum(ST.RMRAdded) AS RMR, 
Sum(qry52.JobPrice) AS TotalPrice, 
Sum(ST.BaseInstPrice) AS BasePrice, 
Sum([CsConnectYn]*1) AS Connects, 
Case when qry4.projectId Is null then 'C' else '' end AS OC,
MIN(BR.Branch) AS FirstOfBranch, 
MIN(DEPT.Dept) AS FirstOfDept, 
MIN(DIV.Division) AS FirstDiv

FROM  
ALP_tblArAlpDivision AS DIV
INNER JOIN (((ALP_tblArAlpSysType AS SYST
INNER JOIN ((((((ALP_tblJmSvcTkt AS ST 
INNER JOIN ALP_tblJmSvcTktProject AS STP
ON ST.ProjectId = STP.ProjectId) 
INNER JOIN ALP_tblJmMarketCode AS MC
ON STP.MarketCodeId = MC.MarketCodeId) 
INNER JOIN ALP_tblArAlpSiteSys AS SS
ON ST.SysId = SS.SysId) 
INNER JOIN ALP_tblArAlpSite AS ASite
ON ST.SiteId = ASite.SiteId) 
LEFT JOIN ufxALP_R_AR_Jm_Q004_OpenProjIds() AS qry4 
ON ST.ProjectId = qry4.ProjectId) 
INNER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS qry52 
ON ST.TicketId = qry52.TicketId) 
ON SYST.SysTypeId = SS.SysTypeId) 
INNER JOIN ALP_tblArAlpBranch AS BR
ON ST.BranchId = BR.BranchId) 
INNER JOIN ALP_tblArAlpDept AS DEPT 
ON ST.DeptId = DEPT.DeptId) 
ON DIV.DivisionId = ST.DivId

WHERE
ST.OrderDate Between @StartDate And @EndDate

GROUP BY 
 ST.SalesRepId, 
 ST.ProjectId, 
 ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END, 
 MC.MarketCode, 
 SYST.SysType, 
 Case when qry4.projectId Is null then 'C' else '' end

HAVING 
(@Branch='<ALL>' OR MIN(BR.Branch)=@Branch) 
AND (@Department='<ALL>' OR MIN(DEPT.Dept)=@Department)  
AND (@Division=0 OR MIN(DIV.DivisionId)=@Division) 
)