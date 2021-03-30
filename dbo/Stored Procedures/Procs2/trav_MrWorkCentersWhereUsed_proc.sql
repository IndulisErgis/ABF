
CREATE PROCEDURE [dbo].[trav_MrWorkCentersWhereUsed_proc]
 @HasAssemblies bit,
 @HasRoutings bit,
 @HasOperations bit

AS
SET NOCOUNT ON
BEGIN TRY


SELECT w.WorkCenterId, w.Descr
FROM dbo.tblMrWorkCenter w INNER JOIN #tmpWorkCentersWhereUsed t on w.WorkCenterId = t.WorkCenterId
 
IF(@HasAssemblies =1)
BEGIN
	
SELECT w.WorkCenterId, h.AssemblyId, h.RevisionNo, r.Step, h.Description 
FROM dbo.tblMrWorkCenter w INNER JOIN dbo.tblMbAssemblyRouting r ON w.WorkCenterId = r.WorkCenterId 
	INNER JOIN dbo.tblMbAssemblyHeader h ON r.HeaderId= h.Id
	INNER JOIN #tmpWorkCentersWhereUsed t on w.WorkCenterId = t.WorkCenterId
END

IF(@HasOperations = 1)
BEGIN
	SELECT w.WorkCenterId, o.OperationId, o.Descr 
FROM dbo.tblMrWorkCenter w INNER JOIN dbo.tblMrOperations o ON w.WorkCenterId = o.WorkCenterId
INNER JOIN #tmpWorkCentersWhereUsed t on w.WorkCenterId = t.WorkCenterId

END

IF(@HasRoutings = 1)
BEGIN
	SELECT w.WorkCenterId, h.RoutingId, r.Step, h.Descr 
	FROM dbo.tblMrWorkCenter w 
	INNER JOIN dbo.tblMrRoutingDetail r ON w.WorkCenterId = r.WorkCenterId 
	INNER JOIN dbo.tblMrRoutingHeader h ON r.RoutingId = h.RoutingId
	INNER JOIN #tmpWorkCentersWhereUsed t on w.WorkCenterId = t.WorkCenterId

END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrWorkCentersWhereUsed_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrWorkCentersWhereUsed_proc';

