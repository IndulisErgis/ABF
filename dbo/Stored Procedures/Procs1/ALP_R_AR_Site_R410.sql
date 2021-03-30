



CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R410]
(
 @LessThanAmount DECIMAL
 )	
AS
BEGIN
SET NOCOUNT ON

SELECT
C.AlpCustId,
CASE WHEN ISNULL(C.AlpFirstName,'')='' THEN CustName ELSE CustName + ', ' + C.AlpFirstName END AS CName,
SRB.SiteId,
CASE WHEN MarketType=1 THEN 'RESIDENTIAL' WHEN MarketType=2 THEN 'COMMERCIAL' ELSE 'GOVERNMENT' END AS ResComGov,
SS.SysTypeId,
SS.SysDesc,
SS.AlarmId,
SUM(SRBS.ActivePrice)AS SumOfActivePrice

FROM 
((((ALP_tblArCust_view AS C 
INNER JOIN ALP_tblArAlpSiteRecBill AS SRB
ON C.[CustId] = SRB.[CustId]) 
INNER JOIN ALP_tblArAlpSiteRecBillServ AS SRBS
ON SRB.[RecBillId] = SRBS.[RecBillId]) 
INNER JOIN ALP_tblArAlpSiteSys AS SS
ON SRBS.[SysId] = SS.[SysId]) 
INNER JOIN ALP_tblArAlpSite AS AlpSite 
ON SRB.[SiteId] = AlpSite.[SiteId]) 
INNER JOIN ALP_tblArAlpMarket AS MKT 
ON AlpSite.[MarketId] = MKT.[MarketId]

WHERE
(((SRBS.Status)='active')) 

GROUP BY
C.AlpCustId, 
CASE WHEN ISNULL(C.AlpFirstName,'')='' THEN CustName ELSE CustName + ', ' + C.AlpFirstName END,
SRB.SiteId, 
CASE WHEN MarketType=1 THEN 'RESIDENTIAL' WHEN MarketType=2 THEN 'COMMERCIAL' ELSE 'GOVERNMENT' END, 
SS.SysTypeId, 
SS.SysDesc, 
SS.AlarmId

HAVING (((Sum(SRBS.ActivePrice))<@LessThanAmount And (Sum(SRBS.ActivePrice))<>0));

END