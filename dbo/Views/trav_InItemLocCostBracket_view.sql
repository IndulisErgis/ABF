
CREATE VIEW dbo.trav_InItemLocCostBracket_view
AS
select ItemId,LocId,LotNum,Max(Entrydate) AS InitialDate,Cost,cast(SUM(Qty - InvoicedQty - RemoveQty) as float) AS Qty,
	cast(SUM(Qty - InvoicedQty - RemoveQty)*Cost as float) AS CostExt
FROM dbo.tblinqtyonhand
WHERE (Qty - InvoicedQty - RemoveQty) <> 0
GROUP BY ItemId,LocId,LotNum,EntryID,Cost
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemLocCostBracket_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InItemLocCostBracket_view';

