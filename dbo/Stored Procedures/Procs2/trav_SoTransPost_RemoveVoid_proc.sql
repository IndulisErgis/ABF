
CREATE PROCEDURE dbo.trav_SoTransPost_RemoveVoid_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DELETE dbo.tblSoTransHeader
		FROM dbo.tblSoTransHeader
		INNER JOIN #VoidTransList l ON dbo.tblSoTransHeader.TransId = l.TransId

	DELETE dbo.tblSoTransDetail
		FROM dbo.tblSoTransDetail
		INNER JOIN #VoidTransList l ON dbo.tblSoTransDetail.TransId = l.TransId

	DELETE dbo.tblSoTransDetailExt
		FROM dbo.tblSoTransDetailExt
		INNER JOIN #VoidTransList l ON dbo.tblSoTransDetailExt.TransId = l.TransId

	DELETE dbo.tblSoTransSer
		FROM dbo.tblSoTransSer
		INNER JOIN #VoidTransList l ON dbo.tblSoTransSer.TransId = l.TransId

	DELETE dbo.tblSoTransPmt
		FROM dbo.tblSoTransPmt
		INNER JOIN #VoidTransList l ON dbo.tblSoTransPmt.TransId = l.TransId

	DELETE dbo.tblSoTransTax
		FROM dbo.tblSoTransTax
		INNER JOIN #VoidTransList l ON dbo.tblSoTransTax.TransId = l.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_RemoveVoid_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_RemoveVoid_proc';

