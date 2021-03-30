
CREATE PROCEDURE [dbo].[trav_MrOperationsWhereUsed_proc]
@HasRoutings  tinyint,
@HasAssemblies tinyint


AS
SET NOCOUNT ON
BEGIN TRY

SELECT O.OperationId, O.Descr, O.ReqEmployees
FROM dbo.tblMrOperations O INNER JOIN #tmpOperationsWhereUsed t on O.OperationId = t.OperationId

IF(@HasRoutings = 1)
BEGIN
	SELECT d.RoutingId, d.Step, h.Descr, d.OperationId, d.WorkCenterId, d.LaborTypeId, d.MachineGroupId 
FROM dbo.tblMrRoutingDetail d INNER JOIN dbo.tblMrRoutingHeader h ON d.RoutingId = h.RoutingId
INNER JOIN #tmpOperationsWhereUsed tmp on d.OperationId = tmp.OperationId
END

IF(@HasAssemblies = 1)
BEGIN
	SELECT h.AssemblyId, h.RevisionNo, h.Description, o.OperationId, r.Step 
FROM #tmpOperationsWhereUsed o 
	INNER JOIN dbo.tblMbAssemblyRouting r ON o.OperationId = r.OperationId 
	INNER JOIN dbo.tblMbAssemblyHeader h ON r.HeaderId = h.Id  
END


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrOperationsWhereUsed_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrOperationsWhereUsed_proc';

