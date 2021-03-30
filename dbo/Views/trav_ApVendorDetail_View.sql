
CREATE VIEW [dbo].[trav_ApVendorDetail_View]
AS
	SELECT v.VendorID, [Name], v.[Status], VendorClass, v.DistCode, v.DivisionCode, PriorityCode, VendorHoldYN, 
		h.PostRun, h.TransId, h.InvoiceNum, InvoiceDate, PONum, d.EntryNum, d.GLAcct,d.WhseId, d.PartId, d.PartType, JobId
	FROM dbo.tblApVendor AS v 
		INNER JOIN dbo.tblApHistHeader AS h ON v.VendorID = h.VendorId
		INNER JOIN dbo.tblApHistDetail AS d ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApVendorDetail_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApVendorDetail_View';

