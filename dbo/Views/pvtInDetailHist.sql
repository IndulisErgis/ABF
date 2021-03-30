
CREATE VIEW dbo.pvtInDetailHist
AS

SELECT SumYear, GlPeriod AS SumPeriod, AppId, TransDate, CostExt, PriceExt, Qty, ItemId, LocId,
	CASE TransType WHEN 1 THEN 'Purchase' WHEN 2 THEN 'Purchase Return'	WHEN 3 THEN 'Sales'
		WHEN 4 THEN 'Sales Return' WHEN 5 THEN 'Material Requisition' WHEN 6 THEN 'Transfer In'
		WHEN 7 THEN 'Transfer Out' WHEN 8 THEN 'Build' WHEN 9 THEN 'Adjustment Increase'
		WHEN 10 THEN 'Adjustment Decrease' WHEN 15 THEN 'Material Requisition Return'
		WHEN 16 THEN 'Consumed'	WHEN 17 THEN 'Move In' WHEN 18 THEN 'Move Out'
		WHEN 19 THEN 'COGS Adjustment' WHEN 20 THEN 'Purchase Price Variance'
	END AS [transtype$]
FROM dbo.tblInHistDetail
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInDetailHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtInDetailHist';

