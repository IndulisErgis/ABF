CREATE PROCEDURE [dbo].[ALP_R_AR_ABF235_LeasedEquipmentCosts]
(
	@StartDate DateTime,
	@EndDate DateTime,
	@MinimumAmt float
)
AS
BEGIN
SET NOCOUNT ON;

SELECT 
ASite.County, 
ASite.PostalCode, 
DETAIL_A.SiteId, 
DETAIL_A.[SysId], 
DETAIL_A.InstallYear, 
DETAIL_A.SysDesc, 
DETAIL_A.ItemId, 
DETAIL_A.[Desc], 
ASite.SiteName, 
ASite.AlpFirstName, 
ASite.Addr1, 
ASite.Addr2, 
ASite.City,
ASite.City + ', ' + ASite.PostalCode AS City_Zip,
DETAIL_A.Cost AS Cost, 
DETAIL_A.InstallDate, 
DETAIL_A.WarrStarts, 
City + ', ' + County + ', ' + PostalCode AS City_County_Zip

FROM ufxABFRpt235_DetailASummary(@StartDate,@EndDate,@MinimumAmt)
	AS DETAIL_SUMMARY
	INNER JOIN ALP_tblArAlpSite_view AS ASite
	INNER JOIN ufxABFRpt235_DetailA(@StartDate,@EndDate) 
		AS DETAIL_A
		ON ASite.SiteId = DETAIL_A.SiteId 
		ON DETAIL_SUMMARY.SiteId = DETAIL_A.SiteId
		AND DETAIL_SUMMARY.SysId = DETAIL_A.SysId

ORDER BY
	ASite.County, 
	ASite.PostalCode, 
	DETAIL_A.SiteId;

END