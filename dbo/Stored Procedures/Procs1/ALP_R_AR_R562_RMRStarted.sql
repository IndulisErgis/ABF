
CREATE PROCEDURE [dbo].[ALP_R_AR_R562_RMRStarted]
(
	@StartDate datetime,
	@EndDate datetime
)
AS
BEGIN
	SET NOCOUNT ON;
SELECT 
AC.CustId, 
SiteName,
ASite.AlpFirstName,
SiteName + CASE ISnull(ASite.AlpFirstName,'') 
	WHEN '' THEN '' ELSE (', ' + ASite.AlpFirstName) END AS Site,
AC.CustName, 
RBS.ServiceStartDate, 
RB.SiteId, 

RBS.ServiceID, 
RBS.ActivePrice, 
RBS.Status

FROM 
(
(ALP_tblArAlpSite_view AS ASite 
INNER JOIN ALP_tblArAlpBranch AS AB 
 ON ASite.BranchId = AB.BranchId) 
INNER JOIN 
(
(ALP_tblArAlpSiteRecBill_view as RB  
INNER JOIN ALP_tblArCust_view AS AC 
ON RB.CustId = AC.CustId) 
INNER JOIN ALP_tblArAlpCycle 
ON RB.BillCycleId = ALP_tblArAlpCycle.CycleId) 
ON ASite.SiteId = RB.SiteId) 
INNER JOIN (ALP_tblArAlpSysType AS SType
INNER JOIN (ALP_tblArAlpSiteRecBillServ_view AS RBS 
INNER JOIN ALP_tblArAlpSiteSys_view AS SS
ON RBS.SysId = SS.SysId) 
ON SType.SysTypeId =SS.SysTypeId) 
ON RB.RecBillId = RBS.RecBillId

WHERE 
RBS.ServiceStartDate Between @StartDate And @EndDate

ORDER BY Site 

END