
CREATE VIEW dbo.trav_InItemOnHandSer_view
AS
----Status InUse and ReturnedSale are included, 
--but Traverse does not use status InUse and ReturnedSale.
SELECT ItemId, LocId, SUM(CASE SerNumStatus WHEN 5 THEN 0 ELSE 1 END) AS QtyOnHand,
	SUM(CASE SerNumStatus WHEN 2 THEN 1  WHEN 5 THEN -1 ELSE 0 END) AS QtyInUse,
	SUM(CASE SerNumStatus WHEN 5 THEN 0 ELSE CostUnit END) AS Cost
FROM dbo.tblInItemSer
WHERE SerNumStatus IN (1,2,5,8)
GROUP BY ItemId, LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemOnHandSer_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemOnHandSer_view';

