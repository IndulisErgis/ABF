
CREATE VIEW dbo.pvtInPhysicalCount
AS

SELECT c.BatchId, c.ProductLine, c.ItemId, i.Descr, c.LocId, NULL AS BinNum, c.QtyFrozen, c.QtyCounted
FROM dbo.tblInPhysCount c INNER JOIN  dbo.tblInItem i ON c.ItemId = i.ItemId 
WHERE i.ItemType = 1
UNION ALL 
SELECT c.BatchId, c.ProductLine, c.ItemId, i.Descr, c.LocId, ExtLocAId AS BinNum, d.QtyFrozen, d.QtyCounted
FROM dbo.tblInPhysCount c INNER JOIN  dbo.tblInItem i ON c.ItemId = i.ItemId 
	INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum 
WHERE i.ItemType = 1
UNION ALL
SELECT c.BatchId, c.ProductLine, c.ItemId, i.Descr, c.LocId, ExtLocAId AS BinNum, ISNULL(d.QtyFrozen,0), ISNULL(d.QtyCounted,0)
FROM dbo.tblInPhysCount c INNER JOIN  dbo.tblInItem i ON c.ItemId = i.ItemId 
	LEFT JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum 
WHERE i.ItemType = 2
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInPhysicalCount';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInPhysicalCount';

