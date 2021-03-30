
CREATE PROCEDURE [dbo].[ALP_R_AR_R584_DealerStatement_Detail] 
(
@CustID varchar(10)
)
AS
BEGIN
SET NOCOUNT ON;

SELECT 
AC.CustId, 
AC.CustName,

Q002.InvcNum, 
Q002.FirstOfTransDate AS [Date], 
HH.AlpSiteID, 
[SiteName] + 
	CASE
	WHEN ASite.AlpFirstName IS NULL
	THEN ''
	ELSE ', ' + ASite.AlpFirstName END AS Site, 
HD.AlpAlarmId,
HD.PartId,  
Q002.InvcAmt, 

Q002.CreditAmt, 
--HD.QtyShipSell, 
ISNULL(HD.QtyShipSell,0) AS QtyShipSell,
ISNULL(HD.UnitPriceSell,0) AS UnitPriceSell,
ISNULL(HH.SalesTax,0) AS SalesTax

FROM 
ALP_tblArCust_view AS AC 
	INNER JOIN ufxALP_R_AR_R587_Q002_OpenItems_Q001() AS Q002 
		ON AC.CustId = Q002.CustId	
	LEFT JOIN ALP_tblArHistHeader_view AS HH
			  LEFT JOIN ALP_tblArHistDetail_view AS HD 
	       	  ON (HH.PostRun = HD.PostRun AND 
	       		  HH.TransId = HD.TransID)
	LEFT JOIN ALP_tblArAlpSite_view AS ASite 
		ON HH.AlpSiteID = ASite.SiteId 
		ON Q002.InvcNum = HH.InvcNum 		


GROUP BY 
AC.CustId,
ASite.SiteId,
HD.AlpAlarmId,
Q002.InvcNum, 
HH.AlpSiteID,
HD.EntryNum,
Q002.FirstOfTransDate, 
AC.CustName, 
[SiteName] + 
	CASE
	WHEN ASite.AlpFirstName IS NULL
	THEN ''
	ELSE ', ' + ASite.AlpFirstName END, 
AC.AlpDealerYn, 
HD.PartId, 
CASE WHEN HD.AddnlDesc IS Null THEN '' END,
Q002.InvcAmt, 
Q002.CreditAmt, 
HD.QtyShipSell, 
HD.UnitPriceSell, 
HH.SalesTax

HAVING ((@CustID = '<ALL>' AND AC.AlpDealerYn=1) OR (@CustID <> '<ALL>' AND AC.CustId=@CustID AND AC.AlpDealerYn=1))

ORDER BY CustId, InvcNum, AlpAlarmId, HD.PartId 
END