
CREATE PROCEDURE [dbo].[trav_MrMachineGroupsWhereUsed_proc]
@HasAssemblies tinyint,
@HasRoutings tinyint,
@HasOperations tinyint,
@HasWorkCenters tinyint

AS
SET NOCOUNT ON
BEGIN TRY

SELECT m.MachineGroupId, m.Descr, m.QtyAvail, m.CostGroupId
FROM dbo.tblMrMachineGroups  m inner join 
#tmpMrMachineGroupsWhereUsed t on m.MachineGroupId = t.MachineGroupId


IF(@HasAssemblies = 1 )
BEGIN
SELECT g.MachineGroupId, a.AssemblyId, a.RevisionNo, r.Step, a.Description 
FROM dbo.tblMrMachineGroups g 
	INNER JOIN dbo.tblMbAssemblyRouting r ON g.MachineGroupId = r.MachineGroupId 
	INNER JOIN dbo.tblMbAssemblyHeader a ON r.HeaderId = a.Id
	inner join #tmpMrMachineGroupsWhereUsed t on g.MachineGroupId = t.MachineGroupId
END

IF(@HasOperations = 1 )
BEGIN
SELECT o.OperationId, o.Descr, g.MachineGroupId, o.MachRunTime, o.ReqEmployees, o.MachRunTimeIn 
FROM dbo.tblMrMachineGroups g INNER JOIN dbo.tblMrOperations o ON g.MachineGroupId = o.MachineGroupId
inner join #tmpMrMachineGroupsWhereUsed t on g.MachineGroupId = t.MachineGroupId
END

IF(@HasRoutings = 1)
BEGIN
SELECT r.RoutingId, h.Descr, m.MachineGroupId 
FROM dbo.tblMrMachineGroups m 
	INNER JOIN dbo.tblMrRoutingDetail r ON m.MachineGroupId = r.MachineGroupId 
	INNER JOIN dbo.tblMrRoutingHeader h ON r.RoutingID = h.RoutingId
	inner join #tmpMrMachineGroupsWhereUsed t on m.MachineGroupId = t.MachineGroupId
END

IF(@HasWorkCenters =1)
BEGIN
SELECT m.MachineGroupId, w.WorkCenterId, w.Descr 
FROM dbo.tblMrWCMachineGroups wcm 
	INNER JOIN dbo.tblMrWorkCenter w ON wcm.WorkCenterId = w.WorkCenterId 
	INNER JOIN dbo.tblMrMachineGroups m ON wcm.MachineGroupId = m.MachineGroupId
	inner join #tmpMrMachineGroupsWhereUsed t on m.MachineGroupId = t.MachineGroupId

END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrMachineGroupsWhereUsed_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrMachineGroupsWhereUsed_proc';

