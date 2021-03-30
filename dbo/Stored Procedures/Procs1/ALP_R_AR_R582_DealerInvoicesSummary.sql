





CREATE PROCEDURE [dbo].[ALP_R_AR_R582_DealerInvoicesSummary]
(
@CustID varchar(10),
@StartDate datetime,
@EndDate datetime
)
--MAH 11/3/14 - changed views used to capture AlarmID
--MAH 11/4/14 - Changed to allow select for All dealers
--MAH 11/17/14 - fixed the Sales Tax handling
AS
BEGIN
SET NOCOUNT ON;

SELECT 
AC.CustId, 
AC.Attn, 
AC.CustName + 
	CASE
	WHEN AC.AlpFirstName IS Null THEN ''
	WHEN AC.AlpFirstName = '' THEN ''
	ELSE (', ' + AC.AlpFirstName) END
	AS CName,
AC.Addr1 +
	CASE
	WHEN AC.Addr2 is null THEN ''
	WHEN AC.Addr2 = '' THEN ''
	ELSE (', ' + AC.Addr2) END 
	AS CAddress, 
AC.City + ', ' + AC.Region + '  ' + AC.PostalCode AS CityRegionPostal,
CASE 
		WHEN HD.EntryNum = -1
		THEN 'SalesTax'
		ELSE HD.PartId END AS PartId,
Count(CASE 
		WHEN HD.EntryNum = -1
		THEN 'SalesTax' 
		ELSE HD.PartId END) AS CountOfPartId, 
Sum(HD.QtyShipSell) AS SumOfQtyShipSell, 
--Sum(HD.UnitPriceSell) AS SumOfUnitPriceSell, 
Sum(CASE WHEN  HD.EntryNum = -1 THEN 0 ELSE HD.UnitPriceSell END ) AS SumOfUnitPriceSell,
Sum(CASE
		WHEN HD.EntryNum = -1
		THEN UnitPriceSell
		ELSE 0 END) AS SumOfSalesTax
FROM 
	ALP_tblArCust_view AC
	INNER JOIN dbo.ALP_tblArHistHeader_view H
		ON AC.CustId = H.CustId
	--INNER JOIN dbo.tblArHistDetail HD
	--	ON H.PostRun = HD.PostRun AND  
	--	   H.TransID = HD.TransId  
	INNER JOIN ALP_tblArHistDetail_view HD
		 ON HD.PostRun = H.PostRun AND
            HD.TransId = H.TransId
           
--Count(d.PartId) AS CountOfPartId, 
--Sum(d.QtyShipSell) AS SumOfQtyShipSell, 
--Sum(d.UnitPriceSell) AS SumOfUnitPriceSell, 
--Sum(h.SalesTax) AS SumOfSalesTax
--FROM (
--ALP_tblArCust_view 
--INNER JOIN ALP_tblArHistHeader_view AS h
--ON ALP_tblArCust_view.CustId = h.CustId) 
--INNER JOIN ALP_tblArHistDetail_view AS d
--	ON (h.PostRun = d.PostRun) AND 
--(h.TransId = d.TransID)

	--LEFT JOIN dbo.ALP_tblArAlpSite  ASite 
	--	ON H.AlpSiteID = ASite.SiteId
WHERE 
((@CustID = '<ALL>')  OR ((@CustID <> 'ALL>') AND (AC.CustId = @CustID))) 
AND
(H.InvcDate Between @StartDate And @EndDate )
AND AC.AlpDealerYn=1 
--AND HH.AlpAlarmId Is Not Null
GROUP BY 
AC.CustId, 
AC.Attn,
AC.CustName + 
	CASE
	WHEN AC.AlpFirstName IS Null THEN ''
	WHEN AC.AlpFirstName = '' THEN ''
	ELSE (', ' + AC.AlpFirstName) END,
AC.Addr1 +
	CASE
	WHEN AC.Addr2 is null THEN ''
	WHEN AC.Addr2 = '' THEN ''
	ELSE (', ' + AC.Addr2) END, 
AC.City + ', ' + AC.Region + '  ' + AC.PostalCode,
CASE 
		WHEN HD.EntryNum = -1
		THEN 'SalesTax'
		ELSE HD.PartId END

END