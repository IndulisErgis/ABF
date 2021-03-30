
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_InHistory_proc
AS
BEGIN TRY

	--Update location last info
    UPDATE dbo.tblInItemLoc SET DateLastSale = w.TransDate
	FROM dbo.tblInItemLoc l 
	INNER JOIN (
								SELECT MAX(w.TransDate) TransDate,w.ResourceID,w.LocID 
    							FROM #PostTransList t 
									INNER JOIN dbo.tblSvInvoiceHeader h ON t.TransID =h.TransID
									INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransID =d.TransID
									INNER JOIN dbo.tblSvWorkOrderTrans w ON  d.WorkOrderTransID = w.ID 
								WHERE w.QtyUsed <> 0  -- Quantity
									AND w.TransType = 1 -- Part
									AND h.TransType > 0 -- Invoice
								GROUP BY w.ResourceID,w.LocID 
					)w ON l.ItemId = w.ResourceID AND l.LocId = w.LocID 
	WHERE  (l.DateLastSale IS NULL OR w.TransDate > l.DateLastSale)


	UPDATE dbo.tblInQty SET Qty = 0
	FROM #PostTransList t 
	INNER JOIN tblSvInvoiceHeader h ON t.TransID =h.TransID
	INNER JOIN tblSvInvoiceDetail d ON h.TransID =d.TransID
	INNER JOIN dbo.tblSvWorkOrderTrans w ON  d.WorkOrderTransID = w.ID
	INNER JOIN dbo.tblInQty  ON dbo.tblInQty.SeqNum = W.QtySeqNum_Cmtd
	
		
	UPDATE dbo.tblInQty_Ext SET Qty = 0
	FROM #PostTransList t 
	INNER JOIN tblSvInvoiceHeader h ON t.TransID =h.TransID
	INNER JOIN tblSvInvoiceDetail d ON h.TransID =d.TransID
	INNER JOIN dbo.tblSvWorkOrderTransExt w ON  d.WorkOrderTransID = w.ID
	INNER JOIN dbo.tblInQty_Ext  ON dbo.tblInQty_Ext.ExtSeqNum = W.QtySeqNum_Cmtd
		

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT w.HistSeqNum, h.FiscalYear, h.FiscalPeriod, h.InvoiceDate, h.BatchId
	FROM #PostTransList t 
	INNER JOIN tblSvInvoiceHeader h ON t.TransID =h.TransID
	INNER JOIN tblSvInvoiceDetail d ON h.TransID =d.TransID
	INNER JOIN dbo.tblSvWorkOrderTrans w ON  d.WorkOrderTransID = w.ID
	WHERE w.HistSeqNum > 0 AND w.QtyUsed <> 0

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT e.HistSeqNum, h.FiscalYear, h.FiscalPeriod, h.InvoiceDate, h.BatchId
	FROM #PostTransList t
		INNER JOIN tblSvInvoiceHeader h ON t.TransID =h.TransID
		INNER JOIN tblSvInvoiceDetail d ON h.TransID =d.TransID
		INNER JOIN dbo.tblSvWorkOrderTrans w ON  d.WorkOrderTransID = w.ID
		INNER JOIN dbo.tblSvWorkOrderTransExt e ON w.Id = e.ID
		INNER JOIN dbo.tblInItem i ON w.ResourceID = i.ItemId 
	WHERE i.LottedYN = 1 AND e.LotNum IS NOT NULL AND e.QtyUsed <> 0 AND e.HistSeqNum > 0 --Lotted

	EXEC dbo.trav_InUpdateHistory_proc
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_InHistory_proc';

