
CREATE VIEW dbo.trav_PoReceiptVendorItem_view
AS
SELECT h.TransId, h.VendorId, h.OrderedBy, h.TransDate, h.DistCode, h.BatchId, 
	r.ReceiptNum, r.ReceiptDate, l.ReceiptId, v.Name, v.PriorityCode, v.VendorHoldYN, v.VendorClass,
	v.DivisionCode, v.Status, i.Descr, i.ProductLine, 
	i.SalesCat, i.PriceID, i.TaxClass, d.ItemId, d.LocId, d.InItemYn, d.ReqShipDate, d.GLAcct, d.SourceType, d.ProjId,  ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) AS ExpReceiptDate
FROM dbo.tblPoTransReceipt r INNER JOIN dbo.tblPoTransLotRcpt l ON r.TransId = l.TransId AND r.ReceiptNum = l.RcptNum 
	INNER JOIN dbo.tblPoTransHeader h ON r.TransId = h.TransId 
	INNER JOIN dbo.tblPoTransDetail d ON l.TransId = d.TransId AND l.EntryNum = d.EntryNum
	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
	LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoReceiptVendorItem_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoReceiptVendorItem_view';

