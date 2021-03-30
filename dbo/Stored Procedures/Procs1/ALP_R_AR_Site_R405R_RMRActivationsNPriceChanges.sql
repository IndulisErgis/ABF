

CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R405R_RMRActivationsNPriceChanges]
(
@StartDate datetime,
@EndDate datetime
) 
AS
BEGIN
SET NOCOUNT ON

SELECT 
Q404.NewServiceStart, 
RB.SiteId, 
ASite.SiteName + CASE 
	WHEN ASite.AlpFirstName IS NULL
	THEN '' ELSE (', ' + ASite.AlpFirstName) END AS Site, 
AC.CustId, 
AC.CustName, 
ST.SysType, 
RBS.ServiceID, 
RBS.Status, 
Q404.StartBillDate, 
Q404.NewRMR, 
Q404.PriceChange, 
CASE NewServiceStart
	WHEN 1 THEN NewRMR ELSE PriceChange END AS RMR

FROM 
(((ALP_tblArAlpSite_view AS ASite  
	INNER JOIN ALP_tblArAlpBranch AS B 
		ON ASite.BranchId = B.BranchId) 
	INNER JOIN ((ALP_tblArAlpSiteRecBill AS RB 
	INNER JOIN ALP_tblArCust_view AS AC
		ON RB.CustId = AC.CustId) 
	INNER JOIN ALP_tblArAlpCycle as CY 
		ON RB.BillCycleId = CY.CycleId) 
		ON ASite.SiteId = RB.SiteId) 
	INNER JOIN (ALP_tblArAlpSysType AS ST
	INNER JOIN (ALP_tblArAlpSiteRecBillServ_view AS RBS 
	INNER JOIN ALP_tblArAlpSiteSys_view AS SS
		ON RBS.SysId = SS.SysId) 
		ON ST.SysTypeId = SS.SysTypeId) 
		ON RB.RecBillId = RBS.RecBillId) 
	INNER JOIN ufxALP_R_AR_Site_Q404R_NewRmr(@StartDate,@EndDate) AS Q404
	ON RBS.RecBillServId = Q404.RecBillServId

WHERE 
RBS.Status<>'Cancelled' 
AND 
Q404.StartBillDate Between @StartDate And @EndDate

ORDER BY Q404.NewServiceStart DESC, 
(ASite.SiteName + CASE WHEN ASite.AlpFirstName IS NULL
 THEN '' ELSE (', ' + ASite.AlpFirstName) END)
END