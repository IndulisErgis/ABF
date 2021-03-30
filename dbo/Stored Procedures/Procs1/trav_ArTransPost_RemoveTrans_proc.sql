
CREATE PROCEDURE dbo.trav_ArTransPost_RemoveTrans_proc
AS
BEGIN TRY
	DELETE dbo.tblArTransHeader
		FROM dbo.tblArTransHeader
		INNER JOIN #PostTransList l ON dbo.tblArTransHeader.TransId = l.TransId

	DELETE dbo.tblArTransDetail
		FROM dbo.tblArTransDetail
		INNER JOIN #PostTransList l ON dbo.tblArTransDetail.TransId = l.TransId

	DELETE dbo.tblArTransLot
		FROM dbo.tblArTransLot
		INNER JOIN #PostTransList l ON dbo.tblArTransLot.TransId = l.TransId

	DELETE dbo.tblArTransSer
		FROM dbo.tblArTransSer
		INNER JOIN #PostTransList l ON dbo.tblArTransSer.TransId = l.TransId

	DELETE dbo.tblArTransPmt
		FROM dbo.tblArTransPmt
		INNER JOIN #PostTransList l ON dbo.tblArTransPmt.TransId = l.TransId

	DELETE dbo.tblArTransTax
		FROM dbo.tblArTransTax
		INNER JOIN #PostTransList l ON dbo.tblArTransTax.TransId = l.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_RemoveTrans_proc';

