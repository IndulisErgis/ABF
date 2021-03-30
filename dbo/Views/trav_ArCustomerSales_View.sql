
CREATE VIEW [dbo].[trav_ArCustomerSales_View]
AS
	SELECT CustId, CustName, c.City, c.Region, c.Country, c.PostalCode, c.Phone, c.ClassId, SalesRepId1, SalesRepId2, AcctType, 
		PriceCode, DistCode, GroupCode, CurrencyId, TerrId, CustLevel, [Status], l.[Desc], s.Name
    FROM dbo.tblArCust c LEFT JOIN dbo.tblArCustClass l ON  c.ClassId = l.ClassId
	LEFT JOIN dbo.tblArSalesRep s ON c.SalesRepID1 = s.SalesRepID OR c.SalesRepID2 = s.SalesRepID 
		OR (c.SalesRepID1 = s.SalesRepID AND c.SalesRepID2 = s.SalesRepID)
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCustomerSales_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCustomerSales_View';

