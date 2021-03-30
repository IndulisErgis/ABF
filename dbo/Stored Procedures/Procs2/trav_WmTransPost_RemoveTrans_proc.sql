
CREATE PROCEDURE dbo.trav_WmTransPost_RemoveTrans_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--remove the processed transactions	
	DELETE dbo.tblWmTrans
	FROM #PostTransList t INNER JOIN dbo.tblWmTrans on t.TransId = dbo.tblWmTrans.TransId
	
	DELETE dbo.tblWmTransSer
	FROM #PostTransList t INNER JOIN dbo.tblWmTransSer on t.TransId = dbo.tblWmTransSer.TransId

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_RemoveTrans_proc';

