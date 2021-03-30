
CREATE PROCEDURE dbo.trav_PcTransPost_RemoveTrans_proc
AS
BEGIN TRY

	UPDATE dbo.tblInQty SET Qty = 0
	FROM dbo.tblInQty INNER JOIN dbo.tblPcTrans s ON dbo.tblInQty.SeqNum = s.QtySeqNum_Cmtd
		INNER JOIN #PostTransList t ON s.Id = t.TransId 
	WHERE s.QtyFilled <> 0
		
	UPDATE dbo.tblInQty_Ext SET Qty = 0 
	FROM dbo.tblInQty_Ext INNER JOIN dbo.tblPcTransExt s ON dbo.tblInQty_Ext.ExtSeqNum = s.QtySeqNum_Cmtd 
		INNER JOIN dbo.tblPcTrans h ON s.TransId = h.Id
		INNER JOIN #PostTransList t ON h.Id = t.TransId
	WHERE h.QtyFilled <> 0

	UPDATE dbo.tblSmTransLink SET SourceStatus = 1
	WHERE SeqNum IN (SELECT s.LinkSeqNum FROM #PostTransList t INNER JOIN dbo.tblPcTrans s ON t.TransId = s.Id
			WHERE s.QtyFilled <> 0 AND s.LinkSeqNum IS NOT NULL) 
		AND SourceType = 3
			
	DELETE dbo.tblPcTransExt
	FROM #PostTransList t INNER JOIN dbo.tblPcTransExt ON t.TransId = dbo.tblPcTransExt.TransId 
		INNER JOIN dbo.tblPcTrans h ON dbo.tblPcTransExt.TransId = h.Id
	WHERE h.QtyFilled <> 0
	
	DELETE dbo.tblPcTransSer
	FROM #PostTransList t INNER JOIN dbo.tblPcTransSer ON t.TransId = dbo.tblPcTransSer.TransId
		INNER JOIN dbo.tblPcTrans h ON dbo.tblPcTransSer.TransId = h.Id
	WHERE h.QtyFilled <> 0

	DELETE dbo.tblPcTrans
	FROM #PostTransList t INNER JOIN dbo.tblPcTrans ON t.TransId = dbo.tblPcTrans.Id
	WHERE dbo.tblPcTrans.QtyFilled <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_RemoveTrans_proc';

