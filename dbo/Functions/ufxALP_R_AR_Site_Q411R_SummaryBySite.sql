


CREATE FUNCTION [dbo].[ufxALP_R_AR_Site_Q411R_SummaryBySite] 
(	
@StartDate datetime,
@EndDate datetime,
@Branch varchar(255)
)
RETURNS TABLE 
AS
RETURN 
(
/* from qrySite-Q411R-SummaryBySite To become ALP_R_AR_Site_Q411R_SummaryBySite */
SELECT 
CR.Reason, 
SRBS.CanReasonId, 
SRB.SiteId, 
S.Status, 
Sum(LRMR.RMR) AS SumOfRMR, 
CASE WHEN S.Status='Active' THEN 1 ELSE 0 END AS ActiveCount,
CASE WHEN S.Status='Inactive' THEN 1 ELSE 0 END AS InactiveCount,
CASE WHEN S.Status='Pending' THEN 1 ELSE 0 END AS PendingCount

FROM 
ALP_tblArAlpCancelReason AS CR
INNER JOIN ALP_tblArAlpSite AS S 
INNER JOIN ALP_tblArAlpBranch AS B 
ON S.BranchId = B.BranchId
INNER JOIN ALP_tblArAlpSiteRecBill AS SRB 
ON S.SiteId = SRB.SiteId 
INNER JOIN ALP_tblArAlpSiteRecBillServ AS SRBS
ON SRB.RecBillId = SRBS.RecBillId
ON CR.ReasonId = SRBS.CanReasonId
INNER JOIN ufxALP_R_AR_Site_Q411R_LostRMR(@StartDate,@EndDate) AS LRMR 
ON SRBS.RecBillServId = LRMR.RecBillServId

WHERE
B.Branch = @Branch OR @Branch='<ALL>'
AND SRBS.CanReportDate Between @StartDate And @EndDate
AND SRBS.ServiceID<>'STLC' 
And SRBS.ServiceID<>'CAIL' 
And SRBS.ServiceID<>'ESIL'

GROUP BY
CR.Reason, SRBS.CanReasonId, SRB.SiteId, S.Status


--ORDER BY 
--CR.Reason, SRBS.CanReasonId, SRB.SiteId
)