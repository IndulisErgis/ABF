
Create View dbo.trav_ArCashReceiptCustomer_view
AS
SELECT r.RcptHeaderId, r.DepositID, r.BankID, r.CustId, r.PmtDate, r.GLAcct, r.GLPeriod, r.FiscalYear, r.PmtMethodId, r.CurrencyID AS PmtCurrencyID,
	c.CustName, c.City, c.Region, c.Country, c.PostalCode, c.Phone, c.ClassId, c.SalesRepId1, c.SalesRepId2, 
	c.GroupCode, c.AcctType, c.PriceCode, c.DistCode, c.CurrencyID, c.TerrId, c.CustLevel, c.Status, 
	p.[Desc], p.PmtType
FROM dbo.tblArCashRcptHeader r LEFT JOIN dbo.tblArCust c ON r.CustId = c.CustId 
	INNER JOIN dbo.tblArPmtMethod p ON r.PmtMethodId = p.PmtMethodId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCashReceiptCustomer_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCashReceiptCustomer_view';

