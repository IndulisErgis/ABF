
CREATE VIEW [dbo].[trav_ArShipToAddress_view]
AS
	SELECT c.CustId, CustName, ClassId, GroupCode, AcctType, PriceCode, SalesRepId1, SalesRepId2, c.Phone, c.City, CurrencyId, CustLevel, [Status], 
		ShiptoId, ShiptoName, s.DistCode, s.TerrId, s.Region, s.Country, s.PostalCode
	FROM dbo.tblArCust c INNER JOIN dbo.tblArShipTo s ON c.CustId = s.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArShipToAddress_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArShipToAddress_view';

