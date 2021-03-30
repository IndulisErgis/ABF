
CREATE PROCEDURE dbo.trav_SoReturnedItemPost_Remove_proc
AS
SET NOCOUNT ON
BEGIN TRY

	--delete records that have been marked as posted and no longer tie to an originating document
	Delete dbo.tblSoReturnedItem 
		Where [Status] = 9
		And Not Exists(Select 1 From dbo.tblSoTransDetail d 
						Where d.TransId = dbo.tblSoReturnedItem.TransId 
						and d.EntryNum = dbo.tblSoReturnedItem.EntryNum)
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_Remove_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_Remove_proc';

