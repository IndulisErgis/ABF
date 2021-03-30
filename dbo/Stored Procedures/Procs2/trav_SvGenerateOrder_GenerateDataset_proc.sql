

CREATE PROCEDURE dbo.trav_SvGenerateOrder_GenerateDataset_proc
@OrderType int,
@MaintenanceDueDate datetime,
@GroupDispatchByEquipment bit
AS

BEGIN TRY

	CREATE TABLE #Temp
	(
		EquipmentID bigint NULL, 
		WorkToDoID nvarchar(20) NULL,
		CustID  pCustID NULL,
		Description pDescription NULL, 
		RequestedDate datetime NULL, 
		SiteID pLocID  NULL
	)
		
	-- Select main Dataset
	IF( @GroupDispatchByEquipment = 1)
	BEGIN
		INSERT INTO #Temp (EquipmentID, WorkToDoID, CustID, Description, RequestedDate, SiteID)
		SELECT  s.EquipmentID,s.WorkToDoID ,e.CustID AS CustID,e.Description,a.RequestedDate,e.SiteID
		FROM #SiteEquipmentList t
		INNER JOIN dbo.tblSvEquipment e ON t.EquipmentID = e.ID
		INNER JOIN dbo.tblSvEquipmentService s ON t.EquipmentID = s.EquipmentID
		INNER JOIN dbo.tblSvWorkToDo w ON s.WorkToDoID = w.WorkToDoID 
		INNER JOIN
		(
			SELECT MAX(s.ScheduleNextDate) AS RequestedDate , WorkToDoID , s.EquipmentID
			FROM  #SiteEquipmentList t
			INNER JOIN dbo.tblSvEquipment e ON t.EquipmentID = e.ID
			INNER JOIN dbo.tblSvEquipmentService s ON t.EquipmentID = s.EquipmentID
			GROUP BY WorkToDoID,s.EquipmentID
		) AS a ON w.WorkToDoID = a.WorkToDoID AND s.EquipmentID = a.EquipmentID
		WHERE	DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleNextDate)) <=  DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleEndDate)) 
				AND DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleNextDate)) <= @MaintenanceDueDate 
				AND DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleEndDate)) >= @MaintenanceDueDate AND e.Status <> 2
		Order By e.CustID ,e.SiteID
	END	

	ELSE IF( @GroupDispatchByEquipment = 0)
	BEGIN
		INSERT INTO #Temp (EquipmentID, WorkToDoID, CustID, Description, RequestedDate, SiteID)
		SELECT  s.EquipmentID,s.WorkToDoID ,e.CustID AS CustID,e.Description,s.ScheduleNextDate AS RequestedDate,e.SiteID
		FROM #SiteEquipmentList t
		INNER JOIN dbo.tblSvEquipment e ON t.EquipmentID = e.ID 
		INNER JOIN dbo.tblSvEquipmentService s ON t.EquipmentID = s.EquipmentID
		INNER JOIN dbo.tblSvWorkToDo w ON s.WorkToDoID = w.WorkToDoID 
		WHERE	DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleNextDate)) <=  DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleEndDate)) 
				AND DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleNextDate)) <= @MaintenanceDueDate 
				AND DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleEndDate)) >= @MaintenanceDueDate AND e.Status <> 2
		Order By e.CustID ,e.SiteID
	END

	DELETE  #Temp  
	FROM  #Temp  t
	INNER JOIN 	
	(
		SELECT d.EquipmentID ,w.WorkToDoID
		FROM #Temp t		
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.EquipmentID = d.EquipmentID 
		INNER JOIN dbo.tblSvWorkOrderDispatchWorkToDo w ON t.WorkToDoID = w.WorkToDoID and d.WorkOrderID = w.WorkOrderID AND t.EquipmentID = d.EquipmentID  AND d.ID = w.DispatchID
		WHERE d.Status <> 3 AND d.CancelledYN = 0 -- skip not posted AND not cancelled
	) x
	ON x.EquipmentID = t.EquipmentID AND x.WorkToDoID = t.WorkToDoID

	SELECT  EquipmentID,WorkToDoID ,CustID,Description,RequestedDate,SiteID
	FROM #Temp

	SELECT distinct r.RelationID ,r.WorkToDoID
	FROM #SiteEquipmentList t 
	INNER JOIN dbo.tblSvEquipment e ON t.EquipmentID = e.ID 
	INNER JOIN dbo.tblSvEquipmentService s ON t.EquipmentID = s.EquipmentID
	INNER JOIN dbo.tblSvWorkToDo w ON s.WorkToDoID = w.WorkToDoID 
	INNER JOIN dbo.tblSvWorkToDoRelation r ON w.WorkToDoID = r.WorkToDoID
	WHERE	DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleNextDate)) <= DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleEndDate)) 
			AND DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleNextDate)) <= @MaintenanceDueDate 
			AND DATEADD(dd, 0, DATEDIFF(dd, 0, s.ScheduleEndDate)) >= @MaintenanceDueDate AND e.Status <> 2


END TRY

BEGIN CATCH

	EXEC dbo.trav_RaiseError_proc

END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvGenerateOrder_GenerateDataset_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvGenerateOrder_GenerateDataset_proc';

