
CREATE VIEW dbo.pvtInTransactions
AS

SELECT CASE t.TransType	WHEN 11 THEN 'PO New Order'	WHEN 12 THEN 'PO Goods Received'
	WHEN 14 THEN 'AP Invoice' WHEN 15 THEN 'AP Misc. Debit'	WHEN 21 THEN 'SO New Order'
	WHEN 23 THEN 'SO Verified Order' WHEN 24 THEN 'AR Invoice' WHEN 25 THEN 'AR Misc. Credit'
	WHEN 31 THEN 'Adjustment Increase' WHEN 32 THEN 'Adjustment Decrease' END AS [TransType], 
	t.SumYear, t.GlPeriod AS SumPeriod, t.ItemId, i.Descr, t.LocId, t.TransDate, t.Qty, 
	t.PriceUnit, t.CostUnitTrans
FROM dbo.tblInTrans t INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInTransactions';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInTransactions';

