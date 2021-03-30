
CREATE PROCEDURE [dbo].[trav_MrLaborTypesWhereUsed_proc]
@HasOperations tinyint,
@HasRoutings tinyint,
@HasMachineGroups tinyint,
@HasAssemblies tinyint

AS
SET NOCOUNT ON
BEGIN TRY

SELECT l.LaborTypeId, l.Descr, l.HourlyRate, l.ScheduleId,l.PerPieceCost
FROM dbo.tblMrLabor l inner join 
#tmpLaborTypesWhereUsed t on l.LaborTypeId = t.LaborTypeId


IF(@HasAssemblies = 1)
BEGIN
	SELECT DISTINCT l.LaborTypeId, a.AssemblyId, a.RevisionNo, a.Description 
	FROM dbo.tblMrLabor l 
	INNER JOIN dbo.tblMbAssemblyRouting r ON l.LaborTypeId = r.LaborTypeId
	INNER JOIN dbo.tblMbAssemblyHeader a ON r.HeaderId = a.Id
	INNER JOIN #tmpLaborTypesWhereUsed t on t.LaborTypeId = l.LaborTypeId
END

IF(@HasRoutings = 1)
BEGIN
	SELECT DISTINCT l.LaborTypeId, h.RoutingId, r.Step, h.Descr 
	FROM dbo.tblMrLabor l 
	INNER JOIN dbo.tblMrRoutingDetail r ON l.LaborTypeId = r.LaborTypeId 
	INNER JOIN dbo.tblMrRoutingHeader h ON h.RoutingId = r.RoutingId
	INNER JOIN #tmpLaborTypesWhereUsed t on t.LaborTypeId = l.LaborTypeId
END

IF(@HasOperations = 1)
BEGIN
	SELECT l.LaborTypeId, o.OperationId, o.Descr, o.ReqEmployees, o.LaborRunTime, o.LaborRunTimeIn 
	FROM dbo.tblMrLabor l INNER JOIN dbo.tblMrOperations o ON l.LaborTypeId = o.LaborTypeId
	INNER JOIN #tmpLaborTypesWhereUsed t on t.LaborTypeId = l.LaborTypeId
END

IF(@HasMachineGroups = 1)
BEGIN
	SELECT l.LaborTypeId, g.MachineGroupId, g.Descr, g.QtyAvail, g.HrlyCostFactor, g.ScheduleId 
	FROM dbo.tblMrLabor l 
	INNER JOIN (SELECT m.MachineGroupId, m.LaborTypeId, l.Descr 
					FROM dbo.tblMrMachineLabor m LEFT OUTER JOIN dbo.tblMrLabor l ON m.LaborTypeId = l.LaborTypeId
				) m ON l.LaborTypeId = m.LaborTypeId 
	INNER JOIN dbo.tblMrMachineGroups g ON m.MachineGroupId = g.MachineGroupId
	INNER JOIN #tmpLaborTypesWhereUsed t on t.LaborTypeId = l.LaborTypeId
END


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrLaborTypesWhereUsed_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrLaborTypesWhereUsed_proc';

