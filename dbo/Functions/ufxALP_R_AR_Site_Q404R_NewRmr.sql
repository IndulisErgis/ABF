CREATE FUNCTION [dbo].[ufxALP_R_AR_Site_Q404R_NewRmr] 
(
@StartDate datetime,
@EndDate datetime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
SRBS.RecBillId, 
SRBS.RecBillServId, 
RBSP.RecBillServPriceId, 
SRBS.ServiceID, 
SRBS.ServiceStartDate, 
CASE 
	WHEN ServiceStartDate >= @StartDate AND ServiceStartDate <= @EndDate
	THEN 1 ELSE 0 END AS NewServiceStart, 
RBSP.StartBillDate, 
RBSP.EndBillDate, 
CASE
	WHEN ServiceStartDate >= @StartDate And ServiceStartDate <= @EndDate
	THEN Price ELSE 0 END AS NewRMR, 
CASE
	WHEN ServiceStartDate >= @StartDate And ServiceStartDate <= @EndDate
	THEN 0 ELSE RMRChange END AS PriceChange, 
SRB.SiteId, 

CASE 
	WHEN (InstallDate >= @StartDate And InstallDate <= @EndDate)
	THEN 1 ELSE 0 END AS NewSystem, 
SS.SysDesc, 
SRBS.Status

FROM ALP_tblArAlpSiteRecBillServPrice_view AS RBSP
		INNER JOIN ALP_tblArAlpSiteRecBillServ_view AS SRBS 
			ON RBSP.RecBillServId = SRBS.RecBillServId 
		INNER JOIN ALP_tblArAlpSiteRecBill_view AS SRB 
			ON SRBS.RecBillId = SRB.RecBillId 
		INNER JOIN ALP_tblArAlpSiteSys_view AS SS 
			ON SRBS.SysId = SS.SysId

WHERE SRBS.ServiceID <>'STLC' And SRBS.ServiceID <>'CAIL' And SRBS.ServiceID <>'ESIL' 
	AND RBSP.StartBillDate >= @StartDate And RBSP.StartBillDate <= @EndDate 
	AND RBSP.EndBillDate <= @EndDate AND SRBS.Status <> 'Cancelled' 
OR 
	SRBS.ServiceID <> 'STLC' And SRBS.ServiceID <> 'CAIL' And SRBS.ServiceID<>'ESIL'
	AND RBSP.StartBillDate >= @StartDate And RBSP.StartBillDate <= @EndDate 
	AND RBSP.EndBillDate Is Null
	AND SRBS.Status<>'Cancelled'

)