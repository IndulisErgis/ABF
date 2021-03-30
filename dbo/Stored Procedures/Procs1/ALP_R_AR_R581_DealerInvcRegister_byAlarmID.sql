



CREATE PROCEDURE [dbo].[ALP_R_AR_R581_DealerInvcRegister_byAlarmID]
(
@CustID varchar(10),
@StartDate datetime,
@EndDate datetime
)
AS
BEGIN
SET NOCOUNT ON;
SELECT 
AC.CustId
,AC.CustName
,Isnull(HD.AlpAlarmId,'') AS AlpAlarmID
,HH.InvcNum
,HH.InvcDate
,SiteName +
	CASE 
		WHEN ASite.AlpFirstName IS NULL
		THEN ''
		ELSE ', ' + ASite.AlpFirstName END AS Site
,CASE 
		WHEN HD.EntryNum = -1
		THEN 'SalesTax'
		ELSE HD.PartId END AS PartId
--,HD.PartId
--,HD.QtyShipSell
,CASE WHEN HD.EntryNum = -1 THEN 1 ELSE HD.QtyShipSell END AS QtyShipSell
,CASE
	WHEN HD.EntryNum = -1
	THEN 0
	ELSE HD.UnitPriceSell END AS UnitPriceSell
--,HD.UnitPriceSell
--,HH.SalesTax
,CASE
	WHEN HD.EntryNum = -1
	THEN HH.SalesTax
	ELSE 0 END AS SalesTax
	

FROM (
( ALP_tblArCust_view  AS AC
	INNER JOIN ALP_tblArHistHeader_view AS HH 
		ON AC.CustId = HH.CustId ) 
	INNER JOIN ALP_tblArHistDetail_view AS HD 
		ON (HH.TransId = HD.TransID) AND 			   
		   (HH.PostRun = HD.PostRun)
) 
	LEFT JOIN ALP_tblArAlpSite_view AS ASite 
		ON HH.AlpSiteID = ASite.SiteId

WHERE 
(
	( AC.CustId=@CustID) AND 
	(HH.InvcDate Between @StartDate And @EndDate) AND 
	(AC.AlpDealerYn=1)
	--AND HD.EntryNum <> -1
)

ORDER BY AC.CustId, HD.AlpAlarmId, HH.InvcNum 

END