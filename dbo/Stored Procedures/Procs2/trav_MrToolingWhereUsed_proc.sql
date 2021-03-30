
CREATE PROCEDURE [dbo].[trav_MrToolingWhereUsed_proc]

AS
SET NOCOUNT ON
BEGIN TRY

SELECT t.ToolingId, t.Descr, t.StorageLocation, t.VendorId, t.Qty, t.Cost
FROM dbo.tblMrTooling t INNER JOIN #tmpToolingWhereUsed tmp on t.ToolingId = tmp.ToolingId 

SELECT t.ToolingId, o.OperationId, o.Descr 
FROM #tmpToolingWhereUsed t INNER JOIN 
	(dbo.tblMrOperations o INNER JOIN dbo.tblMrOperationsTooling ot ON o.OperationId = ot.OperationId) 
		ON t.ToolingId = ot.ToolingId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrToolingWhereUsed_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrToolingWhereUsed_proc';

