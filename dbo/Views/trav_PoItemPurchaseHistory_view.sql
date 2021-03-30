
CREATE VIEW dbo.trav_PoItemPurchaseHistory_view
AS
SELECT h.VendorId, v.[Name] AS VendorName, h.TransDate AS OrderDate, h.CurrencyId, d.QtyOrd AS Quantity
	, d.UnitCostFgn AS UnitCost, d.LocId, Isnull(d.ReqShipDate, h.ReqShipDate) ReqShipDate, d.ItemId,d.Units,h.ShipVia
FROM dbo.tblPoHistHeader h 
	INNER JOIN dbo.tblPoHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransId
	LEFT JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId
	WHERE h.TransType > 0 
UNION ALL
SELECT  h.VendorId,v.Name,t.ReceiptDate, h.CurrencyId,r.QtyFilled,
	 r.UnitCostFgn,d.LocId,Isnull(d.ReqShipDate, h.ReqShipDate),d.ItemId,d.Units,h.ShipVia
 FROM dbo.tblPoTransHeader h
	INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId
	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId
	INNER JOIN dbo.tblPoTransLotRcpt r ON h.TransId = r.TransId AND d.EntryNum = r.EntryNum
	INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum
    WHERE h.TransType > 0 
UNION ALL
SELECT h.VendorId,v.Name,t.InvcDate, h.CurrencyId,i.Qty,
	i.UnitCostFgn,d.LocId,Isnull(d.ReqShipDate, h.ReqShipDate),d.ItemId,d.Units,h.ShipVia
FROM dbo.tblPoTransHeader h
	INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId
    INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId
	INNER JOIN dbo.tblPoTransInvoice i ON h.TransId = i.TransId AND d.EntryNum = i.EntryNum
	INNER JOIN dbo.tblPoTransInvoiceTot t ON i.TransId = t.TransId AND i.InvoiceNum = t.InvcNum
	WHERE h.TransType > 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoItemPurchaseHistory_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PoItemPurchaseHistory_view';

