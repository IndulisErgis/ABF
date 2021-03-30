
CREATE PROCEDURE dbo.trav_SvProductivity_proc
@TechnicianIDFrom pEmpID = NULL, 
@TechnicianIDThru pEmpID = NULL, 
@CompletedDateFrom datetime = NULL, 
@CompletedDateThru datetime = NULL, 
@SortBy int = 0, -- 0 = Customer ID, 1 = Order Number, 2 = Technician ID, 3 = Completed Date
@IncludeWorkToDoDetail bit = 0, 
@IncludeLaborDetail bit = 0

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpWorkOrderDispatchList(DispatchID bigint NOT NULL PRIMARY KEY CLUSTERED (DispatchID))
--INSERT INTO #tmpWorkOrderDispatchList (DispatchID) 
--SELECT DispatchID 
--FROM 
--(
--	SELECT o.WorkOrderNo, o.OrderDate, o.CustID, o.SiteID, o.Region, o.Country, o.PostalCode, o.TerrId, o.Phone1
--		, o.Email, o.Rep1Id, o.Rep2Id, o.BillingType, o.CustomerPoNumber, o.PODate, o.OriginalWorkOrder
--		, p.ProjectName, a.PhaseId, a.TaskId, d.ID AS DispatchID, d.DispatchNo, d.[Description]
--		, d.[Status], d.EquipmentDescription, d.BillingType AS DispatchBillingType, d.BillToID, d.RequestedDate
--		, d.RequestedTechID, d.CancelledYN, d.HoldYN, d.EntryDate, d.[Counter], d.LocID 
--	FROM dbo.tblSvWorkOrder o 
--		INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
--		LEFT JOIN dbo.tblPcProjectDetail a ON o.ProjectDetailID = a.Id 
--		LEFT JOIN dbo.tblPcProject p ON a.ProjectId = p.Id 
--	WHERE (d.[Status] = 2 OR d.[Status] = 3)
--	UNION ALL
--	SELECT o.WorkOrderNo, o.OrderDate, o.CustID, o.SiteID, o.Region, o.Country, o.PostalCode, o.TerrId, o.Phone1
--		, o.Email, o.Rep1Id, o.Rep2Id, o.BillingType, o.CustomerPoNumber, o.PODate, o.OriginalWorkOrder
--		, o.ProjectID AS ProjectName, o.PhaseId, o.TaskId, d.ID AS DispatchID, d.DispatchNo, d.[Description]
--		, 3 AS [Status], d.EquipmentDescription, d.BillingType AS DispatchBillingType, d.BillToID, d.RequestedDate
--		, d.RequestedTechID, d.CancelledYN, 0 AS HoldYN, d.EntryDate, d.[Counter], d.LocID 
--	FROM dbo.tblSvHistoryWorkOrder o 
--		INNER JOIN dbo.tblSvHistoryWorkOrderDispatch d ON o.ID = d.WorkOrderID
--) tmp --{0}

	CREATE TABLE #Temp
	(
		DispatchID bigint NOT NULL
	)

		IF (@CompletedDateFrom IS NULL AND @CompletedDateThru IS NULL 
			AND @TechnicianIDFrom IS NULL AND @TechnicianIDThru IS NULL)
		BEGIN
			INSERT INTO #Temp(DispatchID) 
			SELECT DispatchID 
			FROM #tmpWorkOrderDispatchList
		END
		ELSE
		BEGIN
		INSERT INTO #Temp(DispatchID) 
			SELECT tmp.DispatchID 
			FROM #tmpWorkOrderDispatchList tmp 
				INNER JOIN 
					(
						SELECT DispatchID FROM dbo.tblSvWorkOrderActivity a 
						WHERE ActivityType = 4 
							AND (@CompletedDateFrom IS NULL OR a.ActivityDateTime >= @CompletedDateFrom) 
							AND (@CompletedDateThru IS NULL OR a.ActivityDateTime < DATEADD(DAY, 1, @CompletedDateThru)) 
							AND (@TechnicianIDFrom IS NULL OR a.TechID >= @TechnicianIDFrom) 
							AND (@TechnicianIDThru IS NULL OR a.TechID <= @TechnicianIDThru) 
						GROUP BY DispatchID
						UNION ALL
						SELECT DispatchID FROM dbo.tblSvHistoryWorkOrderActivity a 
						WHERE ActivityType = 4 
							AND (@CompletedDateFrom IS NULL OR a.ActivityDateTime >= @CompletedDateFrom) 
							AND (@CompletedDateThru IS NULL OR a.ActivityDateTime < DATEADD(DAY, 1, @CompletedDateThru)) 
							AND (@TechnicianIDFrom IS NULL OR a.TechID >= @TechnicianIDFrom) 
							AND (@TechnicianIDThru IS NULL OR a.TechID <= @TechnicianIDThru) 
						GROUP BY DispatchID
					) a  ON tmp.DispatchID = a.DispatchID 
		END

	-- main report resultset (Table)
	SELECT d.ID AS DispatchID
		, CASE @SortBy 
			WHEN 0 THEN CASE WHEN ISNULL(w.CustID, '') = '' THEN w.SiteID ELSE w.CustID END 
			WHEN 1 THEN CAST(WorkOrderNo AS varchar) 
			WHEN 2 THEN CAST(r.TechID AS varchar) 
			WHEN 3 THEN CONVERT(nvarchar(8), r.ActivityDateTime, 112) 
			END AS GrpId1
		, WorkOrderNo AS OrderNo, DispatchNo, w.CustID + ' - ' + c.CustName AS CustIDName, w.SiteID
		, a.ActivityDateTime AS ArriveStartDateTime
		, r.ActivityDateTime AS CompletedDateTime, r.TechID AS CompletedTechID
		, ISNULL(EstUnits, 0) AS Estimate, ISNULL(ActUnits, 0) AS Actual
		, ISNULL(CASE EstUnits WHEN 0 THEN 0 ELSE (ActUnits - EstUnits) * 100.00 / EstUnits END, 0) AS PctVar 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 3 GROUP BY DispatchID
			) s ON d.ID = s.DispatchID 
		LEFT JOIN dbo.tblSvWorkOrderActivity a ON s.ActivityID = a.ID
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 4 GROUP BY DispatchID
			) t ON d.ID = t.DispatchID 
		LEFT JOIN dbo.tblSvWorkOrderActivity r ON t.ActivityID = r.ID
		LEFT JOIN dbo.tblArCust c ON w.CustID = c.CustId
		LEFT JOIN
			(
				SELECT t.DispatchID
					, SUM(QtyEstimated) AS EstUnits
					, SUM(QtyUsed) AS ActUnits 
				FROM dbo.tblSvWorkOrderTrans t INNER JOIN #Temp x ON t.DispatchID = x.DispatchID 
				WHERE t.TransType = 0 -- include labor records only 
				GROUP BY t.DispatchID
			) z ON tmp.DispatchID = z.DispatchID
	UNION ALL
	SELECT d.ID AS DispatchID
		, CASE @SortBy 
			WHEN 0 THEN CASE WHEN ISNULL(w.CustID, '') = '' THEN w.SiteID ELSE w.CustID END 
			WHEN 1 THEN CAST(WorkOrderNo AS varchar) 
			WHEN 2 THEN CAST(r.TechID AS varchar) 
			WHEN 3 THEN CONVERT(nvarchar(8), r.ActivityDateTime, 112) 
			END AS GrpId1
		, WorkOrderNo AS OrderNo, DispatchNo, w.CustID + ' - ' + c.CustName AS CustIDName, w.SiteID
		, a.ActivityDateTime AS ArriveStartDateTime
		, r.ActivityDateTime AS CompletedDateTime, r.TechID AS CompletedTechID
		, ISNULL(EstUnits, 0) AS Estimate, ISNULL(ActUnits, 0) AS Actual
		, ISNULL(CASE EstUnits WHEN 0 THEN 0 ELSE (ActUnits - EstUnits) * 100.00 / EstUnits END, 0) AS PctVar 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvHistoryWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvHistoryWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvHistoryWorkOrderActivity 
				WHERE ActivityType = 3 GROUP BY DispatchID
			) s ON d.ID = s.DispatchID 
		LEFT JOIN dbo.tblSvHistoryWorkOrderActivity a ON s.ActivityID = a.ID
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvHistoryWorkOrderActivity 
				WHERE ActivityType = 4 GROUP BY DispatchID
			) t ON d.ID = t.DispatchID 
		LEFT JOIN dbo.tblSvHistoryWorkOrderActivity r ON t.ActivityID = r.ID
		LEFT JOIN dbo.tblArCust c ON w.CustID = c.CustId
		LEFT JOIN
			(
				SELECT t.DispatchID
					, SUM(QtyEstimated) AS EstUnits
					, SUM(QtyUsed) AS ActUnits 
				FROM dbo.tblSvHistoryWorkOrderTrans t INNER JOIN #Temp x ON t.DispatchID = x.DispatchID 
				WHERE t.TransType = 0 -- include labor records only 
				GROUP BY t.DispatchID
			) z ON tmp.DispatchID = z.DispatchID

	-- Work To Do resultset (Table1)
	SELECT w.DispatchID, WorkToDoID, [Description], SkillLevel
		, EstimatedTime / 3600.0 AS EstimatedTime 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatchWorkToDo w 
			ON tmp.DispatchID = w.DispatchID 
	WHERE @IncludeWorkToDoDetail <> 0
	UNION ALL
	SELECT w.DispatchID, WorkToDoID, [Description], SkillLevel
		, EstimatedTime / 3600.0 AS EstimatedTime 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvHistoryWorkOrderDispatchWorkToDo w 
			ON tmp.DispatchID = w.DispatchID 
	WHERE @IncludeWorkToDoDetail <> 0

	-- Labor resultset (Table2) labor records only
	SELECT t.DispatchID, ResourceID, LaborCode, TransDate, QtyUsed AS TimeSpent, [Description] 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON tmp.DispatchID = t.DispatchID 
	WHERE @IncludeLaborDetail <> 0 AND t.TransType = 0 -- include labor records only
	UNION ALL
	SELECT t.DispatchID, ResourceID, LaborCode, TransDate, QtyUsed AS TimeSpent, [Description] 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvHistoryWorkOrderTrans t ON tmp.DispatchID = t.DispatchID 
	WHERE @IncludeLaborDetail <> 0 AND t.TransType = 0 -- include labor records only

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvProductivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvProductivity_proc';

