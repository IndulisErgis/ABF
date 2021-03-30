
CREATE VIEW dbo.pvtInSerialNumbers
AS

SELECT s.ItemId, i.Descr, s.SerNum, s.LocId, s.CostUnit, s.PriceUnit, 
	CASE s.SerNumStatus	WHEN 1 THEN 'Available'	WHEN 3 THEN 'Sold'
	WHEN 4 THEN 'Lost' WHEN 6 THEN 'Returned' WHEN 7 THEN 'In-Transit' END AS [SerNumStatus]
FROM dbo.tblInItemSer s INNER JOIN dbo.tblInItem i ON s.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInSerialNumbers';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInSerialNumbers';

