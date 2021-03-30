
CREATE PROCEDURE dbo.trav_PcTransPost_PurgeCompletedWM_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--remove completed entries that no longer tie to a source transaction
	DELETE dbo.tblWmPick
	WHERE [Status] = 2 --completed
		AND [SourceId] = 32 --PC Material Req
		AND	[EntryNum] NOT IN (SELECT [Id] FROM dbo.tblPcTrans)
			
	DELETE dbo.tblWmRcpt
	WHERE [Status] = 2 --completed
		AND [Source] = 32 --PC Material Req Return
		AND	[EntryNum] NOT IN (SELECT [Id] FROM dbo.tblPcTrans)
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_PurgeCompletedWM_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_PurgeCompletedWM_proc';

