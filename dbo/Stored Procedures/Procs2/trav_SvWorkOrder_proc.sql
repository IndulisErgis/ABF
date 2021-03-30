
CREATE PROCEDURE dbo.trav_SvWorkOrder_proc
@ScheduledTechnicianFrom pEmpID = NULL, 
@ScheduledTechnicianThru pEmpID = NULL, 
@ScheduledDateFrom datetime = NULL, 
@ScheduledDateThru datetime = NULL, 
@PrintEquipmentHistory bit, 
@PrintSerializedLottedDetail bit, 
@PrintOneCopyPerTechnician bit, 
@PrintAdditionalDescription bit, 
@PrintWarrantyDetail bit,
@PrintServiceContract bit 

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpWorkOrderDispatchList(DispatchID bigint NOT NULL PRIMARY KEY CLUSTERED (DispatchID))
--INSERT INTO #tmpWorkOrderDispatchList (DispatchID) 
--SELECT DispatchID 
--FROM 
--(
-- SELECT o.ID, o.WorkOrderNo, o.OrderDate, o.CustID, o.SiteID, o.Region, o.Country, o.PostalCode, o.TerrId, o.Phone1
--  , o.Email, o.Rep1Id, o.Rep2Id, o.BillingType, o.CustomerPoNumber, o.PODate, o.OriginalWorkOrder
--  , o.ProjectDetailID, d.ID AS DispatchID, d.WorkOrderID, d.DispatchNo, d.[Description], d.[Status]
--  , d.EquipmentID, d.EquipmentDescription, d.BillingType AS DispatchBillingType, d.BillToID, d.RequestedDate
--  , d.RequestedTechID, d.CancelledYN, d.HoldYN, d.EntryDate, d.[Counter], d.LocID 
-- FROM dbo.tblSvWorkOrder o 
--  INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
-- WHERE CustID IS NOT NULL AND d.[Status] = 0 AND d.CancelledYN = 0 AND d.HoldYN = 0
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

	CREATE TABLE #TempCoverage(
	EquipmentID bigint,
	DispatchId bigint,
	CoverageType tinyint,
	ContractNo nvarchar(16),
	EndDate datetime,
	labelServiceContracts nvarchar(100),
	[Status] tinyint)

	CREATE TABLE #TempCoverageAvailable(
	EquipmentID bigint,
	DispatchId bigint,
	CoverageType tinyint,
	ContractNo nvarchar(16),
	EndDate datetime,
	labelServiceContracts nvarchar(100),
	[Status] tinyint)

	CREATE TABLE #TempWarranty(
	EquipmentID bigint,
	DispatchId bigint,
	CoverageType tinyint,
	StartDate datetime,
	EndDate datetime,
	labelWarranty nvarchar(100),
	[Status] tinyint,
	WorkOrderID bigint)

	CREATE TABLE #TempWarrantyAvailable(
	EquipmentID bigint,
	DispatchId bigint,
	CoverageType tinyint,
	StartDate datetime,
	EndDate datetime,
	labelWarranty nvarchar(100),
	[Status] tinyint,
	WorkOrderID bigint)

	DECLARE @CoverageCount int, @WarrantyCount int

	IF (@PrintOneCopyPerTechnician = 0)
	BEGIN
		IF (@ScheduledDateFrom IS NULL AND @ScheduledDateThru IS NULL 
			AND @ScheduledTechnicianFrom IS NULL AND @ScheduledTechnicianThru IS NULL)
		BEGIN
			INSERT INTO #Temp(DispatchID, EquipmentID) 
			SELECT tmp.DispatchID, d.EquipmentID 
			FROM #tmpWorkOrderDispatchList tmp 
				INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
				INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			ORDER BY WorkOrderNo, DispatchNo
		END
		ELSE
		BEGIN
		INSERT INTO #Temp(DispatchID, EquipmentID) 
			SELECT tmp.DispatchID, d.EquipmentID 
			FROM #tmpWorkOrderDispatchList tmp 
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
			FROM #tmpWorkOrderDispatchList tmp 
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
			FROM #tmpWorkOrderDispatchList tmp 
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
	SELECT tmp.[Counter], d.ID AS DispatchID, d.[Description], WorkOrderNo, ISNULL(w.SiteID, w.CustID) AS SiteCustID
		, ISNULL(s.ShiptoName, c2.CustName) AS SiteName
		, w.Attention AS SiteAttention, w.Address1 AS SiteAddress1, w.Address2 AS SiteAddress2, w.City AS SiteCity
		, w.Region AS SiteRegion, w.Country AS SiteCountry, w.PostalCode AS SitePostalCode
		, ISNULL(d.BillToID, w.CustID) AS BillToID
		, CASE WHEN d.BillToID IS NOT NULL THEN c.CustName ELSE c2.CustName END AS BillToName
		, CASE WHEN d.BillToID IS NOT NULL THEN c.Attn ELSE c2.Attn END AS BillToAttention
		, CASE WHEN d.BillToID IS NOT NULL THEN c.Addr1 ELSE c2.Addr1 END AS BillToAddress1
		, CASE WHEN d.BillToID IS NOT NULL THEN c.Addr2 ELSE c2.Addr2 END AS BillToAddress2
		, CASE WHEN d.BillToID IS NOT NULL THEN c.City ELSE c2.City END AS BillToCity
		, CASE WHEN d.BillToID IS NOT NULL THEN c.Region ELSE c2.Region END AS BillToRegion
		, CASE WHEN d.BillToID IS NOT NULL THEN c.Country ELSE c2.Country END AS BillToCountry
		, CASE WHEN d.BillToID IS NOT NULL THEN c.PostalCode ELSE c2.PostalCode END AS BillToPostalCode
		, w.Attention, w.Phone1 AS Phone
		, DispatchNo, d.EquipmentID, d.EquipmentDescription, e.EquipmentNo, e.ItemID, e.SerialNumber, e.TagNumber
		, d.Status 
		, d.StatusID
		, ats.Description AS DispatchStatus
		, RequestedDate, RequestedAMPM
		, RequestedTechID, CancelledYN, a.ActivityDateTime AS ReceivedDateTime, d.[Priority]
		, CASE WHEN b.Description IS NULL THEN  d.BillingType 
			WHEN len(b.Description)=0 THEN d.BillingType 
			ELSE b.Description END AS BillingType
		, WorkOrderNo + '/' + CAST(DispatchNo AS nvarchar) AS WorkOrderDispatchNo 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
		INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
		LEFT JOIN dbo.tblArCust c ON d.BillToID = c.CustId 
		LEFT JOIN dbo.tblArCust c2 ON w.CustID = c2.CustId 
		LEFT JOIN dbo.tblArShipTo s ON w.CustID = s.CustId AND w.SiteID = s.ShiptoId 
		LEFT JOIN dbo.tblSvActivityStatus ats ON d.StatusID = ats.ID
		LEFT JOIN dbo.tblSvEquipment e ON d.EquipmentID = e.ID 
		LEFT JOIN 
			(
				SELECT DispatchID, MAX(ID) AS ActivityID FROM dbo.tblSvWorkOrderActivity 
				WHERE ActivityType = 0 GROUP BY DispatchID
			) r ON d.ID = r.DispatchID 
		LEFT JOIN dbo.tblSvWorkOrderActivity a ON r.ActivityID = a.ID
		INNER JOIN dbo.tblSvBillingType b ON d.BillingType = b.BillingType

	-- Service Contract resultset (Table1)	
	INSERT INTO #TempCoverageAvailable(EquipmentID,DispatchId,CoverageType,ContractNo,EndDate,labelServiceContracts,[Status])
	SELECT  s.EquipmentID,DispatchID
	, s.CoverageType 
	, h.ContractNo, h.EndDate , 'Service Contracts Available'  AS labelServiceContracts
	, CASE when  CONVERT(date, w.OrderDate) BETWEEN CONVERT(date, h.StartDate) AND CONVERT(date, h.EndDate)  THEN 0 Else 1 END AS [Status]
	FROM #TempDistinctEquipment tmp 
		INNER JOIN #Temp t ON tmp.EquipmentID = t.EquipmentID
		INNER JOIN dbo.tblSvServiceContractDetail s ON tmp.EquipmentID = s.EquipmentID 
		INNER JOIN dbo.tblSvServiceContractHeader h ON s.ContractID = h.ID	
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON d.EquipmentID = s.EquipmentID AND d.ID = t.DispatchID
		INNER JOIN dbo.tblSvWorkOrder w ON w.ID = d.WorkOrderID 		
	WHERE @PrintServiceContract =1 
	
	INSERT INTO #TempCoverage(EquipmentID,DispatchId,CoverageType,ContractNo,EndDate,labelServiceContracts,[Status])
	SELECT  s.EquipmentID,c.DispatchID
	, s.CoverageType AS CoverageType
	, h.ContractNo, h.EndDate , 'Service Contracts' AS labelServiceContracts
	, CASE when  CONVERT(date, wo.OrderDate) BETWEEN CONVERT(date, h.StartDate) AND CONVERT(date, h.EndDate)  THEN 0 Else 1 END AS [Status]
	FROM #TempDistinctEquipment tmp 
		INNER JOIN #Temp t ON tmp.EquipmentID = t.EquipmentID
		INNER JOIN dbo.tblSvServiceContractDetail s ON tmp.EquipmentID = s.EquipmentID 
		INNER JOIN dbo.tblSvServiceContractHeader h ON s.ContractID = h.ID
		INNER JOIN dbo.tblSvWorkOrderDispatchCoverage c ON c.CoveredById = s.ID  
		INNER JOIN dbo.tblsvWorkOrderDispatch d ON d.id=c.DispatchID AND d.EquipmentID=s.EquipmentID AND d.ID = t.DispatchID
		INNER JOIN dbo.tblSvWorkOrder wo  ON d.WorkOrderID=wo.id	
	WHERE @PrintServiceContract =1 AND c.CoveredByType =1
	
	SELECT @CoverageCount=  count(*) FROM #TempCoverage

	IF @CoverageCount > 0
	BEGIN
		DELETE #TempCoverageAvailable
		FROM #TempCoverageAvailable t1
		INNER JOIN #TempCoverage t2 ON t1.DispatchId = t2.DispatchId AND t1.EquipmentID = t2.EquipmentID
	END

	SELECT EquipmentID,CoverageType,ContractNo,EndDate,labelServiceContracts,[Status],DispatchID from #TempCoverage
	UNION ALL
	SELECT EquipmentID,CoverageType,ContractNo,EndDate,labelServiceContracts,[Status],DispatchID FROM #TempCoverageAvailable

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
		, QtyEstimated, QtyUsed, Unit, t.[Description], UnitPrice, PriceExt AS ExtPrice
		, CASE WHEN @PrintAdditionalDescription = 1 THEN t.AdditionalDescription 
			ELSE NULL END AS AdditionalDescription, TransDate 
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
	SELECT TOP 3 d.ID AS DispatchID, d.DispatchNo, w.WorkOrderNo, CAST(3 AS tinyint) AS [Status]
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
	INSERT INTO #TempWarrantyAvailable(EquipmentID,DispatchId,CoverageType,StartDate,EndDate,labelWarranty,[Status],WorkOrderID)
	SELECT w.EquipmentID, DispatchId,w.CoverageType , StartDate, EndDate 
	, 'Warranties Available' AS labelWarranty
	,  CASE WHEN  CONVERT(date, wo.OrderDate) BETWEEN CONVERT(date, w.StartDate) AND CONVERT(date, w.EndDate)  
			THEN 0
			ELSE CASE WHEN e.SiteYN =0 THEN 3 ELSE 1 END 
	   END AS [Status]	,wo.ID
	FROM #TempDistinctEquipment tmp 
		INNER JOIN #Temp t ON tmp.EquipmentID = t.EquipmentID
		INNER JOIN dbo.tblSvEquipmentWarranty w ON tmp.EquipmentID = w.EquipmentID 		
		INNER JOIN dbo.tblsvWorkOrderDispatch d ON d.EquipmentID=w.EquipmentID AND d.ID = t.DispatchID
		INNER JOIN dbo.tblSvWorkOrder wo  ON d.WorkOrderID=wo.id	
		INNER JOIN tblSvEquipment e ON e.ID = d.EquipmentID
	WHERE @PrintWarrantyDetail = 1
	
	INSERT INTO #TempWarranty(EquipmentID,DispatchId,CoverageType,StartDate,EndDate,labelWarranty,[Status],WorkOrderID)
	SELECT w.EquipmentID,c.DispatchId, w.CoverageType  AS CoverageType , StartDate, EndDate 
	, 'Warranty' AS labelWarranty
	,  CASE when  CONVERT(date, wo.OrderDate) BETWEEN CONVERT(date, w.StartDate) AND CONVERT(date, w.EndDate)  THEN 0 Else 1 END AS [Status], wo.ID
	FROM #TempDistinctEquipment tmp 
		INNER JOIN #Temp t ON tmp.EquipmentID = t.EquipmentID
		INNER JOIN dbo.tblSvEquipmentWarranty w ON tmp.EquipmentID = w.EquipmentID 
		INNER JOIN dbo.tblSvWorkOrderDispatchCoverage c ON c.CoveredById = w.ID
		INNER JOIN dbo.tblsvWorkOrderDispatch d ON d.id=c.DispatchID AND d.EquipmentID=w.EquipmentID AND d.ID = t.DispatchID
		INNER JOIN dbo.tblSvWorkOrder wo  ON d.WorkOrderID=wo.id		  
	WHERE @PrintWarrantyDetail = 1  AND c.CoveredByType =0
	
	
	SELECT @WarrantyCount  =  count(*) FROM #TempWarranty

	IF @WarrantyCount > 0
	BEGIN
		DELETE #TempWarrantyAvailable
		FROM #TempWarrantyAvailable t1
		INNER JOIN #TempWarranty t2 ON t1.DispatchId = t2.DispatchId AND t1.EquipmentID = t2.EquipmentID AND t1.WorkOrderID = t2.WorkOrderID
	END

	SELECT EquipmentID,CoverageType,StartDate,EndDate,labelWarranty,[Status],DispatchID from #TempWarranty
	UNION ALL
	SELECT EquipmentID,CoverageType,StartDate,EndDate,labelWarranty,[Status],DispatchID FROM #TempWarrantyAvailable

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrder_proc';

