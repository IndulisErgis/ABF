
CREATE PROCEDURE [dbo].[trav_MrMachineGroupsList_proc]
@MaintenanceCutoffDate  DateTime 

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT m.MachineGroupId, m.Descr, m.Notes, m.MaintCycle, m.MaintDate, m.QtyAvail, m.HrlyCostFactor, m.SetupTime
		, m.ScheduleId, m.GLAcct1, m.CostGroupId, m.MGID, m.PurchaseDate
	FROM dbo.tblMrMachineGroups m INNER JOIN #tmpMachineGroupsList t ON m.MachineGroupId = t.MachineGroupId 
	WHERE @MaintenanceCutoffDate IS NULL --all machine groups
		OR  (m.MaintCycle > 0 AND m.MaintDate IS NOT NULL AND DATEADD(day, m.MaintCycle, m.MaintDate) <= @MaintenanceCutoffDate) --or pull the ones that need maintenance

	SELECT m.MachineGroupId, m.LaborTypeId, l.Descr 
	FROM dbo.tblMrMachineLabor m LEFT JOIN dbo.tblMrLabor l ON m.LaborTypeId = l.LaborTypeId
		INNER JOIN #tmpMachineGroupsList t on m.MachineGroupId = t.MachineGroupId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrMachineGroupsList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrMachineGroupsList_proc';

