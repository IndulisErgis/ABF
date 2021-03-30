--PET: http://problemtrackingsystem.osas.com/view.php?id=263214

CREATE PROCEDURE dbo.trav_SvServiceOrderPost_UpdateServiceOrder_proc
AS
BEGIN TRY

	DECLARE @EnteredBy pUserID, @WrkStnDate datetime,@PostRun pPostRun

	SELECT @EnteredBy = [Value]  FROM #GlobalValues WHERE [Key] = 'EnteredBy'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'CurrentWrkStnDateTime'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'

	-- Update status of Dispatch to be Posted to Posted
	UPDATE dbo.tblSvWorkOrderDispatch SET Status = 3 ,PostRun = @PostRun, StatusID = 7
	FROM #ServiceOrderDispatchList t 
	INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.ID

	--Update status of transaction to Posted
	UPDATE dbo.tblSvWorkOrderTrans SET Status = 1
	FROM #TransactionListToProcessTable t
	INNER JOIN  dbo.tblSvWorkOrderTrans tr ON t.transID = tr.ID

	--Create activity record for Dispatch to be Posted
	INSERT INTO dbo.tblSvWorkOrderActivity (DispatchID,WorkOrderID,ActivityType,ActivityDateTime,EntryDate,EnteredBy) 
	SELECT t.DispatchID,d.WorkOrderID,7,@WrkStnDate,GETDATE(),@EnteredBy 
	FROM  #ServiceOrderDispatchList t INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.ID
	
	--Update site equipment next due date
	UPDATE tblSvEquipmentService
		SET ScheduleNextDate = CASE WHEN ScheduleType =0 THEN DATEADD(YEAR,ScheduleInterval,ISNULL(a.CompletedDate,@WrkStnDate))
									WHEN ScheduleType =1 THEN DATEADD(MONTH,ScheduleInterval,ISNULL(a.CompletedDate,@WrkStnDate))
									WHEN ScheduleType =2 THEN DATEADD(DAY,ScheduleInterval,ISNULL(a.CompletedDate,@WrkStnDate)) 
								END
	FROM #ServiceOrderDispatchList t
	INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.ID
	INNER JOIN tblSvWorkOrderDispatchWorkToDo w ON d.ID=w.DispatchID
	INNER JOIN tblSvEquipment e ON e.ID = d.EquipmentID
	INNER JOIN tblSvEquipmentService s ON s.EquipmentID= d.EquipmentID AND s.WorkToDoID = w.WorkToDoID
	LEFT JOIN 
	(	SELECT a.DispatchID, MAX(a.ActivityDateTime) CompletedDate
		FROM #ServiceOrderDispatchList t INNER JOIN tblSvWorkOrderActivity a ON t.DispatchID = a.DispatchID
		WHERE a.ActivityType = 4
		GROUP BY a.DispatchID
	) a  ON t.DispatchID =a.DispatchID
	WHERE e.SiteYN = 1

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_UpdateServiceOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_UpdateServiceOrder_proc';

