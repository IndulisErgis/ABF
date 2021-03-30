
CREATE PROCEDURE dbo.trav_PoTransPost_DropShipAdjustment_proc
AS
BEGIN TRY
DECLARE @PrecCurr smallint

	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	INSERT INTO dbo.tblInHistDetail(ItemId, LocId, ItemType, LottedYN, TransType, SumYear, SumPeriod, 
		GLPeriod, AppId, BatchId, TransId, RefId, SrceID, TransDate, Uom, UomBase, ConvFactor, Qty, CostExt, CostStd, 
		PriceExt, CostUnit, PriceUnit, Source, Qty_Invc, CostExt_Invc, DropShipYn, LotNum)
	SELECT d.ItemId, d.LocId, d.ItemType, d.LottedYN, 19, o.FiscalYear, o.GlPeriod, o.GlPeriod, 'PO', h.BatchId,
		h.TransId, o.InvcNum, 'COGS Adj', o.InvcDate, l.UomBase, l.UomBase, 1, 0, 
		SUM(ROUND(ir.Qty * ( i.UnitCost - r.UnitCost), @PrecCurr)), 0, 0, 0, 0, 200, 0, 0, 1, NULL
	FROM #PostTransList b INNER JOIN dbo.tblPoTransHeader h ON b.TransId = h.TransId 
		INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId 
		INNER JOIN dbo.tblPoTransInvoice i ON b.TransId = i.TransId AND d.EntryNum = i.EntryNum 
		INNER JOIN dbo.tblPoTransInvoiceTot o ON i.TransId = o.TransId AND i.InvoiceNum = o.InvcNum
		INNER JOIN dbo.tblPoTransInvc_Rcpt ir ON i.InvoiceID = ir.InvoiceID 
		INNER JOIN dbo.tblPoTransLotRcpt r ON r.ReceiptID = ir.ReceiptID 
		INNER JOIN dbo.tblInItem l ON d.ItemId = l.ItemId
	WHERE h.TransType > 0 AND d.InItemYn = 1 AND d.ItemType = 1 AND i.Status = 0 AND h.DropShipYn = 1 AND d.LinkSeqNum > 0
	GROUP BY h.TransId, d.EntryNum, d.ItemId, d.LocId, o.InvcNum, o.FiscalYear, o.GlPeriod, o.InvcDate, h.BatchId, d.ItemType, d.LottedYN, l.UomBase
	HAVING SUM(ROUND(ir.Qty * ( i.UnitCost - r.UnitCost), @PrecCurr)) <> 0

	INSERT INTO dbo.tblInHistDetail(ItemId, LocId, ItemType, LottedYN, TransType, SumYear, SumPeriod, 
		GLPeriod, AppId, BatchId, TransId, RefId, SrceID, TransDate, Uom, UomBase, ConvFactor, Qty, CostExt, CostStd, 
		PriceExt, CostUnit, PriceUnit, Source, Qty_Invc, CostExt_Invc, DropShipYn, LotNum)
	SELECT d.ItemId, d.LocId, d.ItemType, d.LottedYN, 19, o.FiscalYear, o.GlPeriod, o.GlPeriod, 'PO', h.BatchId,
		h.TransId, o.InvcNum, 'COGS Adj', o.InvcDate, l.UomBase, l.UomBase, 1, 0, 
		SUM(ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)), 0, 0, 0, 0, 200, 0, 0, 1, NULL
	FROM #PostTransList b INNER JOIN dbo.tblPoTransHeader h ON b.TransId = h.TransId 
		INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId 
		INNER JOIN dbo.tblPoTransInvoice i ON b.TransId = i.TransId AND d.EntryNum = i.EntryNum 
		INNER JOIN dbo.tblPoTransInvoiceTot o ON i.TransId = o.TransId AND i.InvoiceNum = o.InvcNum
		INNER JOIN dbo.tblPoTransSer s ON d.TransID = s.TransID AND d.EntryNum = s.EntryNum AND i.InvoiceNum  = s.InvcNum 
		INNER JOIN dbo.tblInItem l ON d.ItemId = l.ItemId
	WHERE h.TransType > 0 AND d.InItemYn = 1 AND d.ItemType = 2 AND i.Status = 0 AND h.DropShipYn = 1 AND d.LinkSeqNum > 0
	GROUP BY h.TransId, d.EntryNum, d.ItemId, d.LocId, o.InvcNum, o.FiscalYear, o.GlPeriod, o.InvcDate, h.BatchId, d.ItemType, d.LottedYN, l.UomBase
	HAVING SUM(ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_DropShipAdjustment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_DropShipAdjustment_proc';

