
CREATE PROCEDURE dbo.trav_WmMoveQuantityPost_Remove_proc
AS
BEGIN TRY

	--delete the processed quantities
	DELETE dbo.tblWmMoveQuantity 
	FROM #TransList
	WHERE dbo.tblWmMoveQuantity.[Id] = #TransList.[TransId]

	--delete any child entries for parents that have been processed
	DELETE dbo.tblWmMoveQuantity
	WHERE [ParentId] IS NOT NULL
		AND [ParentId] NOT IN (SELECT [Id] FROM dbo.tblWmMoveQuantity)		

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_Remove_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_Remove_proc';

