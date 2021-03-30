
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_PurgeWorkOrder_proc
AS
BEGIN TRY

	UPDATE dbo.tblSmTransLink SET SourceStatus = 1
	WHERE SeqNum IN (SELECT d.LinkSeqNum FROM #CompletedWorkorder t INNER JOIN  dbo.tblSvWorkOrderTrans d ON t.WorkOrderID = d.WorkOrderID
			WHERE d.LinkSeqNum IS NOT NULL)
		AND SourceType = 5
  
	DELETE dbo.tblSvWorkOrder
		FROM dbo.tblSvWorkOrder
		INNER JOIN  #CompletedWorkorder c ON dbo.tblSvWorkOrder.ID = c.WorkOrderID

	DELETE dbo.tblSvWorkOrderReferral
		FROM dbo.tblSvWorkOrderReferral
		INNER JOIN  #CompletedWorkorder c ON dbo.tblSvWorkOrderReferral.ID= c.WorkOrderID
		
	DELETE dbo.tblSvWorkOrderDispatchCoverage
		FROM dbo.tblSvWorkOrderDispatchCoverage
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON dbo.tblSvWorkOrderDispatchCoverage.DispatchID= d.ID
		INNER JOIN  #CompletedWorkorder c ON d.WorkOrderID= c.WorkOrderID

	DELETE dbo.tblSvWorkOrderDispatch
		FROM dbo.tblSvWorkOrderDispatch
		INNER JOIN  #CompletedWorkorder c ON dbo.tblSvWorkOrderDispatch.WorkOrderID= c.WorkOrderID

	DELETE dbo.tblSvWorkOrderDispatchWorkToDo
		FROM dbo.tblSvWorkOrderDispatchWorkToDo
		INNER JOIN  #CompletedWorkorder c ON dbo.tblSvWorkOrderDispatchWorkToDo.WorkOrderID= c.WorkOrderID

	DELETE dbo.tblSvWorkOrderActivity
		FROM dbo.tblSvWorkOrderActivity
		INNER JOIN  #CompletedWorkorder c ON dbo.tblSvWorkOrderActivity.WorkOrderID= c.WorkOrderID

	DELETE dbo.tblSvWorkOrderTransExt
		FROM dbo.tblSvWorkOrderTransExt
		INNER JOIN dbo.tblSvWorkOrderTrans t ON  t.ID = dbo.tblSvWorkOrderTransExt.TransID
		INNER JOIN  #CompletedWorkorder c ON t.WorkOrderID = c.WorkOrderID

	DELETE dbo.tblSvWorkOrderTransSer
		FROM dbo.tblSvWorkOrderTransSer
		INNER JOIN dbo.tblSvWorkOrderTrans t ON  t.ID = dbo.tblSvWorkOrderTransSer.TransID
		INNER JOIN  #CompletedWorkorder c ON t.WorkOrderID = c.WorkOrderID

	DELETE dbo.tblSvWorkOrderTrans
		FROM dbo.tblSvWorkOrderTrans
		INNER JOIN  #CompletedWorkorder c ON dbo.tblSvWorkOrderTrans.WorkOrderID= c.WorkOrderID

	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_PurgeWorkOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_PurgeWorkOrder_proc';

