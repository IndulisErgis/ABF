
CREATE VIEW dbo.trav_SoSaleBlanket_view
AS

SELECT b.BlanketRef, b.BlanketId, b.BlanketType, b.BlanketStatus, b.SoldToId, b.CustPONum, b.Rep1Id, b.Rep2Id, b.ShipToId, b.ShipToRegion, 
	c.CustName, c.ClassId, c.GroupCode, c.AcctType, c.PriceCode, c.DistCode AS CustomerDistCode, 
	c.TerrId, c.CustLevel, c.[Status] AS CustomerStatus, b.CurrencyID
FROM dbo.tblSoSaleBlanket b LEFT JOIN dbo.tblArCust c ON b.SoldToId = c.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoSaleBlanket_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoSaleBlanket_view';

