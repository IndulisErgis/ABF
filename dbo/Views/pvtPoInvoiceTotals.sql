
CREATE VIEW dbo.pvtPoInvoiceTotals
AS

SELECT InvcDate, InvcNum, TransId, GLPeriod, FiscalYear, CurrTaxable + PostTaxable AS Taxable, 
	CurrNonTaxable + PostNonTaxable AS NonTaxable, CurrSalesTax + PostSalesTax AS SalesTax, 
	CurrFreight + PostFreight AS Freight, CurrDisc + PostDisc AS Disc, CurrPrepaid + PostPrepaid AS Prepaid
FROM dbo.tblPoTransInvoiceTot
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoInvoiceTotals';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoInvoiceTotals';

