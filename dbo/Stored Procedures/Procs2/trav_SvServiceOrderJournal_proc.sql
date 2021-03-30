
CREATE PROCEDURE dbo.trav_SvServiceOrderJournal_proc
@SortBy tinyint = 0, -- 0 = Service Order Number, 1 = Location ID
@ViewAdditionalDescription bit = 0, 
@ViewSummary tinyint = 0

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpServiceOrderList(WorkOrderID bigint NOT NULL PRIMARY KEY CLUSTERED (WorkOrderID))
--INSERT INTO #tmpServiceOrderList (WorkOrderID) 
--SELECT WorkOrderID 
--FROM 
--(
--	SELECT o.ID AS WorkOrderID 
--	FROM dbo.tblSvWorkOrder o 
--		INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
--		INNER JOIN dbo.tblSvWorkOrderTrans t ON d.WorkOrderID = t.WorkOrderID AND d.ID = t.DispatchID 
--	WHERE ((d.[Status] = 1) OR (d.[Status] = 0 AND d.CancelledYN <> 0)) AND t.[Status] = 0 
--	GROUP BY o.ID
--) tmp --{0}

	CREATE TABLE #Temp
	(
		TransID bigint NOT NULL
	)

	INSERT INTO #Temp (TransID) 
	SELECT t.ID AS TransID 
	FROM #tmpServiceOrderList tmp 
		INNER JOIN dbo.tblSvWorkOrderDispatch d ON tmp.WorkOrderID = d.WorkOrderID 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON d.ID = t.DispatchID 
	WHERE ((d.[Status] = 1) OR (d.[Status] = 0 AND d.CancelledYN <> 0)) AND t.[Status] = 0 

	-- main report resultset (Table)
	SELECT CASE @SortBy 
			WHEN 0 THEN CAST(w.WorkOrderNo AS nvarchar) 
			WHEN 1 THEN CAST(w.SiteID AS nvarchar) END AS GrpID1
		, w.ID AS WorkOrderID, WorkOrderNo AS ServiceOrderNo, SiteID AS LocationID, OrderDate
		, r.ActivityDateTime AS CompletedDate, ExtCost 
	FROM #tmpServiceOrderList tmp 
		INNER JOIN dbo.tblSvWorkOrder w ON tmp.WorkOrderID = w.ID 
		LEFT JOIN 
			(
				SELECT a.WorkOrderID, MAX(ActivityDateTime) AS ActivityDateTime 
				FROM dbo.tblSvWorkOrderActivity a 
					INNER JOIN #tmpServiceOrderList s ON a.WorkOrderID = s.WorkOrderID 
					INNER JOIN dbo.tblSvWorkOrderDispatch d ON a.WorkOrderID = d.WorkOrderID
				WHERE ((d.[Status] = 1) OR (d.[Status] = 0 AND d.CancelledYN <> 0)) 
				GROUP BY a.WorkOrderID
			) r ON tmp.WorkOrderID = r.WorkOrderID
		INNER JOIN 
			(
				SELECT WorkOrderID, SUM(CostExt) AS ExtCost 
				FROM tblSvWorkOrderTrans 
				GROUP BY WorkOrderID
			) e ON tmp.WorkOrderID = e.WorkOrderID

	-- detail report resultset (Table1)
	SELECT t.ID AS TransID, t.WorkOrderID, ResourceID, [Description]
		, CASE WHEN @ViewAdditionalDescription <> 0 
			THEN t.AdditionalDescription ELSE NULL END AS AdditionalDescription
		, LocID, FiscalPeriod, FiscalYear, GLAcctDebit, GLAcctCredit, Unit, TaxClass, QtyEstimated, QtyUsed
		, UnitCost, CostExt AS ExtCost, TransType 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON tmp.TransID = t.ID
	WHERE @ViewSummary = 0 

	-- lot detail resultset (Table2)
	SELECT l.TransID, l.LotNum AS LotNo, l.QtyUsed AS Qty, l.UnitCost 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderTransExt l ON tmp.TransID = l.TransID 
	WHERE @ViewSummary = 0 
	ORDER BY l.LotNum

	-- serial detail resultset (Table3)
	SELECT s.TransID, s.LotNum AS LotNo, s.SerNum AS SerNo, s.UnitCost 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvWorkOrderTransSer s ON tmp.TransID = s.TransID 
	WHERE @ViewSummary = 0 
	ORDER BY s.LotNum, s.SerNum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderJournal_proc';

