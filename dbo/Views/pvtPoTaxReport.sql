
CREATE VIEW dbo.pvtPoTaxReport
AS

SELECT t.TaxLocID, t.InvcNum, t.TaxClass, t.CurrTaxable, t.CurrNonTaxable, t.CurrTaxAmt, 
	t.CurrRefundable, h.VendorId, t.TransId, t.ExpAcct, c.[Desc]
FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblPoTransInvoiceTax t ON h.TransId = t.TransId 
	INNER JOIN dbo.tblSmTaxClass c ON t.TaxClass = c.TaxClassCode
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoTaxReport';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoTaxReport';

