
CREATE PROCEDURE dbo.[trav_SvServiceOrderPost_PurgeCompletedServiceOrder_proc]
AS
BEGIN TRY

	IF EXISTS(SELECT * FROM #CompletedServiceOrdertable)
	BEGIN
	
		UPDATE dbo.tblSmTransLink SET SourceStatus = 1
		WHERE SeqNum IN (SELECT d.LinkSeqNum FROM #CompletedServiceOrdertable t INNER JOIN  dbo.tblSvWorkOrderTrans d ON t.WorkOrderID = d.WorkOrderID
				WHERE d.LinkSeqNum IS NOT NULL)
			AND SourceType = 5
			
		DELETE FROM dbo.tblSvWorkOrder
		WHERE ID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)
		
		DELETE FROM dbo.tblSvWorkOrderReferral
		WHERE ID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)
		
		DELETE dbo.tblSvWorkOrderDispatchCoverage
		FROM dbo.tblSvWorkOrderDispatchCoverage
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON dbo.tblSvWorkOrderDispatchCoverage.DispatchID= d.ID
		INNER JOIN  #CompletedServiceOrdertable c ON d.WorkOrderID= c.WorkOrderID

		DELETE FROM dbo.tblSvWorkOrderDispatch
		WHERE WorkOrderID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)

		DELETE FROM dbo.tblSvWorkOrderDispatchWorkToDo
		WHERE WorkOrderID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)

		DELETE FROM dbo.tblSvWorkOrderActivity
		WHERE WorkOrderID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)		

		DELETE  dbo.tblSvWorkOrderTransExt
		FROM tblSvWorkOrderTrans t INNER JOIN tblSvWorkOrderTransExt ON tblSvWorkOrderTransExt.TransID = t.ID
		WHERE WorkOrderID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)

		DELETE  dbo.tblSvWorkOrderTransSer
		FROM tblSvWorkOrderTrans t INNER JOIN tblSvWorkOrderTransSer ON tblSvWorkOrderTransSer.TransID = t.ID
		WHERE WorkOrderID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)

		DELETE FROM dbo.tblSvWorkOrderTrans
		WHERE WorkOrderID IN (SELECT WorkOrderID FROM #CompletedServiceOrdertable)
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_PurgeCompletedServiceOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_PurgeCompletedServiceOrder_proc';

