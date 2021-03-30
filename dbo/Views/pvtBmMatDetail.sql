
CREATE VIEW dbo.pvtBmMatDetail
AS

SELECT b.BmItemID AS 'Assembly ID', b.BmLocID AS 'Assembly Loc ID', d.BmBomID AS 'Bom ID', 
	d.ItemID AS 'Item ID', d.LocID AS 'Loc ID', 
	CASE d.BmDetailType WHEN 1 THEN 'Item' WHEN 2 THEN 'Sub' ELSE 'NA' END AS Type,
	d.Uom AS 'UOM', d.Quantity AS 'Qty', b.LaborCost AS 'Labor Cost'
FROM dbo.tblBmBom b INNER JOIN dbo.tblBmBomDetail d ON b.BmBomID = d.BmBomID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmMatDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmMatDetail';

