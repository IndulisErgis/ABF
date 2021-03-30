
CREATE PROCEDURE dbo.trav_SvServiceOrderPost_GetCompletedServiceOrder_proc
AS
BEGIN TRY	

	CREATE TABLE #Temp1
	(
		WorkOrderID bigint
	)
		
	-- Service order that is not completed 
	INSERT INTO #Temp1(WorkOrderID)
	SELECT t.WorkOrderID 
	FROM #ServiceOrderList t
	INNER JOIN dbo.tblSvWorkOrder t1 ON t.WorkOrderID = t1.ID
	INNER JOIN dbo.tblSvWorkOrderDispatch t2 ON t2.WorkOrderID = t1.id
	WHERE t2.Status = 0  AND CancelledYN = 0		
	
	INSERT INTO #CompletedServiceOrdertable(WorkOrderID)
	SELECT t.WorkOrderID FROM #TransactionListToProcessTable t	
	WHERE t.WorkOrderID not in(SELECT WorkOrderID FROM #Temp1)

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GetCompletedServiceOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GetCompletedServiceOrder_proc';

