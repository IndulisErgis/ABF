
CREATE PROCEDURE dbo.trav_SvServiceOrderPost_InHistory_proc
AS
BEGIN TRY

	UPDATE dbo.tblInQty SET Qty = 0
	FROM dbo.tblInQty INNER JOIN dbo.tblSvWorkOrderTrans s ON dbo.tblInQty.SeqNum = s.QtySeqNum_Cmtd
		INNER JOIN #TransactionListToProcessTable t ON s.Id = t.TransId
		
	UPDATE dbo.tblInQty_Ext SET Qty = 0
	FROM dbo.tblInQty_Ext INNER JOIN dbo.tblSvWorkOrderTransExt s ON dbo.tblInQty_Ext.ExtSeqNum = s.QtySeqNum_Cmtd
		INNER JOIN #TransactionListToProcessTable t ON s.TransId = t.TransId

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId, RefId)
	SELECT tr.HistSeqNum, tr.FiscalYear, tr.FiscalPeriod, tr.TransDate, null, null
	FROM #TransactionListToProcessTable t INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	WHERE tr.HistSeqNum > 0

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId, RefId)
	SELECT d.HistSeqNum, tr.FiscalYear, tr.FiscalPeriod, tr.TransDate, null, null
	FROM #TransactionListToProcessTable t INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
		INNER JOIN dbo.tblSvWorkOrderTransExt d ON tr.ID = d.TransID 
		INNER JOIN dbo.tblInItem i ON tr.ResourceID = i.ItemId 
	WHERE i.LottedYN = 1 AND d.LotNum IS NOT NULL AND d.HistSeqNum > 0 --Lotted

	EXEC dbo.trav_InUpdateHistory_proc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_InHistory_proc';

