
CREATE PROCEDURE [dbo].[trav_MrOperationsList_proc]
AS
SET NOCOUNT ON
BEGIN TRY

SELECT o.OperationId, o.Descr, o.[Type]
FROM dbo.tblMrOperations o INNER JOIN #tmpOperationsList t on o.OperationId = t.OperationId 


SELECT o.OperationId, o.MachineGroupId, o.LaborTypeId, o.SetupLaborTypeId, o.WorkCenterId, o.Notes
	, o.MachSetup, o.MachSetupIn, o.MachRunTime, o.MachRunTimeIn, o.LaborSetup, o.LaborSetupIn, o.LaborRunTime, o.LaborRunTimeIn
	, o.QueueTime, o.QueueTimeIn, o.WaitTime, o.WaitTimeIn, o.MoveTime, o.MoveTimeIn, o.MGID, o.ReqEmployees, o.YieldPct, o.MaxQuantity
FROM dbo.tblMrOperations o INNER JOIN #tmpOperationsList t on o.OperationId = t.OperationId

SELECT o.OperationId, t.ToolingId, t.Descr 
FROM dbo.tblMrOperationsTooling o INNER JOIN dbo.tblMrTooling t ON o.ToolingId = t.ToolingId
	INNER JOIN #tmpOperationsList tmp on o.OperationId = tmp.OperationId

SELECT o.OperationId, o.VendorId, o.LeadTime, o.CostGroupId, o.UnitCost, o.MinQty, o.MGID, o.DfltVendorId, o.[Description], o.GLAcct1
FROM dbo.tblMrSubContracted o INNER JOIN #tmpOperationsList t on o.OperationId = t.OperationId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrOperationsList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrOperationsList_proc';

