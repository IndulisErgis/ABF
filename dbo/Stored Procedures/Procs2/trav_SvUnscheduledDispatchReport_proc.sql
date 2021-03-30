
CREATE PROCEDURE dbo.trav_SvUnscheduledDispatchReport_proc
@SortBy int = 0, -- 0 = Customer ID, 1 = Work Order No, 2 = Entry Date
@ViewDetail int = 0, -- 0 = Summary, 1 = Detail
@IncludeWorkToDoDetail bit = 0, 
@IncludeSerializedLottedDetail bit = 0

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpUnscheduledDispatchList(DispatchID bigint NOT NULL PRIMARY KEY CLUSTERED (DispatchID))
--INSERT INTO #tmpUnscheduledDispatchList (DispatchID) 
--SELECT DispatchID 
--FROM 
--(
--	SELECT o.WorkOrderNo, o.OrderDate, o.CustID, o.SiteID, o.Region, o.Country, o.PostalCode
--		, o.TerrId, o.Phone1, o.Email, o.Rep1Id, o.Rep2Id, o.BillingType, o.CustomerPoNumber, o.PODate
--		, o.OriginalWorkOrder, p.ProjectName, a.PhaseId, a.TaskId, d.ID AS DispatchID, d.DispatchNo, d.[Description]
--		, d.EquipmentDescription, d.BillingType AS DispatchBillingType, d.BillToID
--		, d.RequestedDate, d.RequestedTechID, d.HoldYN, d.EntryDate, d.[Counter], d.LocID 
--	FROM dbo.tblSvWorkOrder o 
--		INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
--		LEFT JOIN dbo.tblPcProjectDetail a ON o.ProjectDetailID = a.Id 
--		LEFT JOIN dbo.tblPcProject p ON a.ProjectId = p.Id
--	WHERE d.[Status] = 0 AND d.CancelledYN = 0 AND d.ID NOT IN 
--		(
--			SELECT DispatchID AS ID FROM dbo.tblSvWorkOrderActivity WHERE ActivityType = 1 
--			GROUP BY DispatchID
--		)
--) tmp --{0}

	-- Unscheduled Dispatch resultset (Table)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT d.WorkOrderID, d.ID AS DispatchID
				, CASE @SortBy 
				WHEN 0 THEN CASE WHEN ISNULL(w.CustID, '') = '' THEN w.SiteID ELSE w.CustID END 
				WHEN 1 THEN CAST(WorkOrderNo AS nvarchar) 
				WHEN 2 THEN CONVERT(nvarchar(8), d.EntryDate, 112) 
				END AS GrpId1
			, WorkOrderNo AS OrderNo, OrderDate, w.CustID, w.SiteID, Address1, Address2
			, City, Region, Country, PostalCode, DispatchNo, d.[Description]
			, EquipmentID, e.EquipmentNo, EquipmentDescription, d.BillingType AS DispatchBillingType, BillToID
			, ISNULL(EstTravel, 0) / 3600.00 AS EstTravel
			, (ISNULL(EstimatedTime, 0) + ISNULL(EstTravel, 0)) / 3600.0 AS TotalEst
			, [Counter], LocID, d.EntryDate, HoldYN
			, a.ActivityDateTime AS ReceivedDateTime
			, RequestedDate, RequestedAMPM, RequestedTechID, d.[Priority], d.StatusID, s.[Description] AS [ActivityDispatchStatus]  
		FROM #tmpUnscheduledDispatchList tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			LEFT JOIN dbo.tblSvEquipment e ON d.EquipmentID = e.ID 
			LEFT JOIN 
			(
				SELECT t.ID, t.DispatchID, t.ActivityDateTime, t.TechID 
				FROM dbo.tblSvWorkOrderActivity t 
					INNER JOIN 
					(
						SELECT x.DispatchID, MAX(ID) AS ActivityReceivedID 
						FROM #tmpUnscheduledDispatchList d 
							INNER JOIN dbo.tblSvWorkOrderActivity x ON d.DispatchID = x.DispatchID 
						WHERE ActivityType = 0 
						GROUP BY x.DispatchID
					) r 
					ON t.ID = r.ActivityReceivedID
			) a ON tmp.DispatchID = a.DispatchID 
			LEFT JOIN 
			(
				SELECT DispatchID, SUM(EstimatedTime) AS EstimatedTime 
				FROM dbo.tblSvWorkOrderDispatchWorkToDo 
				GROUP BY DispatchID
			) t ON d.ID = t.DispatchID
			LEFT JOIN dbo.tblsvActivityStatus s ON d.StatusID = s.ID
	END
	ELSE
	BEGIN
		SELECT tmp.DispatchID, w.WorkOrderNo AS OrderNo, d.DispatchNo
			, CASE @SortBy 
				WHEN 0 THEN CASE WHEN ISNULL(w.CustID, '') = '' THEN w.SiteID ELSE w.CustID END 
				WHEN 1 THEN CAST(WorkOrderNo AS nvarchar) 
				WHEN 2 THEN CONVERT(nvarchar(8), d.EntryDate, 112) 
				END AS GrpId1
			, w.CustID, w.CustID + ' - ' + c.CustName AS CustIDName, w.SiteID
			, d.EntryDate, RequestedDate, RequestedTechID 
		FROM #tmpUnscheduledDispatchList tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON w.ID = d.WorkOrderID 
		LEFT JOIN dbo.tblArCust c ON w.CustID = c.CustId 
	END

	-- Work To Do resultset (Table1)
	SELECT w.DispatchID, WorkToDoID, [Description], SkillLevel
		, EstimatedTime / 3600.0 AS EstimatedTime 
	FROM #tmpUnscheduledDispatchList tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatchWorkToDo w 
			ON tmp.DispatchID = w.DispatchID 
	WHERE @IncludeWorkToDoDetail <> 0

	-- Transaction resultset (Table2)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT t.ID AS TransID, t.DispatchID, t.WorkOrderID, t.TransType, ResourceID, t.TransDate
			, QtyEstimated, Unit, t.[Description] 
		FROM #tmpUnscheduledDispatchList tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			LEFT JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
		WHERE (t.TransType = 0 OR t.TransType = 1) -- exclude freight & misc records
	END

	-- Transaction Lotted Detail resultset (Table3)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT TransID, LotNum, e.QtyUsed, e.UnitCost 
		FROM #tmpUnscheduledDispatchList tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
			INNER JOIN dbo.tblSvWorkOrderTransExt e ON t.ID = e.TransID 
		WHERE (TransType = 0 OR TransType = 1) -- exclude freight & misc records
			AND @IncludeSerializedLottedDetail <> 0
	END

	-- Transaction Serialized Detail resultset (Table4)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT TransID, LotNum, SerNum, s.UnitCost 
		FROM #tmpUnscheduledDispatchList tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
			INNER JOIN dbo.tblSvWorkOrderTransSer s ON t.ID = s.TransID 
		WHERE (TransType = 0 OR TransType = 1) -- exclude freight & misc records
			AND @IncludeSerializedLottedDetail <> 0
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvUnscheduledDispatchReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvUnscheduledDispatchReport_proc';

