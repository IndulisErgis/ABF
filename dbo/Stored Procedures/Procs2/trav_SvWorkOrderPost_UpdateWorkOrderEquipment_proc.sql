
--PET: http://problemtrackingsystem.osas.com/view.php?id=263214

CREATE PROCEDURE dbo.trav_SvWorkOrderPost_UpdateWorkOrderEquipment_proc
AS
BEGIN TRY

	DECLARE @PostRun pPostRun, @WrkStnDateTime datetime, @EnteredBy pUserID, @WrkStnDate datetime

	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDateTime = CONVERT(DATETIME,[Value]) FROM #GlobalValues WHERE [Key] = 'WrkStnDateTime'
	SELECT @WrkStnDate = CONVERT(DATETIME,[Value]) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @EnteredBy = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'UserID'


	UPDATE tblSvWorkOrderDispatch 
		SET [Status] =3, PostRun=@PostRun, SourceId =h.SourceId , StatusID = 7
	FROM  tblSvWorkOrderDispatch d
		INNER JOIN tblSvInvoiceDispatch i ON d.ID = i.DispatchID
		INNER JOIN #PostTransList p ON p.TransID = i.TransID
		INNER JOIN tblSvInvoiceHeader h ON h.TransID = i.TransID
		WHERE h.VoidYN=0


	UPDATE tblSvWorkOrderTrans
		SET [Status] =1, EntryNum = i.EntryNum
	FROM  tblSvWorkOrderTrans t
		INNER JOIN tblSvInvoiceDetail i ON i.WorkOrderTransID = t.ID
		INNER JOIN #PostTransList p ON p.TransID = i.TransID
		INNER JOIN tblSvInvoiceHeader h ON h.TransID = i.TransID
		WHERE h.VoidYN=0

	INSERT INTO dbo.tblSvWorkOrderActivity (DispatchID,WorkOrderID,ActivityType,ActivityDateTime,EntryDate,EnteredBy) 

	SELECT DispatchID,d.WorkOrderID,7,@WrkStnDateTime,GETDATE(),@EnteredBy
		FROM  tblSvWorkOrderDispatch d
		INNER JOIN tblSvInvoiceDispatch i ON d.ID = i.DispatchID
		INNER JOIN #PostTransList p ON p.TransID = i.TransID
		INNER JOIN tblSvInvoiceHeader h ON h.TransID = i.TransID
		WHERE h.VoidYN=0

	--Update site equipment next due date
	UPDATE tblSvEquipmentService
		SET ScheduleNextDate = CONVERT(DATETIME, CONVERT(VARCHAR(10),CASE WHEN ScheduleType =0 THEN  DATEADD(YEAR,ScheduleInterval,ISNULL(a.CompletedDate,@WrkStnDate)) 					
									WHEN ScheduleType =1 THEN  DATEADD(MONTH,ScheduleInterval,ISNULL(a.CompletedDate,@WrkStnDate)) 					
									WHEN ScheduleType =2 THEN  DATEADD(DAY,ScheduleInterval,ISNULL(a.CompletedDate,@WrkStnDate)) 							
								END,101))
	FROM tblSvInvoiceDispatch i
		INNER JOIN #PostTransList p ON p.TransID = i.TransID
		INNER JOIN tblSvInvoiceHeader h ON h.TransID = p.TransID
		INNER JOIN tblSvWorkOrderDispatch d ON i.DispatchID = d.ID
		INNER JOIN tblSvWorkOrderDispatchWorkToDo w ON d.WorkOrderID= w.WorkOrderID and d.ID=w.DispatchID
		INNER JOIN tblSvEquipment e ON e.ID = d.EquipmentID
		INNER JOIN tblSvEquipmentService s ON s.EquipmentID= d.EquipmentID AND s.WorkToDoID = w.WorkToDoID
		LEFT JOIN ( SELECT DispatchID, WorkOrderID, MAX(ActivityDateTime) CompletedDate
					FROM tblSvWorkOrderActivity where ActivityType = 4
					GROUP BY DispatchID, WorkOrderID ) a  ON d.ID =a.DispatchID AND d.WorkOrderID =a.WorkOrderID
		WHERE h.VoidYN=0


	INSERT INTO #CompletedWorkorder (WorkOrderID)
	
	SELECT DISTINCT  tblSvInvoiceHeader.WorkOrderID
	FROM  (tblSvInvoiceHeader 
	INNER JOIN tblSvInvoiceDispatch  ON tblSvInvoiceHeader.TransID= tblSvInvoiceDispatch.TransID
	INNER JOIN #PostTransList l ON dbo.tblSvInvoiceHeader.TransId = l.TransId)
	LEFT JOIN (SELECT DISTINCT WorkOrderID From tblSvWorkOrderDispatch Where [Status] < 3) d
			ON tblSvInvoiceHeader.WorkOrderID = d.WorkOrderID
	WHERE d.WorkOrderID IS NULL

	


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_UpdateWorkOrderEquipment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_UpdateWorkOrderEquipment_proc';

