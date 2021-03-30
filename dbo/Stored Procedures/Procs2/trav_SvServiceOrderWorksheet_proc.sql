
CREATE PROCEDURE dbo.trav_SvServiceOrderWorksheet_proc
@ScheduledTechnicianFrom pEmpID = NULL, 
@ScheduledTechnicianThru pEmpID = NULL, 
@ScheduledDateFrom datetime = NULL, 
@ScheduledDateThru datetime = NULL, 
@ViewDetail int = 0, -- 0 = Summary, 1 = Detail
@IncludeWorkToDoDetail bit = 0, 
@IncludeServiceContractDetail bit = 0, 
@IncludeActivityDetail bit = 0, 
@IncludeSerializedLottedDetail bit = 0

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpServiceOrderDispatchList(DispatchID bigint NOT NULL PRIMARY KEY CLUSTERED (DispatchID))
--INSERT INTO #tmpServiceOrderDispatchList (DispatchID) 
--SELECT DispatchID 
--FROM 
--(
--	 SELECT o.WorkOrderNo, o.OrderDate, o.SiteID, o.Region, o.Country, o.PostalCode, o.Phone1
--	  , o.Email, o.OriginalWorkOrder, p.ProjectName, a.PhaseId, a.TaskId, d.ID AS DispatchID, d.DispatchNo
--	  , d.[Description], d.EquipmentDescription, d.RequestedDate, d.RequestedTechID, d.HoldYN
--	  , d.EntryDate, d.[Counter], d.LocID 
--	 FROM dbo.tblSvWorkOrder o 
--		INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
--		LEFT JOIN dbo.tblPcProjectDetail a ON o.ProjectDetailID = a.Id 
--		LEFT JOIN dbo.tblPcProject p ON a.ProjectId = p.Id 
--	 WHERE o.CustID IS NULL AND d.[Status] = 0 AND d.CancelledYN = 0
--) tmp --{0}

	CREATE TABLE #Temp
	(
		DispatchID bigint NOT NULL
	)

		IF (@ScheduledDateFrom IS NULL AND @ScheduledDateThru IS NULL 
			AND @ScheduledTechnicianFrom IS NULL AND @ScheduledTechnicianThru IS NULL)
		BEGIN
			INSERT INTO #Temp(DispatchID) 
			SELECT DispatchID 
			FROM #tmpServiceOrderDispatchList
		END
		ELSE
		BEGIN
		INSERT INTO #Temp(DispatchID) 
			SELECT tmp.DispatchID 
			FROM #tmpServiceOrderDispatchList tmp 
				INNER JOIN 
					(
						SELECT DispatchID FROM dbo.tblSvWorkOrderActivity a 
						WHERE ActivityType = 1 
							AND (@ScheduledDateFrom IS NULL OR a.ActivityDateTime >= @ScheduledDateFrom) 
							AND (@ScheduledDateThru IS NULL OR a.ActivityDateTime < DATEADD(DAY, 1, @ScheduledDateThru)) 
							AND (@ScheduledTechnicianFrom IS NULL OR a.TechID >= @ScheduledTechnicianFrom) 
							AND (@ScheduledTechnicianThru IS NULL OR a.TechID <= @ScheduledTechnicianThru) 
						GROUP BY DispatchID
					) a  ON tmp.DispatchID = a.DispatchID 
		END

	-- main report resultset (Table)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT d.ID AS DispatchID
			, WorkOrderNo AS ServiceOrderNo, w.SiteID AS LocationID, Address1, Address2
			, City, Region, Country, PostalCode, w.Attention AS Contact, w.Phone1 AS Phone
			, DispatchNo, d.EquipmentID, e.EquipmentNo, EquipmentDescription, e.ItemID, e.SerialNumber, e.TagNumber
			, ISNULL(EstTravel, 0) / 3600.00 AS EstTravel
			, (ISNULL(EstimatedTime, 0) + ISNULL(EstTravel, 0)) / 3600.00 AS TotalEst
			, a.ActivityDateTime AS ReceivedDateTime, d.[Priority] ,d.StatusID,ats.Description as ActivityDispatchStatus
		FROM #Temp tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			LEFT JOIN dbo.tblSvEquipment e ON d.EquipmentID = e.ID 
			LEFT JOIN 
				(
					SELECT w.DispatchID, SUM(EstimatedTime) AS EstimatedTime 
					FROM #Temp tmp 
						INNER JOIN dbo.tblSvWorkOrderDispatchWorkToDo w ON tmp.DispatchID = w.DispatchID 
					GROUP BY w.DispatchID
				) r ON d.ID = r.DispatchID 
			LEFT JOIN 
				(
					SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
					WHERE ActivityType = 0 GROUP BY DispatchID
				) t ON d.ID = t.DispatchID 
			LEFT JOIN dbo.tblSvWorkOrderActivity a ON t.ActivityID = a.ID
			LEFT JOIN dbo.tblSvActivityStatus ats ON d.StatusID = ats.ID
	END
	ELSE
	BEGIN
		SELECT d.ID AS DispatchID, WorkOrderNo AS ServiceOrderNo, DispatchNo
		, d.LocID AS LocationID, w.Phone1 AS Phone, w.Country, w.Attention AS Contact
		, a.ActivityDateTime AS ScheduledDateTime, a.TechID AS ScheduledTechID 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN dbo.tblArCust c ON w.CustID = c.CustId 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID 
				FROM dbo.tblSvWorkOrderActivity WHERE ActivityType = 1 
				GROUP BY DispatchID
			) g ON tmp.DispatchID = g.DispatchID 
		LEFT JOIN dbo.tblSvWorkOrderActivity a ON g.ActivityID = a.ID
	END 

	-- Work To Do resultset (Table1)
	SELECT w.DispatchID, WorkToDoID, [Description], SkillLevel
		, EstimatedTime / 3600.00 AS EstimatedTime 
	FROM dbo.tblSvWorkOrderDispatchWorkToDo w 
		INNER JOIN #Temp tmp ON w.DispatchID = tmp.DispatchID 
	WHERE @IncludeWorkToDoDetail <> 0

	-- Service Contract resultset (Table2)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT s.EquipmentID, s.CoverageType, h.ContractNo, h.EndDate 
		FROM 
			(
				SELECT d.EquipmentID FROM dbo.tblSvWorkOrderDispatch d 
					INNER JOIN #Temp tmp ON d.ID = tmp.DispatchID 
				WHERE d.EquipmentID IS NOT NULL GROUP BY d.EquipmentID
			) tmp 
			INNER JOIN dbo.tblSvServiceContractDetail s ON tmp.EquipmentID = s.EquipmentID 
			INNER JOIN dbo.tblSvServiceContractHeader h ON s.ContractID = h.ID 
		WHERE @IncludeServiceContractDetail <> 0
	END

	-- Activity resultset (Table3)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT a.DispatchID, ActivityType, ActivityDateTime
			, TechID, EntryDate, EnteredBy 
		FROM dbo.tblSvWorkOrderActivity a 
			INNER JOIN #Temp tmp ON a.DispatchID = tmp.DispatchID 
		WHERE @IncludeActivityDetail <> 0 AND a.ActivityType = 1
	END

	-- Transaction resultset (Table4)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT t.ID AS TransID, t.DispatchID, t.TransType, ResourceID, t.TransDate
			, QtyEstimated, QtyUsed, Unit, t.[Description] 
		FROM dbo.tblSvWorkOrderDispatch d 
			INNER JOIN #Temp tmp ON d.ID = tmp.DispatchID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			LEFT JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
		WHERE (t.TransType = 0 OR t.TransType = 1) -- exclude freight & misc records
	END

	-- Transaction Lotted Detail resultset (Table5)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT TransID, LotNum, e.QtyUsed, e.UnitCost 
		FROM dbo.tblSvWorkOrderDispatch d 
			INNER JOIN #Temp tmp ON d.ID = tmp.DispatchID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
			INNER JOIN dbo.tblSvWorkOrderTransExt e ON t.ID = e.TransID 
		WHERE @IncludeSerializedLottedDetail <> 0 AND (TransType = 0 OR TransType = 1) -- exclude freight & misc records
	END

	-- Transaction Serialized Detail resultset (Table6)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT TransID, LotNum, SerNum, s.UnitCost 
		FROM dbo.tblSvWorkOrderDispatch d 
			INNER JOIN #Temp tmp ON d.ID = tmp.DispatchID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
			INNER JOIN dbo.tblSvWorkOrderTransSer s ON t.ID = s.TransID 
		WHERE @IncludeSerializedLottedDetail <> 0 AND (TransType = 0 OR TransType = 1) -- exclude freight & misc records
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderWorksheet_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderWorksheet_proc';

