
CREATE VIEW dbo.pvtPoOrderDetail
AS

SELECT h.TransId, h.VendorId, h.TransDate, d.QtyOrd, d.ExtCost, d.UnitCost, d.ItemId, d.LocId,
	d.Descr, d.Units, v.Name,
	CASE h.TransType WHEN 1 THEN 'Goods Received' WHEN -1 THEN 'New Return'
		WHEN 2 THEN 'Invoice Received' WHEN -2 THEN 'Debit Memo' WHEN 9 THEN 'New Order' END AS [TransType], 
	CASE WHEN d.LineStatus = 0 THEN 'Open' ELSE 'Completed' END AS [LineStatus]
FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorID 
WHERE h.TransType <> 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoOrderDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoOrderDetail';

