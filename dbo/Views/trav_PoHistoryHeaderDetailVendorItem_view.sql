
CREATE VIEW dbo.trav_PoHistoryHeaderDetailVendorItem_view
AS
SELECT h.PostRun, h.TransId, h.VendorId, h.DistCode, v.Name, v.PriorityCode, v.VendorHoldYN, 
	v.VendorClass, v.DivisionCode, v.DistCode AS VendorDistCode, v.Status, 
	d.EntryNum, d.LocId, d.ItemId, d.InItemYn, d.ReqShipDate, d.GLAcct, d.SourceType, d.ProjId, 
	r.ReceiptDate, i.Descr, i.ProductLine, i.SalesCat, i.PriceID, i.TaxClass
FROM dbo.tblPoHistHeader h INNER JOIN dbo.tblPoHistDetail d  ON h.PostRun = d.PostRun AND h.TransId = d.TransID 
	LEFT JOIN 
	(SELECT h.PostRun,h.TransID,d.EntryNum,MIN(h.ReceiptDate) ReceiptDate
	 FROM dbo.tblPoHistReceipt h INNER JOIN dbo.tblPoHistLotRcpt d  

	 ON h.PostRun = d.PostRun AND h.TransId = d.TransId AND h.ReceiptNum = d.RcptNum
	 GROUP BY h.PostRun,h.TransID,d.EntryNum) r 
		ON d.PostRun = r.PostRun AND d.TransId = r.TransId AND d.EntryNum = r.EntryNum 
	LEFT JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
	LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoHistoryHeaderDetailVendorItem_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoHistoryHeaderDetailVendorItem_view';

