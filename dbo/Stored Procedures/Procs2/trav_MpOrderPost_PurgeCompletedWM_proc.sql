
CREATE PROCEDURE dbo.trav_MpOrderPost_PurgeCompletedWM_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--remove completed entries that no longer tie to a requirement
	DELETE dbo.tblWmPick
	WHERE [Status] = 2 --completed
		AND [SourceId] = 1 --MP Production
		AND	[EntryNum] NOT IN (SELECT [TransId] FROM dbo.tblMpRequirements)	


	DELETE dbo.tblWmRcpt
	WHERE [Status] = 2 --completed
		AND [Source] = 2 --MP Production
		AND	[EntryNum] NOT IN (SELECT [TransId] FROM dbo.tblMpRequirements)
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderPost_PurgeCompletedWM_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderPost_PurgeCompletedWM_proc';

