CREATE FUNCTION [dbo].[ufxALP_R_AR_Site_Q403R] 
(	
@StartDate datetime,
@EndDate datetime
)
RETURNS TABLE 
AS
RETURN 
(
/* from qrySite-Q403R To become ALP_R_AR_Site_Q403R */
SELECT 
CR.Reason, 
CR.[Desc], 
RBS.CanReportDate, 
DATEPART(month,RBS.CanReportDate) AS CanMonth, 
RBS.ActiveRMR, 
RBS.ServiceID, 
RBSP.Price, 
RBSP.StartBillDate, 
RBSP.EndBillDate

FROM 
ALP_tblArAlpSiteRecBillServ_view AS RBS 
INNER JOIN ALP_tblArAlpCancelReason AS CR
ON RBS.CanReasonId = CR.ReasonId 
LEFT JOIN ALP_tblArAlpSiteRecBillServPrice_view AS RBSP 
ON RBS.RecBillServId = RBSP.RecBillServId

WHERE 
	RBS.CanReportDate Between @StartDate And @EndDate 
	AND RBS.ServiceID <> 'STLC' 
	And RBS.ServiceID <> 'CAIL' 
	And RBS.ServiceID <> 'ESIL' 
	AND RBSP.StartBillDate <= RBS.CanServEndDate 
	AND RBSP.EndBillDate >= RBS.CanServEndDate 
OR (
	RBS.CanReportDate Between @StartDate And @EndDate 
	AND RBS.ServiceID <> 'STLC' 
	And RBS.ServiceID <> 'CAIL' 
	And RBS.ServiceID <> 'ESIL' 
	AND RBSP.StartBillDate <= RBS.CanServEndDate	
	AND RBSP.EndBillDate Is Null
	)
)