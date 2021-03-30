CREATE FUNCTION [dbo].[ufxABFRpt235_DetailASummary]
	(
	@StartDate DateTime,
	@EndDate DateTime,
	@MinimumAmt float
	)
RETURNS TABLE 
AS
RETURN 

SELECT 
	SY.SiteId, 
	SY.SysId, 
	Sum(UnitCost*Qty) AS Cost	
	
FROM 
	ALP_tblArAlpSiteSysItem_view AS SI
		INNER JOIN ALP_tblArAlpSiteSys_view AS SY
		ON SI.SysId = SY.SysId

WHERE SY.InstallDate Between @StartDate And @EndDate 
	AND 
		SI.WarrStarts<=InstallDate AND 
		SI.LeaseYN<>0 AND 
		SI.RemoveYN=0

GROUP BY 
SY.SiteId, 
SY.SysId

HAVING Sum(UnitCost*Qty)>ISNULL(@MinimumAmt,0)