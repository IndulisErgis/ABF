
CREATE VIEW dbo.pvtApDetHist
AS

SELECT h.VendorId, v.Name, d.InvoiceNum, d.PartId, d.WhseId, d.[Desc], d.ExtCost * SIGN(h.TransType) AS ExtCost, 
	CASE WHEN h.TransType > 0 THEN 'Invoice' ELSE 'Debit' END AS [TransType$], h.InvoiceDate, h.PONum
FROM dbo.tblApVendor v INNER JOIN dbo.tblApHistHeader h ON v.VendorID = h.VendorId 
	INNER JOIN dbo.tblApHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransID
WHERE d.EntryNum > 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApDetHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApDetHist';

