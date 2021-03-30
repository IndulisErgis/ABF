
CREATE VIEW [dbo].[trav_ApVendorActivity_View]
AS
	SELECT v.VendorID, h.PostRun, h.TransId, h.InvoiceNum, EntryNum, [Name], VendorHoldYN, VendorClass, v.DistCode, 
		v.DivisionCode, PriorityCode, v.Status, v.CurrencyID, InvoiceDate, PONum, FiscalYear, 
		GLPeriod, h.WhseId, PartId, PartType, JobId, d.GLAcct
	FROM dbo.tblApHistHeader AS h 
		INNER JOIN dbo.tblApHistDetail AS d ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum
		INNER JOIN dbo.tblApVendor AS v ON v.VendorID = h.VendorId
	 --WHERE ISNULL(d.EntryNum, 0) >= 0 -- Exclude SalesTax/Freight/Misc detail records
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApVendorActivity_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApVendorActivity_View';

