
CREATE PROCEDURE dbo.trav_SoReturnedItemPost_Prepare_proc
AS
SET NOCOUNT ON
BEGIN TRY

	--remove any invalid entries from the list to process
	DELETE #PostTransList 
	WHERE [TransId] IN (SELECT b.[TransId]
		FROM #PostTransList b INNER JOIN dbo.tblSoReturnedItem h on b.[TransId] = h.[Counter] 
		WHERE h.[Status] <> 0) --approved items only
		
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_Prepare_proc';

