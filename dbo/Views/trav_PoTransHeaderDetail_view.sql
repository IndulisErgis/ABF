
--PET:http://webfront:801/view.php?id=245231

CREATE VIEW dbo.trav_PoTransHeaderDetail_view
AS
	SELECT h.BatchId, h.TransId, h.VendorId, h.OrderedBy, h.TransDate, h.DistCode, h.TransType, 
		CASE h.PrintStatus WHEN 0 THEN 0 ELSE 1 END AS PrintStatus,
		v.Name, v.PriorityCode, v.VendorHoldYN, v.VendorClass, v.DivisionCode, v.DistCode AS VendorDistCode, 
		v.Status, d.EntryNum, d.LocId, d.ItemId, ISNULL(d.ReqShipDate, h.ReqShipDate) AS ReqShipDate, d.GLAcct
		, d.SourceType, d.ProjId, d.InItemYn, d.LineStatus, i.Descr, i.ProductLine, i.SalesCat, i.PriceID, i.TaxClass, ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) AS ExpReceiptDate	
	FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId
		LEFT JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
			LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoTransHeaderDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoTransHeaderDetail_view';

