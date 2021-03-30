


CREATE Function  [dbo].[ufxALP_R_Jm_R152_Q004_Q005_Q013]
(
	@Startdate Datetime ,
	@Enddate Datetime = null,
	@Market VARCHAR(255)
)	
RETURNS TABLE 
AS
RETURN 
(
--converted from access qryJm-R152-Q004-Q005-Q013 - 7/31/2018 - ER	
SELECT 
MIN(ST.OrderDate) AS FirstDate,
ST.ProjectId, 
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END AS Site, 
MC.MarketCode, 
ST.SalesRepId, 
SYST.SysType, 
SUB.Subdiv, 
Sum(ST.RMRAdded) AS RMR, 
Sum(qry52.JobPrice) AS TotalPrice, 
Sum(ST.BaseInstPrice) AS BasePrice, 
Sum([CsConnectYn]*1) AS Connects,
Case when SUM(IsNull(qry13.TotalRmr,0))>'0' then 'Y' else '' end AS ArBilling, 
Case when qry4.projectId Is null then 'C' else '' end AS OC

FROM  
 ALP_tblArAlpSysType AS SYST
 INNER JOIN (((((((ALP_tblJmSvcTkt AS ST
 INNER JOIN ALP_tblArAlpSiteSys AS SS 
 ON ST.SysId = SS.SysId) 
 INNER JOIN ALP_tblArAlpSite AS ASite
 ON ST.SiteId = ASite.SiteId) 
 INNER JOIN ALP_tblArAlpSubdivision AS SUB 
 ON ASite.SubDivID = SUB.SubdivId) 
 LEFT JOIN ufxALP_R_AR_Jm_Q004_OpenProjIds() AS qry4
 ON ST.ProjectId = qry4.ProjectId) 
 INNER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS qry52
 ON ST.TicketId = qry52.TicketId) 
 INNER JOIN (ALP_tblJmSvcTktProject AS STP
 INNER JOIN ALP_tblJmMarketCode AS MC 
 ON STP.MarketCodeId = MC.MarketCodeId) 
 ON ST.ProjectId = STP.ProjectId) 
 LEFT JOIN ufxALP_R_AR_Jm_Q013_RMRbySysId() AS qry13 
 ON SS.SysId = qry13.SysId) 
 ON SYST.SysTypeId = SS.SysTypeId

WHERE
ST.OrderDate Between @StartDate And @EndDate
AND (@Market = '<ALL>' Or MC.MarketCode = @Market)

GROUP BY 
ST.ProjectId, 
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END, 
MC.MarketCode, 
ST.SalesRepId, 
SYST.SysType, 
SUB.Subdiv, 
Case when qry4.projectId Is null then 'C' else '' end

HAVING 
ST.ProjectId Is Not Null AND SUB.Subdiv Is Not Null
)