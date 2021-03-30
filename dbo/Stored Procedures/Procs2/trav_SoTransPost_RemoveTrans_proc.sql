
CREATE PROCEDURE dbo.trav_SoTransPost_RemoveTrans_proc
AS
SET NOCOUNT ON
BEGIN TRY
	CREATE TABLE #RemoveTransList( TransId nvarchar(10) NOT NULL PRIMARY KEY  CLUSTERED ([TransId]))
	
	INSERT INTO #RemoveTransList (TransId)
	SELECT h.TransId
		FROM dbo.tblSoTransHeader h
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		WHERE h.TransType <> 3 --don't remove trans that have been converted to backorders

	UPDATE dbo.tblInQty_Ext SET Qty = 0
	FROM dbo.tblInQty_Ext INNER JOIN dbo.tblSoTransDetailExt s ON dbo.tblInQty_Ext.ExtSeqNum = s.QtySeqNum_Cmtd
		INNER JOIN #RemoveTransList t ON s.TransId = t.TransId

	UPDATE dbo.tblSmTransLink SET SourceStatus = 1
	WHERE SeqNum IN (SELECT d.LinkSeqNum FROM #RemoveTransList t INNER JOIN  dbo.tblSoTransDetail d ON t.TransId = d.TransId
			WHERE d.LinkSeqNum IS NOT NULL)
		AND SourceType = 4

	DELETE dbo.tblSoTransHeader
		FROM dbo.tblSoTransHeader
		INNER JOIN #RemoveTransList l ON dbo.tblSoTransHeader.TransId = l.TransId

	DELETE dbo.tblSoTransDetail
		FROM dbo.tblSoTransDetail
		INNER JOIN #RemoveTransList l ON dbo.tblSoTransDetail.TransId = l.TransId

	DELETE dbo.tblSoTransDetailExt
		FROM dbo.tblSoTransDetailExt
		INNER JOIN #RemoveTransList l ON dbo.tblSoTransDetailExt.TransId = l.TransId

	DELETE dbo.tblSoTransSer
		FROM dbo.tblSoTransSer
		INNER JOIN #RemoveTransList l ON dbo.tblSoTransSer.TransId = l.TransId

	DELETE dbo.tblSoTransPmt
		FROM dbo.tblSoTransPmt
		INNER JOIN #RemoveTransList l ON dbo.tblSoTransPmt.TransId = l.TransId

	DELETE dbo.tblSoTransTax
		FROM dbo.tblSoTransTax
		INNER JOIN #RemoveTransList l ON dbo.tblSoTransTax.TransId = l.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_RemoveTrans_proc';

