
CREATE VIEW dbo.pvtApTaxHistory
AS

SELECT InvcNum, TaxLocID, TaxClass, TaxAmt, Refundable, Taxable, NonTaxable
FROM dbo.tblApHistInvoiceTax
WHERE Taxable <> 0 OR NonTaxable <> 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApTaxHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApTaxHistory';

