
CREATE PROCEDURE dbo.trav_SvServiceOrder_proc
@ScheduledTechnicianFrom pEmpID = NULL, 
@ScheduledTechnicianThru pEmpID = NULL, 
@ScheduledDateFrom datetime = NULL, 
@ScheduledDateThru datetime = NULL, 
@PrintEquipmentHistory bit, 
@PrintSerializedLottedDetail bit, 
@PrintOneCopyPerTechnician bit, 
@PrintAdditionalDescription bit, 
@PrintWarrantyDetail bit

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpServiceOrderDispatchList(DispatchID bigint NOT NULL PRIMARY KEY CLUSTERED (DispatchID))
--INSERT INTO #tmpServiceOrderDispatchList (DispatchID) 
--SELECT DispatchID 
--FROM 
--(
-- SELECT o.WorkOrderNo, o.OrderDate, o.SiteID, o.Region, o.Country, o.PostalCode, o.Phone1, o.Email
--	, o.OriginalWorkOrder, o.ProjectDetailID, d.ID AS DispatchID, d.DispatchNo, d.[Description], d.[Status]
--	, d.EquipmentDescription, d.RequestedDate, d.RequestedTechID, d.CancelledYN, d.HoldYN
--	, d.EntryDate, d.[Counter], d.LocID 
-- FROM dbo.tblSvWorkOrder o 
--  INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
-- WHERE CustID IS NULL AND d.[Status] = 0 AND d.CancelledYN = 0 AND d.HoldYN = 0
--) tmp

	CREATE TABLE #Temp
	(
		[Counter] [int] IDENTITY (1, 1) NOT NULL, 
		DispatchID bigint NOT NULL, 
		EquipmentID bigint NULL
	)

	CREATE TABLE #TempDistinctEquipment
	(
		EquipmentID bigint NULL
	)

	CREATE TABLE #TempDistinctDispatch
	(
		DispatchID bigint NOT NULL
	)

	CREATE TABLE #TempWarranty(
	EquipmentID bigint,
	DispatchId bigint,
	CoverageType tinyint,
	StartDate datetime,
	EndDate datetime,
	labelWarranty nvarchar(100),
	[Status] tinyint)

	CREATE TABLE #TempWarrantyAvailable(
	EquipmentID bigint,
	DispatchId bigint,
	CoverageType tinyint,
	StartDate datetime,
	EndDate datetime,
	labelWarranty nvarchar(100),
	[Status] tinyint)


	DECLARE  @WarrantyCount int

	IF (@PrintOneCopyPerTechnician = 0)
	BEGIN
		IF (@ScheduledDateFrom IS NULL AND @ScheduledDateThru IS NULL 
			AND @ScheduledTechnicianFrom IS NULL AND @ScheduledTechnicianThru IS NULL)
		BEGIN
			INSERT INTO #Temp(DispatchID, EquipmentID) 
			SELECT tmp.DispatchID, d.EquipmentID 
			FROM #tmpServiceOrderDispatchList tmp 
				INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
				INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			ORDER BY WorkOrderNo, DispatchNo
		END
		ELSE
		BEGIN
		INSERT INTO #Temp(DispatchID, EquipmentID) 
			SELECT tmp.DispatchID, d.EquipmentID  
			FROM #tmpServiceOrderDispatchList tmp 
				INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
				INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
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
			ORDER BY WorkOrderNo, DispatchNo
		END
	END
	ELSE
	BEGIN
		IF (@ScheduledDateFrom IS NULL AND @ScheduledDateThru IS NULL 
			AND @ScheduledTechnicianFrom IS NULL AND @ScheduledTechnicianThru IS NULL)
		BEGIN
			INSERT INTO #Temp(DispatchID, EquipmentID) 
			SELECT tmp.DispatchID, d.EquipmentID 
			FROM #tmpServiceOrderDispatchList tmp 
				INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
				INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
				LEFT JOIN (SELECT * FROM dbo.tblSvWorkOrderActivity WHERE ActivityType = 1) a 
					ON tmp.DispatchID = a.DispatchID 
			ORDER BY WorkOrderNo, DispatchNo
		END
		ELSE
		BEGIN
		INSERT INTO #Temp(DispatchID, EquipmentID) 
			SELECT tmp.DispatchID, d.EquipmentID 
			FROM #tmpServiceOrderDispatchList tmp 
				INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
				INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
				INNER JOIN tblSvWorkOrderActivity a ON tmp.DispatchID = a.DispatchID 
			WHERE a.ActivityType = 1 
							AND (@ScheduledDateFrom IS NULL OR a.ActivityDateTime >= @ScheduledDateFrom) 
							AND (@ScheduledDateThru IS NULL OR a.ActivityDateTime <= @ScheduledDateThru) 
							AND (@ScheduledTechnicianFrom IS NULL OR a.TechID >= @ScheduledTechnicianFrom) 
							AND (@ScheduledTechnicianThru IS NULL OR a.TechID <= @ScheduledTechnicianThru) 
			ORDER BY WorkOrderNo, DispatchNo
		END
	END

	INSERT INTO #TempDistinctEquipment(EquipmentID) 
	SELECT DISTINCT EquipmentID FROM #Temp

	INSERT INTO #TempDistinctDispatch(DispatchID) 
	SELECT DISTINCT DispatchID FROM #Temp	

	-- main report resultset (Table)
	SELECT tmp.[Counter], d.ID AS DispatchID, d.[Description], WorkOrderNo AS ServiceOrderNo, w.SiteID AS LocationSiteID
		, w.Attention AS LocationAttention, w.Address1 AS LocationAddress1, w.Address2 AS LocationAddress2
		, w.City AS LocationCity, w.Region AS LocationRegion, w.PostalCode AS LocationPostalCode
		, w.Country AS LocationCountry, w.Phone1 AS Phone
		, DispatchNo, d.EquipmentID, d.EquipmentDescription, e.EquipmentNo, e.ItemID, e.SerialNumber, e.TagNumber
		, d.Status 
		, d.StatusID
		, ats.Description AS DispatchStatus
		, RequestedAMPM, RequestedTechID, a.ActivityDateTime AS ReceivedDateTime, d.[Priority]
		, WorkOrderNo + '/' + CAST(DispatchNo AS nvarchar) AS ServiceOrderDispatchNo 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN dbo.tblArCust c2 ON w.CustID = c2.CustId 
		LEFT JOIN dbo.tblSvEquipment e ON d.EquipmentID = e.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 0 GROUP BY DispatchID
			) r ON d.ID = r.DispatchID 
		LEFT JOIN dbo.tblSvWorkOrderActivity a ON r.ActivityID = a.ID
		LEFT JOIN dbo.tblSvActivityStatus ats ON d.StatusID = ats.ID

	-- Service Contract resultset (Table1)
	SELECT DISTINCT s.EquipmentID, s.CoverageType, h.ContractNo, h.EndDate 
	,  CASE when  CONVERT(date, w.OrderDate) BETWEEN CONVERT(date, h.StartDate) AND CONVERT(date, h.EndDate)  THEN 0 Else 1 END AS [Status], DispatchID
	FROM #TempDistinctEquipment tmp 
		INNER JOIN #Temp t ON tmp.EquipmentID = t.EquipmentID
		INNER JOIN dbo.tblSvServiceContractDetail s ON tmp.EquipmentID = s.EquipmentID 
		INNER JOIN dbo.tblSvServiceContractHeader h ON s.ContractID = h.ID
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON d.EquipmentID = s.EquipmentID AND d.ID = t.DispatchID
		INNER JOIN dbo.tblSvWorkOrder w ON w.ID = d.WorkOrderID 

	-- Work To Do resultset (Table2)
	SELECT w.DispatchID, WorkToDoID, [Description], SkillLevel
		, EstimatedTime / 3600.00 AS EstimatedTime, w.ID 
	FROM dbo.tblSvWorkOrderDispatchWorkToDo w 
		INNER JOIN #TempDistinctDispatch tmp ON w.DispatchID = tmp.DispatchID

	-- Activity resultset (Table3)
	SELECT a.DispatchID, ActivityType, ActivityDateTime
		, TechID, EntryDate, EnteredBy 
	FROM dbo.tblSvWorkOrderActivity a 
		INNER JOIN #TempDistinctDispatch tmp ON a.DispatchID = tmp.DispatchID 
	WHERE a.ActivityType = 1

	-- Transaction resultset (Table4)
	SELECT t.ID AS TransID, t.DispatchID, t.TransType, ResourceID
		, QtyEstimated, QtyUsed, Unit, t.[Description]
		, CASE WHEN @PrintAdditionalDescription = 1 THEN t.AdditionalDescription 
			ELSE NULL END AS AdditionalDescription 
		, UnitCost, CostExt AS ExtCost, TransDate 
	FROM dbo.tblSvWorkOrderDispatch d 
		INNER JOIN #TempDistinctDispatch tmp ON d.ID = tmp.DispatchID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
	WHERE (t.TransType = 0 OR t.TransType = 1) -- exclude freight & misc records

	-- Transaction Lotted Detail resultset (Table5)
	SELECT TransID, LotNum, e.QtyUsed 
	FROM dbo.tblSvWorkOrderDispatch d 
		INNER JOIN #TempDistinctDispatch tmp ON d.ID = tmp.DispatchID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
		INNER JOIN dbo.tblSvWorkOrderTransExt e ON t.ID = e.TransID 
	WHERE @PrintSerializedLottedDetail <> 0 AND (TransType = 0 OR TransType = 1) -- exclude freight & misc records

	-- Transaction Serialized Detail resultset (Table6)
	SELECT TransID, LotNum, SerNum 
	FROM dbo.tblSvWorkOrderDispatch d 
		INNER JOIN #TempDistinctDispatch tmp ON d.ID = tmp.DispatchID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
		INNER JOIN dbo.tblSvWorkOrderTransSer s ON t.ID = s.TransID 
	WHERE @PrintSerializedLottedDetail <> 0 AND (TransType = 0 OR TransType = 1) -- exclude freight & misc records

	-- Equipment History resultset (Table7)
	SELECT TOP 3 d.ID AS DispatchID, d.DispatchNo, w.WorkOrderNo AS ServiceOrderNo, CAST(3 AS tinyint) AS [Status]
		, a.ActivityDateTime AS CompletedDate, a.TechID, d.EquipmentID 
	FROM dbo.tblSvHistoryWorkOrderDispatch d 
		INNER JOIN #TempDistinctEquipment tmp ON d.EquipmentID = tmp.EquipmentID 
		INNER JOIN dbo.tblSvHistoryWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvHistoryWorkOrderActivity 
				WHERE ActivityType = 4 GROUP BY DispatchID
			) r ON d.ID = r.DispatchID 
		LEFT JOIN dbo.tblSvHistoryWorkOrderActivity a ON r.ActivityID = a.ID 
	WHERE @PrintEquipmentHistory <> 0 
	ORDER BY d.EntryDate DESC

	-- Equipment History Work To Do Detail resultset (Table8)
	SELECT w.DispatchID, WorkToDoID, w.[Description], SkillLevel
		, EstimatedTime / 3600.00 AS EstimatedTime, w.ID 
	FROM dbo.tblSvHistoryWorkOrderDispatch d 
		INNER JOIN #TempDistinctEquipment tmp ON d.EquipmentID = tmp.EquipmentID 
		INNER JOIN dbo.tblSvHistoryWorkOrderDispatchWorkToDo w ON d.ID = w.DispatchID 
		INNER JOIN 
		(
			SELECT TOP 3 d.ID AS DispatchID 
			FROM dbo.tblSvHistoryWorkOrderDispatch d 
				INNER JOIN #TempDistinctEquipment tmp ON d.EquipmentID = tmp.EquipmentID 
				INNER JOIN dbo.tblSvHistoryWorkOrder w ON d.WorkOrderID = w.ID 
				LEFT JOIN 
					(
						SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvHistoryWorkOrderActivity 
						WHERE ActivityType = 4 GROUP BY DispatchID
					) r ON d.ID = r.DispatchID 
				LEFT JOIN dbo.tblSvHistoryWorkOrderActivity a ON r.ActivityID = a.ID 
			WHERE @PrintEquipmentHistory <> 0 
			ORDER BY d.EntryDate DESC
		) x ON d.ID = x.DispatchID

	-- Warranty resultset (Table9)
	INSERT INTO #TempWarrantyAvailable(EquipmentID,DispatchId,CoverageType,StartDate,EndDate,labelWarranty,[Status])
	SELECT w.EquipmentID, DispatchId,w.CoverageType , StartDate, EndDate 
	, 'Warranties Available' AS labelWarranty
	,  CASE WHEN  CONVERT(date, wo.OrderDate) BETWEEN CONVERT(date, w.StartDate) AND CONVERT(date, w.EndDate)  
			THEN 0
			ELSE CASE WHEN e.SiteYN =0 THEN 3 ELSE 1 END 
	   END AS [Status]	
	FROM #TempDistinctEquipment tmp 
		INNER JOIN #Temp t ON tmp.EquipmentID = t.EquipmentID
		INNER JOIN dbo.tblSvEquipmentWarranty w ON tmp.EquipmentID = w.EquipmentID 		
		INNER JOIN dbo.tblsvWorkOrderDispatch d ON d.EquipmentID=w.EquipmentID AND d.ID = t.DispatchID
		INNER JOIN dbo.tblSvWorkOrder wo  ON d.WorkOrderID=wo.id	
		INNER JOIN tblSvEquipment e ON e.ID = d.EquipmentID
	WHERE @PrintWarrantyDetail = 1
	
	INSERT INTO #TempWarranty(EquipmentID,DispatchId,CoverageType,StartDate,EndDate,labelWarranty,[Status])
	SELECT w.EquipmentID,c.DispatchId, w.CoverageType  AS CoverageType , StartDate, EndDate 
	, 'Warranty' AS labelWarranty
	,  CASE when  CONVERT(date, wo.OrderDate) BETWEEN CONVERT(date, w.StartDate) AND CONVERT(date, w.EndDate)  THEN 0 Else 1 END AS [Status]
	FROM #TempDistinctEquipment tmp 
		INNER JOIN #Temp t ON tmp.EquipmentID = t.EquipmentID
		INNER JOIN dbo.tblSvEquipmentWarranty w ON tmp.EquipmentID = w.EquipmentID 
		INNER JOIN dbo.tblSvWorkOrderDispatchCoverage c ON c.CoveredById = w.ID
		INNER JOIN dbo.tblsvWorkOrderDispatch d ON d.id=c.DispatchID AND d.EquipmentID=w.EquipmentID AND d.ID = t.DispatchID
		INNER JOIN dbo.tblSvWorkOrder wo  ON d.WorkOrderID=wo.id		  
	WHERE @PrintWarrantyDetail = 1  AND c.CoveredByType =0
	
	
	SELECT @WarrantyCount  =  count(*) FROM #TempWarrantyAvailable

	IF @WarrantyCount > 0
	BEGIN
		DELETE #TempWarrantyAvailable
		FROM #TempWarrantyAvailable t1
		INNER JOIN #TempWarranty t2 ON t1.DispatchId = t2.DispatchId AND t1.EquipmentID = t2.EquipmentID
	END

	SELECT * from #TempWarranty
	UNION All
	SELECT * FROM #TempWarrantyAvailable

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrder_proc';

