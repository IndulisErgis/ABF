
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_RemoveTrans_proc
AS
BEGIN TRY

	DELETE dbo.tblArCashRcptHeader
		FROM dbo.tblArCashRcptHeader 
		INNER JOIN #PostTransList l ON dbo.tblArCashRcptHeader.RcptHeaderID = l.TransId 

	DELETE dbo.tblArCashRcptDetail 
		FROM dbo.tblArCashRcptDetail
		INNER JOIN #PostTransList l ON dbo.tblArCashRcptDetail.RcptHeaderID = l.TransId 


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_RemoveTrans_proc';

