
CREATE VIEW dbo.pvtInUnitPricing
AS

SELECT u.ItemId, i.Descr, u.Uom, u.LocId, u.BrkId, p.BrkQty, p.BrkAdj, 
	CASE WHEN p.BrkAdjType = 0 THEN 'Amount' WHEN p.BrkAdjType = 1 THEN 'Percent' ELSE '' END AS [BrkAdjType], 
	u.PriceAvg, u.PriceMin, u.PriceList, u.PriceBase
FROM dbo.tblInItemLocUomPrice u INNER JOIN dbo.tblInItem i ON u.ItemId = i.ItemId 
	LEFT JOIN dbo.tblInPriceBreaks p ON u.BrkId = p.BrkId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInUnitPricing';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInUnitPricing';

