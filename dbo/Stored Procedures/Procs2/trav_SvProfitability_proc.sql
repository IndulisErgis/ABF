
--PET:http://webfront:801/view.php?id=244597

CREATE PROCEDURE dbo.trav_SvProfitability_proc
@TechnicianIDFrom pEmpID = NULL, 
@TechnicianIDThru pEmpID = NULL, 
@CompletedDateFrom datetime = NULL, 
@CompletedDateThru datetime = NULL, 
@SortBy int = 0, -- 0 = Customer ID, 1 = Order Number, 2 = Technician ID, 3 = Completed Date
@IncludeWorkToDoDetail bit = 0, 
@IncludeTransactionDetail bit = 0

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
--	WHERE o.CustID IS NOT NULL AND (d.[Status] = 2 OR d.[Status] = 3)
--	UNION ALL
--	SELECT o.WorkOrderNo, o.OrderDate, o.CustID, o.SiteID, o.Region, o.Country, o.PostalCode, o.TerrId, o.Phone1
--		, o.Email, o.Rep1Id, o.Rep2Id, o.BillingType, o.CustomerPoNumber, o.PODate, o.OriginalWorkOrder
--		, o.ProjectID AS ProjectName, o.PhaseId, o.TaskId, d.ID AS DispatchID, d.DispatchNo, d.[Description]
--		, 3 AS [Status], d.EquipmentDescription, d.BillingType AS DispatchBillingType, d.BillToID, d.RequestedDate
--		, d.RequestedTechID, d.CancelledYN, 0 AS HoldYN, d.EntryDate, d.[Counter], d.LocID 
--	FROM dbo.tblSvHistoryWorkOrder o 
--		INNER JOIN dbo.tblSvHistoryWorkOrderDispatch d ON o.ID = d.WorkOrderID 
--	WHERE o.CustID IS NOT NULL
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
			WHEN 1 THEN CAST(WorkOrderNo AS nvarchar) 
			WHEN 2 THEN CAST(r.TechID AS nvarchar) 
			WHEN 3 THEN CONVERT(nvarchar(8), r.ActivityDateTime, 112) 
			END AS GrpId1
		, WorkOrderNo AS OrderNo, DispatchNo, w.CustID + ' - ' + c.CustName AS CustIDName, w.SiteID
		, a.ActivityDateTime AS ReceivedDateTime
		, r.ActivityDateTime AS CompletedDateTime, r.TechID AS CompletedTechID
		, ISNULL(LaborCost, 0) AS LaborCost, ISNULL(PartsCost, 0) AS PartsCost
		, ISNULL(TotalCost, 0) AS TotalCost
		, ISNULL(LaborBilled, 0) AS LaborBilled, ISNULL(PartsBilled, 0) AS PartsBilled
		, ISNULL(TotalBilled, 0) AS TotalBilled
		, ISNULL(LaborProfit, 0) AS LaborProfit, ISNULL(PartsProfit, 0) AS PartsProfit
		, ISNULL(TotalProfit, 0) AS TotalProfit 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 0 GROUP BY DispatchID
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
					, SUM(CASE TransType WHEN 0 THEN d.CostExt ELSE 0 END) AS LaborCost
					, SUM(CASE TransType WHEN 1 THEN d.CostExt ELSE 0 END) AS PartsCost
					, SUM(d.CostExt) AS TotalCost
					, SUM(CASE TransType WHEN 0 THEN d.PriceExt ELSE 0 END) AS LaborBilled
					, SUM(CASE TransType WHEN 1 THEN d.PriceExt ELSE 0 END) AS PartsBilled
					, SUM(d.PriceExt) AS TotalBilled
					, SUM(CASE TransType WHEN 0 THEN d.PriceExt ELSE 0 END) 
						- SUM(CASE TransType WHEN 0 THEN d.CostExt ELSE 0 END) AS LaborProfit
					, SUM(CASE TransType WHEN 1 THEN d.PriceExt ELSE 0 END) 
						- SUM(CASE TransType WHEN 1 THEN d.CostExt ELSE 0 END) AS PartsProfit
					, SUM(d.PriceExt) - SUM(d.CostExt) AS TotalProfit 
				FROM dbo.tblSvWorkOrderTrans t INNER JOIN #Temp x ON t.DispatchID = x.DispatchID 
					INNER JOIN dbo.tblSvInvoiceDetail d ON t.ID = d.WorkOrderTransID
				WHERE t.TransType = 0 OR t.TransType = 1 -- exclude freight & misc records 
				GROUP BY t.DispatchID
			) z ON tmp.DispatchID = z.DispatchID 
	WHERE d.[Status] = 2 -- Billed
	UNION ALL
	SELECT d.ID AS DispatchID
		, CASE @SortBy 
			WHEN 0 THEN CASE WHEN ISNULL(w.CustID, '') = '' THEN w.SiteID ELSE w.CustID END 
			WHEN 1 THEN CAST(WorkOrderNo AS nvarchar) 
			WHEN 2 THEN CAST(r.TechID AS nvarchar) 
			WHEN 3 THEN CONVERT(nvarchar(8), r.ActivityDateTime, 112) 
			END AS GrpId1
		, WorkOrderNo AS OrderNo, DispatchNo, w.CustID + ' - ' + c.CustName AS CustIDName, w.SiteID
		, a.ActivityDateTime AS ReceivedDateTime
		, r.ActivityDateTime AS CompletedDateTime, r.TechID AS CompletedTechID
		, ISNULL(LaborCost, 0) AS LaborCost, ISNULL(PartsCost, 0) AS PartsCost
		, ISNULL(TotalCost, 0) AS TotalCost
		, ISNULL(LaborBilled, 0) AS LaborBilled, ISNULL(PartsBilled, 0) AS PartsBilled
		, ISNULL(TotalBilled, 0) AS TotalBilled
		, ISNULL(LaborProfit, 0) AS LaborProfit, ISNULL(PartsProfit, 0) AS PartsProfit
		, ISNULL(TotalProfit, 0) AS TotalProfit 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 0 GROUP BY DispatchID
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
					, SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS LaborCost
					, SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS PartsCost
					, SUM(COALESCE(d.CostExt, t.CostExt)) AS TotalCost
					, SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) AS LaborBilled
					, SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) AS PartsBilled
					, SUM(COALESCE(d.PriceExt, t.PriceExt)) AS TotalBilled
					, SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) 
						- SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS LaborProfit
					, SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) 
						- SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS PartsProfit
					, SUM(COALESCE(d.PriceExt, t.PriceExt)) - SUM(COALESCE(d.CostExt, t.CostExt)) AS TotalProfit 
				FROM dbo.tblSvWorkOrderDispatch w 
					INNER JOIN #Temp x ON w.ID = x.DispatchID 
					INNER JOIN dbo.tblSvWorkOrderTrans t  ON w.ID = t.DispatchID 
					LEFT JOIN dbo.tblArHistHeader h ON w.SourceId = h.SourceId 
					LEFT JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun 
						AND h.TransId = d.TransID AND t.EntryNum = d.EntryNum 
				WHERE t.TransType = 0 OR t.TransType = 1 -- exclude freight & misc records 
				GROUP BY t.DispatchID
			) z ON tmp.DispatchID = z.DispatchID 
	WHERE d.[Status] = 3 -- Posted
	UNION ALL
	SELECT d.ID AS DispatchID
		, CASE @SortBy 
			WHEN 0 THEN CASE WHEN ISNULL(w.CustID, '') = '' THEN w.SiteID ELSE w.CustID END 
			WHEN 1 THEN CAST(WorkOrderNo AS nvarchar) 
			WHEN 2 THEN CAST(r.TechID AS nvarchar) 
			WHEN 3 THEN CONVERT(nvarchar(8), r.ActivityDateTime, 112) 
			END AS GrpId1
		, WorkOrderNo AS OrderNo, DispatchNo, w.CustID + ' - ' + c.CustName AS CustIDName, w.SiteID
		, a.ActivityDateTime AS ReceivedDateTime
		, r.ActivityDateTime AS CompletedDateTime, r.TechID AS CompletedTechID
		, ISNULL(LaborCost, 0) AS LaborCost, ISNULL(PartsCost, 0) AS PartsCost
		, ISNULL(TotalCost, 0) AS TotalCost
		, ISNULL(LaborBilled, 0) AS LaborBilled, ISNULL(PartsBilled, 0) AS PartsBilled
		, ISNULL(TotalBilled, 0) AS TotalBilled
		, ISNULL(LaborProfit, 0) AS LaborProfit, ISNULL(PartsProfit, 0) AS PartsProfit
		, ISNULL(TotalProfit, 0) AS TotalProfit 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvHistoryWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvHistoryWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 0 GROUP BY DispatchID
			) s ON d.ID = s.DispatchID 
		LEFT JOIN dbo.tblSvHistoryWorkOrderActivity a ON s.ActivityID = a.ID
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 4 GROUP BY DispatchID
			) t ON d.ID = t.DispatchID 
		LEFT JOIN dbo.tblSvHistoryWorkOrderActivity r ON t.ActivityID = r.ID
		LEFT JOIN dbo.tblArCust c ON w.CustID = c.CustId
		LEFT JOIN
			(
				SELECT t.DispatchID
					, SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS LaborCost
					, SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS PartsCost
					, SUM(COALESCE(d.CostExt, t.CostExt)) AS TotalCost
					, SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) AS LaborBilled
					, SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) AS PartsBilled
					, SUM(COALESCE(d.PriceExt, t.PriceExt)) AS TotalBilled
					, SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) 
						- SUM(CASE t.TransType WHEN 0 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS LaborProfit
					, SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.PriceExt, t.PriceExt) ELSE 0 END) 
						- SUM(CASE t.TransType WHEN 1 THEN COALESCE(d.CostExt, t.CostExt) ELSE 0 END) AS PartsProfit
					, SUM(COALESCE(d.PriceExt, t.PriceExt)) - SUM(COALESCE(d.CostExt, t.CostExt)) AS TotalProfit 
				FROM dbo.tblSvHistoryWorkOrderDispatch w 
					INNER JOIN #Temp x ON w.ID = x.DispatchID 
					INNER JOIN dbo.tblSvHistoryWorkOrderTrans t  ON w.ID = t.DispatchID 
					LEFT JOIN dbo.tblArHistHeader h ON w.SourceId = h.SourceId 
					LEFT JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun 
						AND h.TransId = d.TransID AND t.EntryNum = d.EntryNum 
				WHERE t.TransType = 0 OR t.TransType = 1 -- exclude freight & misc records 
				GROUP BY t.DispatchID
			) z ON tmp.DispatchID = z.DispatchID

	-- Work To Do resultset
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

	-- Transaction resultset (Table2) part & labor records only
	SELECT t.DispatchID, t.TransType, t.ResourceID, ISNULL(d.CostExt, 0) AS Cost, ISNULL(d.PriceExt, 0) AS Billed
		, ISNULL(d.PriceExt, 0) - ISNULL(d.CostExt, 0) AS Profit
		, CASE ISNULL(d.PriceExt, 0) WHEN 0 THEN 0 ELSE (ISNULL(d.PriceExt, 0) - ISNULL(d.CostExt, 0)) * 100.00 
			/ ISNULL(d.PriceExt, 0) END AS Pct 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch x ON tmp.DispatchID = x.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON x.WorkOrderID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON x.ID = t.DispatchID
		INNER JOIN dbo.tblSvInvoiceDetail d ON t.ID = d.WorkOrderTransID 
		INNER JOIN dbo.tblSvInvoiceHeader h ON d.TransId = h.TransId  
	WHERE @IncludeTransactionDetail <> 0 AND x.[Status] = 2 -- Billed 
		AND (t.TransType = 0 OR t.TransType = 1) -- exclude freight & misc records
		AND h.VoidYN = 0
	UNION ALL
	SELECT t.DispatchID, t.TransType, t.ResourceID
		, COALESCE(d.CostExt, t.CostExt) AS Cost, COALESCE(d.PriceExt, t.PriceExt) AS Billed
		, COALESCE(d.PriceExt, t.PriceExt) - COALESCE(d.CostExt, t.CostExt) AS Profit
		, CASE COALESCE(d.PriceExt, t.PriceExt) WHEN 0 THEN 0 
			ELSE (COALESCE(d.PriceExt, t.PriceExt) - COALESCE(d.CostExt, t.CostExt)) * 100.00 
				/ COALESCE(d.PriceExt, t.PriceExt) END AS Pct 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch x ON tmp.DispatchID = x.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON x.WorkOrderID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON x.ID = t.DispatchID 
		LEFT JOIN dbo.tblArHistHeader h ON x.SourceId = h.SourceId 
		LEFT JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun 
			AND h.TransId = d.TransID AND t.EntryNum = d.EntryNum 
	WHERE @IncludeTransactionDetail <> 0 AND x.[Status] = 3 -- Posted 
		AND (t.TransType = 0 OR t.TransType = 1) -- exclude freight & misc records
		AND ISNULL(h.VoidYn, 0) = 0
	UNION ALL
	SELECT t.DispatchID, t.TransType, t.ResourceID
		, COALESCE(d.CostExt, t.CostExt) AS Cost, COALESCE(d.PriceExt, t.PriceExt) AS Billed
		, COALESCE(d.PriceExt, t.PriceExt) - COALESCE(d.CostExt, t.CostExt) AS Profit
		, CASE COALESCE(d.PriceExt, t.PriceExt) WHEN 0 THEN 0 
			ELSE (COALESCE(d.PriceExt, t.PriceExt) - COALESCE(d.CostExt, t.CostExt)) * 100.00 
				/ COALESCE(d.PriceExt, t.PriceExt) END AS Pct 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvHistoryWorkOrderDispatch x ON tmp.DispatchID = x.ID 
		INNER JOIN dbo.tblSvHistoryWorkOrder w ON x.WorkOrderID = w.ID 
		INNER JOIN dbo.tblSvHistoryWorkOrderTrans t ON x.ID = t.DispatchID 
		LEFT JOIN dbo.tblArHistHeader h ON x.SourceId = h.SourceId 
		LEFT JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun 
			AND h.TransId = d.TransID AND t.EntryNum = d.EntryNum 
	WHERE @IncludeTransactionDetail <> 0 AND (t.TransType = 0 OR t.TransType = 1) -- exclude freight & misc records
		AND ISNULL(h.VoidYn, 0) = 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvProfitability_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvProfitability_proc';

