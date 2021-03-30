
CREATE VIEW dbo.pvtInLocDetail
AS

SELECT CASE ItemLocStatus WHEN 1 THEN 'Active' WHEN 2 THEN 'Discontinued' WHEN 3 THEN 'Superceded'
		WHEN 4 THEN 'Obsolete'	END AS [Status$],
	ItemId, LocId, DateLastSale, DateLastPurch, CostStd, CostAvg, CostBase, CostLast, CostLast + CostLandedLast AS CostLandedLast 
FROM dbo.tblInItemLoc
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInLocDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInLocDetail';

