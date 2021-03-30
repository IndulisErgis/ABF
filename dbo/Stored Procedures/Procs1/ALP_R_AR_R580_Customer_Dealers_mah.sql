
CREATE PROCEDURE [dbo].[ALP_R_AR_R580_Customer_Dealers_mah] 
(
@CustID varchar(10),
@StartDate dateTime,
@EndDate dateTime
)
AS
BEGIN
SET NOCOUNT ON

SELECT 
AC.CustId, 
AC.CustName,
HH.InvcNum, 
Isnull(HH.AlpAlarmId,'') AS AlpAlarmID,
HH.InvcDate, 
AC.AlpDealerYn, 
HH.AlpSiteID, 
ASite.SiteName + CASE 			
				WHEN ASite.AlpFirstName Is Null 
				THEN ''
				ELSE ', ' + ASite.AlpFirstName END
				AS Site, 

HD.PartId, 
HD.AddnlDesc, 
HD.QtyShipSell, 
HD.UnitPriceSell, 
H.SalesTax

FROM 
	(
	ALP_tblArCust_view AC
	INNER JOIN ALP_ArHistHeaderDetail_view HH
		ON AC.CustId = HH.CustId
	INNER JOIN dbo.ALP_tblArHistHeader_view H
		ON HH.PostRun = H.PostRun AND
		   HH.AlpTransId = H.TransId
	INNER JOIN dbo.tblArHistDetail HD
		ON HH.PostRun = HD.PostRun AND   
           HH.AlpTransID = HD.TransId AND   
           HH.AlpEntryNum = HD.EntryNum
	LEFT JOIN dbo.ALP_tblArAlpSite  ASite 
		ON H.AlpSiteID = ASite.SiteId
	--ALP_tblArCust_view AS AC
	--INNER JOIN ALP_tblArHistHeader_view AS HH 
	--	ON AC.CustId = HH.CustId 
	--INNER JOIN ALP_tblArHistDetail_view AS HD
	--	ON ( 
	--		(HH.TransId = HD.TransID) AND 
	--		(HH.PostRun = HD.PostRun) 
	--		) 
	--LEFT JOIN ALP_tblArAlpSite_view AS ASite 
	--	ON HH.AlpSiteID = ASite.SiteId
)		
WHERE 
AC.CustId=@CustID AND 
(HH.InvcDate Between @StartDate And @EndDate) AND 
AC.AlpDealerYn=1

ORDER BY AC.CustId,HH.InvcNum, HH.AlpAlarmId

END