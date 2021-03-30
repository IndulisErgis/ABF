
CREATE PROCEDURE dbo.trav_InMatReqTransPost_Clear_proc
AS
BEGIN TRY

	UPDATE dbo.tblInMatReqDetail SET QtyReqstd = CASE WHEN QtyFilled < QtyReqstd THEN QtyReqstd - QtyFilled ELSE 0 END, QtyFilled = 0,
		QtySeqNum = 0, HistSeqNum = 0
	FROM dbo.tblInMatReqDetail INNER JOIN #PostTransList t ON dbo.tblInMatReqDetail.TransId = t.TransId

	/* delete Material Requisitions detail information */
	DELETE dbo.tblInMatReqDetail
	FROM dbo.tblInMatReqDetail INNER JOIN #PostTransList t ON dbo.tblInMatReqDetail.TransId = t.TransId
	WHERE dbo.tblInMatReqDetail.QtyReqstd = 0 AND dbo.tblInMatReqDetail.QtyFilled = 0 AND dbo.tblInMatReqDetail.QtyBkord = 0
	
	/* delete Material Requisitions header information */
	DELETE dbo.tblInMatReqHeader
	FROM dbo.tblInMatReqHeader INNER JOIN #PostTransList t ON dbo.tblInMatReqHeader.TransId = t.TransId
	WHERE dbo.tblInMatReqHeader.TransId NOT IN (SELECT TransId FROM tblInMatReqDetail)

	/* delete tblInMatReqSer */
	DELETE dbo.tblInMatReqSer
	FROM dbo.tblInMatReqSer INNER JOIN #PostTransList t ON dbo.tblInMatReqSer.TransId = t.TransId

	/* delete tblInMatReqLot */
	DELETE dbo.tblInMatReqLot
	FROM dbo.tblInMatReqLot INNER JOIN #PostTransList t ON dbo.tblInMatReqLot.TransId = t.TransId

	/* zero out costs on the detail records */
	UPDATE dbo.tblInMatReqDetail SET CostUnitStd = 0 
	FROM dbo.tblInMatReqDetail INNER JOIN #PostTransList t ON dbo.tblInMatReqDetail.TransId = t.TransId
	WHERE dbo.tblInMatReqDetail.QtyFilled = 0

	/* zero out costs on the header records */
	UPDATE dbo.tblInMatReqHeader SET ReqTotal = 0
	FROM dbo.tblInMatReqHeader INNER JOIN #PostTransList t ON dbo.tblInMatReqHeader.TransId = t.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqTransPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqTransPost_Clear_proc';

