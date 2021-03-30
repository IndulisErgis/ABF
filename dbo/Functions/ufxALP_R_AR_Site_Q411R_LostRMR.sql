

CREATE FUNCTION [dbo].[ufxALP_R_AR_Site_Q411R_LostRMR] 
(	
@StartDate datetime,
@EndDate datetime
)
RETURNS TABLE 
AS
RETURN 
(
/* from qrySite-Q411R-LostRmr To become ALP_R_AR_Site_Q411R_LostRMR */
SELECT 
RB.RecBillId, 
RBSP.RecBillServId, 
RBSP.RecBillServPriceId, 
RBSP.Price AS RMR, 
RBS.CanReportDate, 
RBSP.StartBillDate, 
RBSP.EndBillDate

FROM ALP_tblArAlpSiteRecBill AS RB 
INNER JOIN ALP_tblArAlpSiteRecBillServPrice AS RBSP
INNER JOIN ALP_tblArAlpSiteRecBillServ AS RBS
ON RBSP.RecBillServId = RBS.RecBillServId 
ON RB.RecBillId = RBS.RecBillId

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
	AND RBSP.EndBillDate Is Null)

--ORDER BY RB.RecBillId, RBSP.RecBillServId
)