CREATE PROCEDURE [dbo].[ALP_R_AR_420_RecurbyServiceProviderStatus] 
(
 @StartBillDate DateTime,
 @EndBillDate DateTime,
 @ServiceProvider VARCHAR(255)
)
AS
--created 09/16/15 - ER
--altered 9/26/15 - ER - Removed Status parameter & added Date parameters with WHERE Clause
SELECT 
CustName + CASE ISnull(Cust.AlpFirstName,'') 
	WHEN '' THEN '' ELSE (', ' + Cust.AlpFirstName)END AS Cust, 
Cust.CustId,
SiteName + CASE ISnull(ASite.AlpFirstName,'') 
	WHEN '' THEN '' ELSE (', ' + ASite.AlpFirstName)END AS Site,  
ASite.SiteId, 
SRB.ItemId, 
SRB.NextBillDate, 
SRBS.ServiceID, 
SRBS.[Desc],
Cycle.Cycle,
SS.AlarmId,
SRBS.Status,
SRBSP.Price,
SRBS.ServiceStartDate,
ITEM.AlpMFG,
ISNULL(SRBS.CanServEndDate,SRBS.FinalBillDate)AS CanclExpDate

FROM [dbo].[ALP_tblArAlpSiteRecBill] AS SRB
	INNER JOIN [dbo].[ALP_tblArAlpCycle] AS CYCLE
		ON	CYCLE.CycleId = SRB.BillCycleId
	INNER JOIN [dbo].[ALP_tblArAlpSite] AS ASITE
		ON	SRB.SiteId = ASITE.SiteId
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS SRBS
		ON	SRBS.RecBillId = SRB.RecBillId
	INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS SRBSP
		ON	SRBSP.RecBillServId = SRBS.RecBillServId
	INNER JOIN [dbo].[ALP_tblArCust_view] AS CUST
		ON	SRB.CustId = CUST.CustId
	INNER JOIN [dbo].[ALP_tblArAlpSiteSys] AS SS
		ON	SS.SysId = SRBS.SysId
	INNER JOIN [dbo].[ALP_tblInItem] AS ITEM
		ON SRBS.ServiceID = ITEM.AlpItemId
		
WHERE ServiceStartDate < @EndBillDate AND 
(EndBillDate IS NULL OR EndBillDate Between @StartBillDate and @EndBillDate)AND
(CanServEndDate IS NULL OR CanServEndDate Between @StartBillDate and @EndBillDate)
		
ORDER BY SiteId