
CREATE PROCEDURE [dbo].[trav_MrWorkCentersList_proc]


AS
SET NOCOUNT ON
BEGIN TRY

SELECT w.WorkCenterId, w.Descr, w.Notes, w.MGID, w.ScheduleId, w.GLAcct1, w.Super, w.CostGroupId, w.BillRate, w.BillMethod
	, w.OverheadLaborPct, w.OverheadFlatAmt, w.OverheadPerPiece, w.OverheadMachPct
FROM dbo.tblMrWorkCenter w INNER JOIN #tmpWorkCentersList t on w.WorkCenterId = t.WorkCenterId 

SELECT w.WorkCenterId, m.MachineGroupId, m.Descr 
FROM dbo.tblMrWCMachineGroups w INNER JOIN dbo.tblMrMachineGroups m ON w.MachineGroupId = m.MachineGroupId
INNER JOIN #tmpWorkCentersList t on w.WorkCenterId = t.WorkCenterId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrWorkCentersList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrWorkCentersList_proc';

