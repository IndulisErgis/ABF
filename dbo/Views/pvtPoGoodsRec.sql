
CREATE VIEW dbo.pvtPoGoodsRec
AS

SELECT r.TransID, r.EntryNum, t.ReceiptNum, t.ReceiptDate, t.GlPeriod, t.FiscalYear, d.ItemId, d.LocId, 
	SUM(r.QtyFilled) AS Qty, CASE SUM(r.QtyFilled) WHEN SUM(r.ExtCost) THEN 0 ELSE SUM(r.ExtCost) / SUM(r.QtyFilled) END AS UnitCost, 
	SUM(r.ExtCost) AS ExtCost
FROM dbo.tblPoTransReceipt t INNER JOIN dbo.tblPoTransLotRcpt r ON t.TransId = r.TransId AND t.ReceiptNum = r.RcptNum
	INNER JOIN dbo.tblPoTransDetail d ON r.TransID = d.TransID AND r.EntryNum = d.EntryNum 
GROUP BY r.TransID, r.EntryNum, t.ReceiptNum, t.ReceiptDate, t.GlPeriod, t.FiscalYear, d.ItemId, d.LocId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoGoodsRec';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoGoodsRec';

