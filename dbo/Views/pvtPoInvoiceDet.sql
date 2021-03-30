
CREATE VIEW dbo.pvtPoInvoiceDet
AS

SELECT i.TransID, i.EntryNum, i.InvoiceNum, CASE WHEN i.Status = 0 THEN 'Open' ELSE 'Completed' END AS status, 
	h.VendorId, t.InvcDate AS InvoiceDate, t.GlPeriod, t.FiscalYear, i.Qty, i.UnitCost, i.ExtCost
FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId
	INNER JOIN dbo.tblPoTransInvoice i ON t.TransId = i.TransId AND t.InvcNum = i.InvoiceNum
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoInvoiceDet';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoInvoiceDet';

