
CREATE PROCEDURE dbo.trav_PoTransPost_PurgeCompletedWM_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--remove completed entries that no longer tie to a source transaction
	DELETE dbo.tblWmRcpt
	WHERE [Status] = 2 --completed
		AND [Source] = 0 --PO
		AND	[TransId] NOT IN (SELECT [TransId] FROM dbo.tblPoTransHeader)		
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_PurgeCompletedWM_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_PurgeCompletedWM_proc';

