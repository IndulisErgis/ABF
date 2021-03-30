
CREATE PROCEDURE dbo.trav_SvWorkOrderReport_proc
@SortBy int = 0, -- 0 = Customer ID, 1 = Work Order Number, 2 = Dispatch Status
@ViewDetail int = 0, -- 0 = Summary, 1 = Detail
@IncludeWorkToDoDetail bit = 0, 
@IncludeActivityDetail bit = 1, 
@IncludeSerializedLottedDetail bit = 0

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
--		, o.ProjectDetailID, d.ID AS DispatchID, d.DispatchNo, d.[Description], d.[Status]
--		, d.EquipmentDescription, d.BillingType AS DispatchBillingType, d.BillToID, d.RequestedDate
--		, d.RequestedTechID, d.CancelledYN, d.HoldYN, d.EntryDate, d.[Counter], d.LocID 
--	FROM dbo.tblSvWorkOrder o 
--		INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
--	WHERE CustID IS NOT NULL
--) tmp --{0}

	DECLARE @ActivityCount int
	SELECT @ActivityCount = count(ID) FROM dbo.tblSvActivityStatus

	CREATE TABLE #Activity
	(
		DispatchID bigint NOT NULL, 
		ActivityID bigint NULL, 
		ActivityReceivedID bigint NULL		
		PRIMARY KEY (DispatchID)
	)

	INSERT INTO #Activity (DispatchID, ActivityID, ActivityReceivedID) 
	SELECT tmp.DispatchID, g.ActivityID, r.ActivityReceivedID 
	FROM #tmpWorkOrderDispatchList tmp 
		LEFT JOIN 
		(
			SELECT DispatchID, MAX(ID) AS ActivityID 
			FROM dbo.tblSvWorkOrderActivity 
			GROUP BY DispatchID
		) g 
			ON tmp.DispatchID = g.DispatchID 
		LEFT JOIN 
		(
			SELECT DispatchID, MAX(ID) AS ActivityReceivedID 
			FROM dbo.tblSvWorkOrderActivity WHERE ActivityType = 0 
			GROUP BY DispatchID
		) r 
			ON tmp.DispatchID = r.DispatchID 

	-- Work Order Dispatch resultset (Table)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT d.WorkOrderID, d.ID AS DispatchID
				, CASE @SortBy 
				WHEN 0 THEN w.CustID 
				WHEN 1 THEN CAST(WorkOrderNo AS nvarchar) 
				WHEN 2 THEN CASE WHEN @ActivityCount =0 THEN CAST(d.[Status] AS nvarchar) 
					   ELSE CASE WHEN LEN(CAST(ats.Sequence AS nvarchar)) =3 THEN  CAST(ats.Sequence AS nvarchar) 
								 WHEN LEN(CAST(ats.Sequence AS nvarchar)) =2 THEN  '0'+CAST(ats.Sequence AS nvarchar) 
								 WHEN LEN(CAST(ats.Sequence AS nvarchar)) =1 THEN  '00'+CAST(ats.Sequence AS nvarchar)
							END 
							END
				END AS GrpId1
			, WorkOrderNo, OrderDate, w.CustID, w.SiteID, Address1, Address2
			, City, Region, Country, PostalCode, DispatchNo, d.[Description]
			, e.EquipmentNo AS EquipmentID, EquipmentDescription
			, CASE WHEN b.Description IS NULL THEN  d.BillingType 
				   WHEN len(b.Description)=0 THEN d.BillingType 
				   ELSE b.Description END	AS DispatchBillingType 
			, BillToID
			, ISNULL(EstTravel, 0) / 3600.00 AS EstTravel
			, (ISNULL(EstimatedTime, 0) + ISNULL(EstTravel, 0)) / 3600.00 AS TotalEst
			, [Counter], LocID, d.EntryDate, d.[Status], HoldYN
			, a.ActivityDateTime AS ReceivedDateTime
			, RequestedDate, RequestedAMPM, RequestedTechID, CancelledYN, d.[Priority] ,d.StatusID, ats.Description as DispatchStatus
		FROM #Activity tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			LEFT JOIN dbo.tblSvEquipment e ON d.EquipmentID = e.ID
			LEFT JOIN dbo.tblSvWorkOrderActivity a ON tmp.ActivityReceivedID = a.ID 
			LEFT JOIN dbo.tblSvActivityStatus ats ON d.StatusID = ats.ID
			LEFT JOIN 
			(
				SELECT w.DispatchID, SUM(EstimatedTime) AS EstimatedTime 
				FROM #Activity tmp 
					INNER JOIN dbo.tblSvWorkOrderDispatchWorkToDo w ON tmp.DispatchID = w.DispatchID 
				GROUP BY w.DispatchID
			) t ON d.ID = t.DispatchID
			INNER JOIN dbo.tblSvBillingType b ON d.BillingType = b.BillingType
	END
	ELSE
	BEGIN
		SELECT tmp.DispatchID, w.WorkOrderNo, d.DispatchNo
				, CASE @SortBy 
				WHEN 0 THEN w.CustID 
				WHEN 1 THEN CAST(WorkOrderNo AS nvarchar) 
				WHEN 2 THEN CASE WHEN @ActivityCount =0 THEN CAST(d.[Status] AS nvarchar) 
					   ELSE CASE WHEN LEN(CAST(ats.Sequence AS nvarchar)) =3 THEN  CAST(ats.Sequence AS nvarchar) 
								 WHEN LEN(CAST(ats.Sequence AS nvarchar)) =2 THEN  '0'+CAST(ats.Sequence AS nvarchar) 
								 WHEN LEN(CAST(ats.Sequence AS nvarchar)) =1 THEN  '00'+CAST(ats.Sequence AS nvarchar)
							END 
							END
				END AS GrpId1
			, w.CustID, w.CustID + ' - ' + c.CustName AS CustIDName, w.SiteID
			, r.ActivityDateTime AS ReceivedDateTime
			, a.ActivityDateTime, a.TechID, a.ActivityType , ats.Description as DispatchStatus
		FROM #Activity tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON w.ID = d.WorkOrderID 
			LEFT JOIN dbo.tblArCust c ON w.CustID = c.CustId 
			LEFT JOIN dbo.tblSvWorkOrderActivity a ON tmp.ActivityID = a.ID 
			LEFT JOIN dbo.tblSvWorkOrderActivity r ON tmp.ActivityReceivedID = r.ID 
			LEFT JOIN dbo.tblSvActivityStatus ats ON d.StatusID = ats.ID
	END

	-- Work To Do resultset (Table1)
	SELECT w.DispatchID, WorkToDoID, [Description], SkillLevel
		, EstimatedTime / 3600.00 AS EstimatedTime 
	FROM #Activity tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatchWorkToDo w 
			ON tmp.DispatchID = w.DispatchID 
	WHERE @IncludeWorkToDoDetail <> 0

	-- Activity resultset (Table2)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT a.DispatchID, ActivityType, ActivityDateTime
			, TechID, a.EntryDate, EnteredBy , ats.Description as ActivityStatus
		FROM #Activity tmp 
			INNER JOIN dbo.tblSvWorkOrderActivity a ON tmp.DispatchID = a.DispatchID			
			LEFT JOIN dbo.tblSvActivityStatus ats ON a.ActivityType = ats.ID
		WHERE @IncludeActivityDetail <> 0 AND a.ActivityType <> 0
	END


	-- Transaction resultset (Table3)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT t.ID AS TransID, t.DispatchID, t.WorkOrderID, t.TransType, ResourceID, t.TransDate
			, QtyEstimated, QtyUsed, Unit, t.[Description] 
		FROM #Activity tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
		WHERE (t.TransType = 0 OR t.TransType = 1) -- exclude freight & misc records
	END

	-- Transaction Lotted Detail resultset (Table4)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT TransID, LotNum, e.QtyUsed 
		FROM #Activity tmp 
			INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.DispatchID = d.ID 
			INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
			INNER JOIN dbo.tblSvWorkOrderTransExt e ON t.ID = e.TransID 
		WHERE (TransType = 0 OR TransType = 1) -- exclude freight & misc records
			AND @IncludeSerializedLottedDetail <> 0
	END

	-- Transaction Serialized Detail resultset (Table5)
	IF (@ViewDetail <> 0)
	BEGIN
		SELECT TransID, LotNum, SerNum 
		FROM #Activity tmp 
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
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderReport_proc';

