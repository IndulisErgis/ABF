CREATE FUNCTION [dbo].[ufxABFRpt235_DetailA]
(
@StartDate DateTime,
@EndDate DateTime
)
RETURNS TABLE 
AS
RETURN
(
SELECT 
	SYS.SiteId, 
	SYS.SysId, 
	SYS.SysDesc, 
	SYSITEM.ItemId, 
	SYSITEM.[Desc], 
	SYSITEM.Qty, 
	UnitCost*Qty AS Cost, 
	SYS.InstallDate, 
	SYSITEM.WarrStarts, 
	SYS.LeaseYN AS LeasedSystemYn, 
	SYSITEM.LeaseYN AS LeasedItemYn, 
	DatePart(yyyy,InstallDate) AS InstallYear
	
FROM ALP_tblArAlpSiteSysItem_view AS SYSITEM
	INNER JOIN ALP_tblArAlpSiteSys_view AS SYS
ON	SYSITEM.SysId = SYS.SysId

WHERE SYS.InstallDate 
	Between @StartDate And @EndDate 
	AND SYSITEM.WarrStarts<=InstallDate 
	AND SYSITEM.LeaseYN<>0 AND SYSITEM.RemoveYN=0
);