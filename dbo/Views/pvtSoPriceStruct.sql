
CREATE  VIEW dbo.pvtSoPriceStruct
AS
SELECT dbo.tblSoPriceStructHeader.PriceId, dbo.tblSoPriceStructHeader.Descr, dbo.tblSoPriceStructDetail.CustLevel
	, dbo.tblSoPriceStructDetail.Descr AS Expr1
	, case dbo.tblSoPriceStructDetail.PriceAdjBase
		when 0 then 'No Base'
		when 1 then 'Standard Cost'
		when 2 then 'Base Cost'
		when 3 then 'Average Price'
		when 4 then 'Base Price'
		when 5 then 'List Price'
		when 6 then 'Minimum Price'
		when 7 then 'Calculated Price'
	end as [PriceAdjBase]
	, case when dbo.tblSoPriceStructDetail.PriceAdjType = 0 then 'Amount' else 'Percent' end as [PriceAdjType]
	, dbo.tblSoPriceStructDetail.PriceAdjAmt
FROM dbo.tblSoPriceStructHeader 
INNER JOIN dbo.tblSoPriceStructDetail ON dbo.tblSoPriceStructHeader.PriceId = dbo.tblSoPriceStructDetail.PriceId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoPriceStruct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoPriceStruct';

