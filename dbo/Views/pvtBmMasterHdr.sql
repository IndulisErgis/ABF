
CREATE VIEW dbo.pvtBmMasterHdr
AS

SELECT BmItemID AS 'Assembly ID', BmLocID AS 'Assembly Loc ID', 
	Descr AS 'Description', Uom AS UOM, LaborCost AS 'Labor Cost'
FROM dbo.tblBmBom
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmMasterHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmMasterHdr';

