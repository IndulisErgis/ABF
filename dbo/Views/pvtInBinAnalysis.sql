
CREATE VIEW dbo.pvtInBinAnalysis
AS

SELECT b.BinNum, b.ItemId, i.Descr, b.LocId, b.LastCountTagNum, b.LastCountUom, b.LastCountDate, b.LastCountQty
FROM dbo.tblInItemLocBin b INNER JOIN dbo.tblInItem i ON b.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInBinAnalysis';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInBinAnalysis';

