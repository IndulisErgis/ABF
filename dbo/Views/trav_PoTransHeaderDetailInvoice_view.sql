
CREATE VIEW dbo.trav_PoTransHeaderDetailInvoice_view
AS
SELECT h.TransId, h.VendorId, d.EntryNum, d.LocId, d.ItemId, d.ReqShipDate, r.InvoiceId,
	r.InvoiceNum, p.InvcDate, p.GlPeriod, p.FiscalYear
FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblPoTransDetail d  ON h.TransId = d.TransID 
	INNER JOIN dbo.tblPoTransInvoice r ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum 
	INNER JOIN dbo.tblPoTransInvoiceTot p ON r.TransID = p.TransId AND r.InvoiceNum = p.InvcNum
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoTransHeaderDetailInvoice_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoTransHeaderDetailInvoice_view';

