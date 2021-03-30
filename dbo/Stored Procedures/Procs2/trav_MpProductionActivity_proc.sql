
CREATE PROCEDURE trav_MpProductionActivity_proc
@EmployeeIdFrom pEmpID, 
@EmployeeIdThru pEmpID, 
@ItemIdFrom pItemId, 
@ItemIdThru pItemId, 
@DateFrom datetime, 
@DateThru datetime, 
@IncludeMaterials bit, 
@IncludeByproducts bit, 
@IncludeProcesses bit, 
@IncludeSubcontracted bit, 
@IncludeSubassemblies bit, 
@IncludeFinishedGoods bit, 
@SortBy tinyint --0 = Item ID / Work Center ID / Vendor ID, 1 = Order Number / Release Number, 2 = Transaction Date

AS
BEGIN TRY
	SET NOCOUNT ON

	--For Main Report
	SELECT 1

	--Materials
	SELECT CASE @SortBy 
			WHEN 0 THEN d.ComponentId 
			WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
			ELSE CONVERT(nvarchar(8), d.TransDate, 112) END AS SortBy
		, o.OrderNo, o.ReleaseNo, o.EstCompletionDate, r.ReqId, d.ComponentID, d.LocId AS Location
		, i.Descr AS [Description], d.TransDate, d.Qty AS QtyPulled, d.ActualScrap AS QtyScrapped, d.UOM AS Unit
		, d.UnitCost, d.VarianceCode, v.Descr VarianceDescription, d.Notes, d.TransId, d.SeqNo, d.Qty * d.UnitCost AS TotalCost 
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
		INNER JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId 
		LEFT JOIN dbo.tblInItem i ON d.ComponentId = i.ItemId 
		LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode 
	WHERE @IncludeMaterials = 1 
		AND (s.ComponentType = 3 OR s.ComponentType = 4) --stocked OR material 
		AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru) 
		AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

	--Byproducts
	SELECT CASE @SortBy 
			WHEN 0 THEN d.ComponentId 
			WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
			ELSE CONVERT(nvarchar(8), d.TransDate, 112) END AS SortBy
		, o.OrderNo, o.ReleaseNo, o.EstCompletionDate, r.ReqId, d.ComponentID, d.LocId AS Location
		, i.Descr AS [Description], d.TransDate, d.Qty AS QtyPulled, d.ActualScrap AS QtyScrapped, d.UOM AS Unit, d.TransId, d.SeqNo
		, d.UnitCost, d.VarianceCode, v.Descr VarianceDescription, d.Notes, d.Qty * d.UnitCost AS TotalCost 
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
		INNER JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId 
		LEFT JOIN dbo.tblInItem i ON d.ComponentId = i.ItemId 
		LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode 
	WHERE @IncludeByproducts = 1 
		AND (s.ComponentType = 5) --byproduct
		AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru) 
		AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

	--Processes
	SELECT CASE @SortBy 
			WHEN 0 THEN s.WorkCenterId 
			WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
			ELSE CONVERT(nvarchar(8), d.TransDate, 112) END AS SortBy
		, o.OrderNo, o.ReleaseNo, o.EstCompletionDate, r.ReqId, d.TransDate
		, d.VarianceCode, v.Descr VarianceDescription
		, s.WorkCenterID, s.OperSupervisor AS Supervisor, d.EmployeeID, d.BeginTime AS StartTime, d.EndTime AS FinishTime
		, s.MachineGroupID, d.MachineSetup, d.MachineRun
		, s.LaborTypeID, d.LaborSetup, d.Labor
		, s.LaborPctOvhd, s.HourlyRateLbr
		, s.MachPctOvhd, s.HourlyCostFactorMach
		, s.PerPieceCostLbr, s.FlatAmtOvhd AS FlatOverhead, s.PerPieceOvhd AS PerPieceOverhead
		, d.QtyProduced, d.QtyScrapped
		, d.Notes
		, d.MachineSetup * s.HourlyCostFactorMach AS MachineSetupCost
		, d.MachineRun * s.HourlyCostFactorMach AS MachineRunCost
		, (d.MachineRun * s.HourlyCostFactorMach) * (s.MachPctOvhd / 100) AS MachineOverhead
		, d.LaborSetup * s.HourlyRateLbrSetup AS LaborSetupCost
		, d.Labor * s.HourlyRateLbr AS LaborRunCost
		, (d.Labor * s.HourlyRateLbr) * (s.LaborPctOvhd / 100) AS LaborOverhead
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpTimeSum s ON r.TransId = s.TransId 
		INNER JOIN 
		(
			SELECT TransId, TransDate, VarianceCode
				, QtyProduced, QtyScrapped, EmployeeId, BeginTime, EndTime
				, MachineSetup / (CASE WHEN ISNULL(MachineSetupIn, 0) = 0 THEN 1 ELSE MachineSetupIn END) AS MachineSetup 
				, MachineRun / (CASE WHEN ISNULL(MachineRunIn, 0) = 0 THEN 1 ELSE MachineRunIn END) AS MachineRun
				, LaborSetup / (CASE WHEN ISNULL(LaborSetupIn, 0) = 0 THEN 1 ELSE LaborSetupIn END) AS LaborSetup
				, Labor / (CASE WHEN ISNULL(LaborIn, 0) = 0 THEN 1 ELSE LaborIn END) AS Labor
				, Notes	
			FROM dbo.tblMpTimeDtl) d ON s.TransId = d.TransId 
				LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode 
				INNER JOIN dbo.tblMpOrder p ON o.OrderNo = p.OrderNo 
	WHERE @IncludeProcesses = 1 
		AND (@ItemIdFrom IS NULL OR p.AssemblyId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR p.AssemblyId <= @ItemIdThru) 
		AND (@EmployeeIdFrom IS NULL OR d.EmployeeId >= @EmployeeIdFrom) AND (@EmployeeIdThru IS NULL OR d.EmployeeId <= @EmployeeIdThru) 
		AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

	--Subcontracted
	SELECT CASE @SortBy 
			WHEN 0 THEN d.VendorId 
			WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
			ELSE CONVERT(nvarchar(8), d.TransDate, 112) END AS SortBy
		, o.OrderNo, o.ReleaseNo, o.EstCompletionDate, r.ReqId, d.VendorID, d.VendorDocNo
		, vend.[Name], d.TransDate, d.QtySent, d.QtyReceived, d.QtyScrapped
		, d.VarianceCode, v.Descr VarianceDescription, d.Notes 
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpSubContractDtl d ON r.TransId = d.TransId 
		LEFT JOIN dbo.tblApVendor vend ON d.VendorId = vend.VendorId 
		LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode 
		INNER JOIN dbo.tblMpOrder p ON o.OrderNo = p.OrderNo 
	WHERE @IncludeSubcontracted = 1 
		AND (@ItemIdFrom IS NULL OR p.AssemblyId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR p.AssemblyId <= @ItemIdThru)
		AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

	--Subassemblies
	SELECT CASE @SortBy 
			WHEN 0 THEN d.ComponentId 
			WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
			ELSE CONVERT(nvarchar(8), d.TransDate, 112) END AS SortBy
		, o.OrderNo, o.ReleaseNo, o.EstCompletionDate, r.ReqId, d.ComponentId AS AssemblyID, d.LocId AS Location
		, i.[Description], d.TransDate, d.ActualScrap AS QtyScrapped, d.UOM AS Unit
		, CASE WHEN d.SubAssemblyTranType = -1 THEN d.Qty ELSE 0 END  AS MovedToStock
		, CASE WHEN d.SubAssemblyTranType = 1 THEN d.Qty ELSE 0 END  AS PulledFromStock
		, d.VarianceCode, v.Descr VarianceDescription, d.Notes 
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
		INNER JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId 
		LEFT JOIN dbo.tblMbAssemblyHeader i ON d.ComponentId = i.AssemblyId 
		LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode 
	WHERE @IncludeSubassemblies = 1 
		AND (i.DfltRevYn IS NULL OR i.DfltRevYn = 1) AND (s.ComponentType = 2) --non-stocked
		AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru) 
		AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

	--Finished Goods
	SELECT CASE @SortBy 
			WHEN 0 THEN d.ComponentId 
			WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
			ELSE CONVERT(nvarchar(8), d.TransDate, 112) END AS SortBy
		,o.OrderNo, o.ReleaseNo, o.EstCompletionDate, r.ReqId, d.LocId AS Location
		, i.[Description], d.TransDate, d.Qty AS QtyCompleted, d.ActualScrap AS QtyScrapped, d.UOM AS Unit
		, d.VarianceCode, v.Descr AS VarianceDescription, d.Notes, d.TransId, d.SeqNo, d.ComponentID AS AssemblyID 
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
		INNER JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId 
		LEFT JOIN dbo.tblMbAssemblyHeader i ON d.ComponentId = i.AssemblyId 
		LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode 
	WHERE @IncludeFinishedGoods = 1 
		AND (i.DfltRevYn IS NULL OR i.DfltRevYn = 1) AND (s.ComponentType = 0) --assembly/finished goods
		AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru) 
		AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

	--Lot Numbers
	SELECT l.TransId, l.EntryNum, l.LotNum, l.QtyFilled 
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlDtlExt l ON r.TransId = l.TransId 
	WHERE l.LotNum IS NOT NULL

	--Serial Numbers
	SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum, s.CostUnit 
	FROM #tmpOrderReleaseList tmp 
		INNER JOIN dbo.tblMpOrderReleases o ON tmp.Id = o.Id 
		INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpMatlSer s ON r.TransId = s.TransId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionActivity_proc';

