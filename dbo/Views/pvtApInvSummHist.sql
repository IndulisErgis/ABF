
CREATE VIEW dbo.pvtApInvSummHist
AS

SELECT h.VendorId, v.Name, case when h.TransType = 1 then 'Invoice' else 'Debit' end as [TransType$], h.FiscalYear, 
	h.GLPeriod, h.InvoiceNum, h.InvoiceDate, h.Subtotal * h.TransType AS Subtotal, h.SalesTax * h.TransType AS SalesTax, 
    h.Freight * h.TransType AS Freight, h.Misc * h.TransType AS Misc
FROM dbo.tblApHistHeader h INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApInvSummHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApInvSummHist';

