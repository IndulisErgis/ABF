
Create View dbo.trav_ArSalesRepCommInvc_view
AS

SELECT s.SalesRepID, s.[Name], s.Addr1, s.Addr2, s.City, s.Region, s.Country, s.PostalCode, s.Phone, s.Fax, s.EmplId, 
	s.RunCode, s.EarnCode, s.VendorId, s.Email, s.Internet, c.CustId, c.InvcNum, c.InvcDate, c.Counter, c.CompletedDate,
	c.HoldYn, m.CustName, m.ClassId, m.GroupCode, m.AcctType, m.PriceCode, m.DistCode, m.TerrId, m.CustLevel, m.Status
FROM dbo.tblArSalesRep s INNER JOIN dbo.tblArCommInvc c ON s.SalesRepID = c.SalesRepID 
	LEFT JOIN dbo.tblArCust m ON c.CustId = m.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArSalesRepCommInvc_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArSalesRepCommInvc_view';

