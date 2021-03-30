





CREATE PROCEDURE [dbo].[ALP_R_AR_407_RecurbyCustName] 
( 
 @Branch VARCHAR(255)='<ALL>',
 @Market VARCHAR(255)='<ALL>'
)
AS
--converted from qrySite-R407 - 03/13/15 - ER
SELECT 
BR.Branch, 
CASE WHEN MarketType=1 THEN 'RESIDENTIAL' WHEN MarketType=2 THEN 'COMMERCIAL' ELSE 'GOVERNMENT' END AS ResComGov,
MKT.MarketType, 
CustName + CASE ISnull(Cust.AlpFirstName,'') 
	WHEN '' THEN '' ELSE (', ' + Cust.AlpFirstName)END +' ('+Cust.CustId+')' AS Cust, 
SiteName + CASE ISnull(ASite.AlpFirstName,'') 
	WHEN '' THEN '' ELSE (', ' + ASite.AlpFirstName)END
	+' ('+CONVERT(VARCHAR(15),ASite.SiteId)+')'
	AS Site, 
ST.SysType, 
SRB.ItemId, 
SRB.NextBillDate, 
SRBS.ServiceID, 
SRBS.ActivePrice AS RMR, 
Left([Cycle],1) AS Freq, 
SRBS.ActivePrice*ActiveCycleId AS BillAmt

FROM ((ALP_tblArCust_view AS Cust
INNER JOIN ((ALP_tblArAlpSite AS ASite 
INNER JOIN ALP_tblArAlpMarket AS MKT
ON ASite.MarketId = MKT.MarketId) 
INNER JOIN (((ALP_tblArAlpSiteRecBill AS SRB
RIGHT JOIN ALP_tblArAlpSiteRecBillServ AS SRBS
ON SRB.RecBillId = SRBS.RecBillId) 
LEFT JOIN ALP_tblArAlpCycle AS Cycle 
ON SRB.BillCycleId = Cycle.CycleId) 
RIGHT JOIN ALP_tblArAlpSiteSys AS SS 
ON SRBS.SysId = SS.SysId) 
ON ASite.SiteId = SS.SiteId) 
ON Cust.CustId = SS.CustId) 
INNER JOIN ALP_tblArAlpSysType AS ST 
ON SS.SysTypeId = ST.SysTypeId) 
INNER JOIN ALP_tblArAlpBranch AS BR
ON ASite.BranchId = BR.BranchId

WHERE 
(@Branch = '<ALL>' OR BR.Branch = @Branch)
AND (@Market ='<ALL>' OR CONVERT(Varchar(10),MKT.MarketType) = @Market) 
AND (SRBS.Status='Active')