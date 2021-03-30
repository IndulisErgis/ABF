






CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R411R]
(
 @StartDate datetime, 
 @EndDate datetime,
 @Branch varchar(255)
 )	
AS
BEGIN
SET NOCOUNT ON

SELECT
B.Branch,
--Added case for blank market - 8/17/16 - ER
CASE WHEN MarketType=1 THEN 'RESIDENTIAL' WHEN MarketType=2 THEN 'COMMERCIAL' WHEN S.MarketId=0 THEN 'NO MARKET' ELSE 'GOVERNMENT' END AS ResComGov,
--Switched from C.CustId - 12/09/16 - ER
SRBS.CanCustId AS AlpCustId,
--Switched from C.CustName - 12/09/16 - ER
CASE WHEN ISNULL(CanCustFirstName,'')='' THEN CanCustName ELSE CanCustName + ', ' + CanCustFirstName END AS CName,
SRB.SiteId, 
--Switched from S.SiteName - 12/09/16 - ER
CASE WHEN ISNULL(CanSiteFirstName,'')='' THEN ISNULL(CanSiteName,S.Addr1) ELSE CanSiteName + ', ' + CanSiteFirstName END AS CSite,
ST.SysType,
SRB.ItemId, 
SRBS.ServiceID, 
SRBS.Status, 
LRMR.StartBillDate AS FirstOfStartBillDate, 
SRBS.CanReportDate, 
CR.Reason, 
LRMR.RMR, 
SRBS.CanComments, 
SS.AlarmId, 
SRBS.CanReasonId

FROM 
ALP_tblArAlpCancelReason AS CR 
INNER JOIN ALP_tblArAlpSite AS S
INNER JOIN ALP_tblArAlpBranch AS B 
ON S.BranchId = B.BranchId 
INNER JOIN ALP_tblArAlpSiteRecBill AS SRB 
INNER JOIN ALP_tblArCust_view AS C 
ON SRB.CustId = C.AlpCustId 
ON S.SiteId = SRB.SiteId 
INNER JOIN ALP_tblArAlpSiteRecBillServ AS SRBS 
LEFT OUTER JOIN ALP_tblArAlpSiteSys AS SS
ON SRBS.SysID = SS.SysID 
ON SRB.RecBillId = SRBS.RecBillId 
ON CR.ReasonId = SRBS.CanReasonId 
--Changed to LEFT Join to allow blank market entries to appear in report - 8/17/16 - ER
LEFT JOIN ALP_tblArAlpMarket AS M  
ON S.MarketId = M.MarketId 
INNER JOIN ufxALP_R_AR_Site_Q411R_LostRMR(@StartDate,@EndDate) AS LRMR
ON SRBS.RecBillServId = LRMR.RecBillServId
LEFT OUTER JOIN ALP_tblArAlpSysType AS ST 
ON ST.SysTypeId = SS.SysTypeId

WHERE 
--Now filtering in RDL file - 01/21/16 - ER
--B.Branch = @Branch OR @Branch='<ALL>'
SRBS.ServiceID<>'STLC' 
AND SRBS.ServiceID<>'CAIL' 
AND SRBS.ServiceID<>'ESIL' 
AND SRBS.CanReportDate Between @StartDate AND @EndDate


ORDER BY
CSite

END