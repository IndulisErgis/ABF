
CREATE VIEW dbo.pvtSoLocPrice
AS
SELECT LocId, ItemId, CustLevel, Descr
	, case PriceAdjBase
		when 0 then 'No Base'
		when 1 then 'Standard Cost'
		when 2 then 'Base Cost'
		when 3 then 'Average Price'
		when 4 then 'Base Price'
		when 5 then 'List Price'
		when 6 then 'Minimum Price'
		when 7 then 'Calculated Price'
	end as [AdjBase]
	, case when PriceAdjType = 0 then 'Amount' else 'Percent' end as [AdjType]
	, PriceAdjAmt
FROM dbo.tblSoItemLocPrice
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoLocPrice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoLocPrice';

