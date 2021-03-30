
CREATE PROCEDURE dbo.trav_GlPostToMaster_UpdateJournal_proc
AS
SET NOCOUNT ON
BEGIN TRY

	--mark the journal entries as posted for the selected fiscal years and periods
	UPDATE dbo.tblGlJrnl SET PostedYn = -1
	FROM dbo.tblGlJrnl j
	INNER JOIN #PostJournalList l ON j.EntryNum = l.EntryNum 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_UpdateJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_UpdateJournal_proc';

