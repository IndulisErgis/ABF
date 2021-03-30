
CREATE PROCEDURE dbo.trav_SvServiceOrderPost_PurgeWMPickEntries_proc
AS
BEGIN TRY
	--Purge completed WM pick entries if WM interface to SD is Yes
	DELETE dbo.tblWmPick
	WHERE [Status] = 2 --completed
		AND [SourceId] = 2 --Sd 
		AND	[EntryNum] NOT IN (SELECT [Id] FROM dbo.tblSvWorkOrderTrans) 
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_PurgeWMPickEntries_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_PurgeWMPickEntries_proc';

