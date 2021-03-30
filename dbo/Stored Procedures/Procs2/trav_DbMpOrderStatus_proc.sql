
CREATE PROCEDURE dbo.trav_DbMpOrderStatus_proc
@Planner nvarchar(20) = '', 
@HoursDollars tinyint, -- 0 = Hours, 1 = Dollars
@PercentComplete pDecimal, 
@PercentagePrecision tinyint

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmpOrderRelease
	(
		ReleaseId int NOT NULL 
		PRIMARY KEY CLUSTERED (ReleaseId)
	)

	CREATE TABLE #tmpOrderCost
	(
		ReleaseId int NOT NULL, 
		EstimateHours decimal(28, 10) NOT NULL DEFAULT(0), 
		ActualHours decimal(28, 10) NOT NULL DEFAULT(0), 
		ActualCost decimal(28, 10) NOT NULL DEFAULT(0), 
		EstimateCost decimal(28, 10) NOT NULL DEFAULT(0)
	)

	CREATE TABLE #tmpResults
	(
		OrderRel nvarchar(19), 
		OrderNo pTransID NULL, 
		ReleaseNo int, 
		AssemblyId pItemID NULL, 
		Planner nvarchar(20) NULL, 
		EstimateHours decimal(28, 10) NOT NULL DEFAULT(0), 
		ActualHours decimal(28, 10) NOT NULL DEFAULT(0), 
		PercentCompleteHours decimal(28, 10) NOT NULL DEFAULT(0), 
		EstimateCost decimal(28, 10) NOT NULL DEFAULT(0), 
		ActualCost decimal(28, 10) NOT NULL DEFAULT(0), 
		PercentCompleteCost decimal(28, 10) NOT NULL DEFAULT(0)
	)

	INSERT INTO #tmpOrderRelease (ReleaseId) 
	SELECT r.Id 
	FROM dbo.tblMpOrderReleases r 
		INNER JOIN dbo.tblMpOrder o ON o.OrderNo = r.OrderNo
	WHERE r.[Status] = 4 AND ((@Planner = '') OR (@Planner = o.Planner))

	-- Est & Act Hours (Time)
	INSERT INTO #tmpOrderCost (ReleaseId, EstimateHours, ActualHours) 
			SELECT o.Id AS ReleaseId
				, SUM((s.MachineSetupEst / 60.0) 
					+ (s.LaborSetupEst / 60.0) 
					+ (s.MachineRunEst / 60.0) 
					+ (s.LaborEst / 60.0)) AS EstimateHours
				, 0 AS ActualHours 
			FROM dbo.tblMpTimeSum s 
				INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId 
				INNER JOIN dbo.tblMpOrderReleases o ON  o.Id = r.ReleaseId 
				INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
				INNER JOIN #tmpOrderRelease t ON o.Id = t.ReleaseId 
	GROUP BY  o.Id	
	
	INSERT INTO #tmpOrderCost (ReleaseId, EstimateHours, ActualHours) 
			SELECT o.Id AS ReleaseId
				, 0 AS EstimateHours
				, (SUM(COALESCE(d.MachineSetup / d.MachineSetupIn, 0))) 
					+ (SUM(COALESCE(d.MachineRun / d.MachineRunIn, 0))) 
					+ (SUM(COALESCE(d.LaborSetup / d.LaborSetupIn, 0))) 
					+ (SUM(COALESCE(d.Labor / d.LaborIn, 0))) AS ActualHours 
			FROM dbo.tblMpTimeDtl d
				INNER JOIN dbo.tblMpRequirements r ON d.TransId = r.TransId 
				INNER JOIN dbo.tblMpOrderReleases o ON  o.Id = r.ReleaseId 
				INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
				INNER JOIN #tmpOrderRelease t ON o.Id = t.ReleaseId 
	GROUP BY  o.Id
	

	-- Est Cost (Materials)
	INSERT INTO #tmpOrderCost (ReleaseId, EstimateCost) 
	SELECT o.Id AS ReleaseId
		, ISNULL(SUM(CASE WHEN s.ComponentType = 5 
			THEN -(ISNULL(s.EstQtyRequired * s.UnitCost, 0)) -- reverse sign for byproducts
			ELSE ISNULL(s.EstQtyRequired * s.UnitCost, 0) END), 0) AS EstimateCost 
	FROM #tmpOrderRelease t 
		INNER JOIN dbo.tblMpOrderReleases o ON t.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
	WHERE s.ComponentType IN (4, 5) 
	GROUP BY o.Id

	-- Act Cost (Materials)
	INSERT INTO #tmpOrderCost (ReleaseId, ActualCost) 
	SELECT o.Id AS ReleaseId
		, ISNULL(SUM(CASE s.ComponentType 
			WHEN 2 THEN -- subassembly
				CASE d.SubAssemblyTranType 
					WHEN 2 THEN 0 -- assembled get cost from components used
					WHEN 1 THEN d.Qty * d.UnitCost -- cost pulled from stock
					WHEN -1 THEN -d.Qty * d.UnitCost -- cost moved to stock (credit)
				END 
			WHEN 3 THEN d.Qty * d.UnitCost -- stocked subassembly
			WHEN 4 THEN d.Qty * d.UnitCost -- material
			WHEN 5 THEN -d.Qty * d.UnitCost -- byproduct (credit)
			END), 0) AS ActualCost 
	FROM #tmpOrderRelease t 
		INNER JOIN dbo.tblMpOrderReleases o ON t.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
		INNER JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId 
	WHERE s.ComponentType IN (2, 3, 4, 5) 
	GROUP BY o.Id

	-- Est Cost (Time)
	INSERT INTO #tmpOrderCost (ReleaseId, EstimateCost) 
	SELECT o.Id AS ReleaseId
		, ISNULL(SUM(((1 + (LaborPctOvhd / 100.0)) * ((LaborSetupEst / 60.0) * HourlyRateLbrSetup) + ((LaborEst / 60.0) * HourlyRateLbr)) 
			+ ((1 + (MachPctOvhd / 100.0)) * (((MachineSetupEst / 60.0) + (MachineRunEst / 60.0)) * HourlyCostFactorMach)) 
			+ FlatAmtOvhd + (PerPieceOvhd * QtyProducedEst)), 0) AS EstimateCost 
	FROM #tmpOrderRelease t 
		INNER JOIN dbo.tblMpOrderReleases o ON t.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpTimeSum s ON r.TransId = s.TransId 
	GROUP BY o.Id

	-- Act Cost (Time) - flat amount overhead only
	INSERT INTO #tmpOrderCost (ReleaseId, ActualCost) 
	SELECT o.Id AS ReleaseId
		, ISNULL(SUM(FlatAmtOvhd), 0) AS ActualCost 
	FROM #tmpOrderRelease t 
		INNER JOIN dbo.tblMpOrderReleases o ON t.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpTimeSum s ON r.TransId = s.TransId 
	GROUP BY o.Id

	-- Act Cost (Time)
	INSERT INTO #tmpOrderCost (ReleaseId, ActualCost) 
	SELECT o.Id AS ReleaseId
		, ISNULL(SUM(((1 + (LaborPctOvhd / 100.0)) * ((LaborSetup / LaborSetupIn) * HourlyRateLbrSetup) + ((Labor / LaborIn) * HourlyRateLbr)) 
			+ ((1 + (MachPctOvhd / 100.0)) * (((MachineSetup / MachineSetupIn) + (MachineRun / MachineRunIn)) * HourlyCostFactorMach)) 
			--+ FlatAmtOvhd 
			+ (PerPieceOvhd * (d.QtyProduced + d.QtyScrapped))), 0) AS ActualCost 
	FROM #tmpOrderRelease t 
		INNER JOIN dbo.tblMpOrderReleases o ON t.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpTimeSum s ON r.TransId = s.TransId 
		INNER JOIN dbo.tblMpTimeDtl d ON s.TransId = d.TransId 
	GROUP BY o.Id

	-- Est Cost (Subcontract)
	INSERT INTO #tmpOrderCost (ReleaseId, EstimateCost) 
	SELECT o.Id AS ReleaseId, ISNULL(SUM(EstQtyRequired * EstPerPieceCost), 0) AS EstimateCost 
	FROM #tmpOrderRelease t 
		INNER JOIN dbo.tblMpOrderReleases o ON t.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpSubContractSum s ON r.TransId = s.TransId 
	GROUP BY o.Id

	-- Act Cost (Subcontract)
	INSERT INTO #tmpOrderCost (ReleaseId, ActualCost) 
	SELECT o.Id AS ReleaseId, ISNULL(SUM(QtyReceived * UnitCost), 0) AS ActualCost 
	FROM #tmpOrderRelease t 
		INNER JOIN dbo.tblMpOrderReleases o ON t.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpSubContractSum s ON r.TransId = s.TransId 
		INNER JOIN dbo.tblMpSubContractDtl d ON s.TransId = d.TransId 
	GROUP BY o.Id

	INSERT INTO	#tmpResults (OrderRel, OrderNo, ReleaseNo, AssemblyId, Planner, EstimateHours, ActualHours
		, PercentCompleteHours, EstimateCost, ActualCost, PercentCompleteCost) 
	SELECT o.OrderNo + '/' + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) AS OrderRel, o.OrderNo, o.ReleaseNo, h.AssemblyId, h.Planner, tmp.EstimateHours, tmp.ActualHours
		, tmp.PercentCompleteHours, tmp.EstimateCost, tmp.ActualCost, tmp.PercentCompleteCost
	FROM 
		(
			SELECT ReleaseId, SUM(EstimateHours) AS EstimateHours, SUM(ActualHours) AS ActualHours
				, SUM(EstimateCost) AS EstimateCost, SUM(ActualCost) AS ActualCost
				, ROUND(CASE WHEN SUM(EstimateHours) = 0 THEN 0 ELSE (SUM(ActualHours) / SUM(EstimateHours)) 
					* 100 END, @PercentagePrecision) AS PercentCompleteHours 
				, ROUND(CASE WHEN SUM(EstimateCost) = 0 THEN 0 ELSE (SUM(ActualCost) / SUM(EstimateCost)) 
					* 100 END, @PercentagePrecision) AS PercentCompleteCost 
			FROM #tmpOrderCost 
			GROUP BY ReleaseId
		) tmp
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.ReleaseId = o.Id 
		INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo

	SELECT * FROM #tmpResults 
	WHERE (CASE @HoursDollars WHEN 0 THEN PercentCompleteHours ELSE PercentCompleteCost END) >= @PercentComplete

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbMpOrderStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbMpOrderStatus_proc';

