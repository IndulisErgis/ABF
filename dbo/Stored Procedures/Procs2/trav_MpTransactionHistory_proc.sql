
CREATE PROCEDURE trav_MpTransactionHistory_proc
@SortBy tinyint = 0 ,--0=assembly/workcenter/vendor - 1=Order/release - 2=CompletionDate
@EmployeeIdFrom pEmpID = null,
@EmployeeIdThru pEmpID = null,
@DateFrom datetime = null,
@DateThru datetime = null,
@ItemIdFrom pItemId = null,
@ItemIdThru pItemId = null,
@IncludeMaterials bit = 1,
@IncludeByproducts bit = 1,
@IncludeProcesses bit = 1,
@IncludeSubcontracted bit = 1,
@IncludeSubassemblies bit = 1,
@IncludeFinishedGoods bit = 1
AS

BEGIN TRY
SET NOCOUNT ON

--For Main Report
SELECT 1	

--Material
SELECT CASE @SortBy WHEN 0 THEN d.ComponentId WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
	ELSE CONVERT(nvarchar(8), d.TransDate, 112) END SortBy
	, o.OrderNo, o.ReleaseNo,  o.EstCompletionDate, r.ReqId, d.ComponentId, d.LocId
	, i.Descr, d.TransDate, d.Qty, d.ActualScrap, d.UOM
	, d.UnitCost, d.VarianceCode, v.Descr VarianceDescr, d.Notes, d.PostRun, d.TransId, d.SeqNo
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblInItem i ON d.ComponentId = i.ItemId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE @IncludeMaterials = 1 
	AND (s.ComponentType = 3 OR s.ComponentType = 4) --stocked OR material 
	AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)
	
--ByProducts
SELECT CASE @SortBy WHEN 0 THEN d.ComponentId WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
	ELSE CONVERT(nvarchar(8), d.TransDate, 112) END SortBy
	, o.OrderNo, o.ReleaseNo,  o.EstCompletionDate, r.ReqId, d.ComponentId, d.LocId
	, i.Descr, d.TransDate, d.Qty, d.ActualScrap, d.UOM, d.PostRun, d.TransId, d.SeqNo
	, d.UnitCost, d.VarianceCode, v.Descr VarianceDescr, d.Notes
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblInItem i ON d.ComponentId = i.ItemId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE @IncludeByproducts = 1 
	AND (s.ComponentType = 5) --byproduct
	AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

--Process
SELECT CASE @SortBy WHEN 0 THEN s.WorkCenterId WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
	ELSE CONVERT(nvarchar(8), d.TransDate, 112) END SortBy
	, o.OrderNo, o.ReleaseNo,  o.EstCompletionDate, r.ReqId, d.TransDate
	, d.VarianceCode, v.Descr VarianceDescr
	, s.WorkCenterId, s.OperSupervisor, d.EmployeeId, d.BeginTime, d.EndTime
	, s.MachineGroupId, d.MachineSetup, d.MachineRun
	, s.LaborTypeId, d.LaborSetup, d.Labor
	, s.LaborPctOvhd, s.HourlyRateLbr
	, s.MachPctOvhd, s.HourlyCostFactorMach
	, s.PerPieceCostLbr, s.FlatAmtOvhd, s.PerPieceOvhd
	, d.QtyProduced, d.QtyScrapped
	, d.Notes, s.HourlyRateLbrSetup
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN (SELECT PostRun, TransId, TransDate, VarianceCode
	, QtyProduced, QtyScrapped, EmployeeId, BeginTime, EndTime
	, MachineSetup / (CASE WHEN ISNULL(MachineSetupIn, 0) = 0 THEN 1 ELSE MachineSetupIn END)MachineSetup 
	, MachineRun / (CASE WHEN ISNULL(MachineRunIn, 0) = 0 THEN 1 ELSE MachineRunIn END)MachineRun
	, LaborSetup / (CASE WHEN ISNULL(LaborSetupIn, 0) = 0 THEN 1 ELSE LaborSetupIn END)LaborSetup
	, Labor / (CASE WHEN ISNULL(LaborIn, 0) = 0 THEN 1 ELSE LaborIn END)Labor
	, Notes	FROM dbo.tblMpHistoryTimeDtl) d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMpVarianceCodes v 	ON d.VarianceCode = v.VarianceCode
WHERE @IncludeProcesses = 1
	AND (@ItemIdFrom IS NULL OR o.AssemblyId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR o.AssemblyId <= @ItemIdThru)
	AND (@EmployeeIdFrom IS NULL OR d.EmployeeId >= @EmployeeIdFrom) AND (@EmployeeIdThru IS NULL OR d.EmployeeId <= @EmployeeIdThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)
	
--SubContract
SELECT CASE @SortBy WHEN 0 THEN d.VendorId WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
	ELSE CONVERT(nvarchar(8), d.TransDate, 112) END SortBy
	, o.OrderNo, o.ReleaseNo,  o.EstCompletionDate,r.ReqId, d.VendorId, d.VendorDocNo
	, vend.[Name], d.TransDate, d.QtySent, d.QtyReceived, d.QtyScrapped
	, d.VarianceCode, v.Descr VarianceDescr, d.Notes
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistorySubContractDtl d	ON r.PostRun = d.PostRun AND r.TransId = d.TransId 
	LEFT JOIN dbo.tblApVendor vend 	ON d.VendorId = vend.VendorId
	LEFT JOIN dbo.tblMpVarianceCodes v 	ON d.VarianceCode = v.VarianceCode
WHERE @IncludeSubcontracted = 1 
	AND (@ItemIdFrom IS NULL OR o.AssemblyId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR o.AssemblyId <= @ItemIdThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

--SubAssembly
SELECT CASE @SortBy WHEN 0 THEN d.ComponentId WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
	ELSE CONVERT(nvarchar(8), d.TransDate, 112) END SortBy
	, o.OrderNo, o.ReleaseNo,  o.EstCompletionDate, r.ReqId, d.ComponentId, d.LocId
	, i.Description, d.TransDate, d.ActualScrap, d.UOM
	, CASE WHEN d.AssembledYn = 1 THEN d.Qty ELSE 0 END QtyToStock
	, CASE WHEN d.AssembledYn <> 1 THEN d.Qty ELSE 0 END QtyFromStock
	, d.VarianceCode, v.Descr VarianceDescr, d.Notes
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMbAssemblyHeader i ON d.ComponentId = i.AssemblyId
	LEFT JOIN dbo.tblMpVarianceCodes v 	ON d.VarianceCode = v.VarianceCode
WHERE @IncludeSubassemblies = 1
	AND (i.DfltRevYn IS NULL OR i.DfltRevYn = 1) AND (s.ComponentType = 2) --non-stocked
	AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)
	
--Finished Goods
SELECT CASE @SortBy WHEN 0 THEN d.ComponentId WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) 
	ELSE CONVERT(nvarchar(8), d.TransDate, 112) END SortBy
	,o.OrderNo, o.ReleaseNo,  o.EstCompletionDate,r.ReqId, d.LocId
	, i.Description, d.TransDate, d.Qty, d.ActualScrap, d.UOM
	, d.VarianceCode, v.Descr VarianceDescr, d.Notes, d.PostRun, d.TransId, d.SeqNo, d.ComponentID
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMbAssemblyHeader i ON d.ComponentId = i.AssemblyId
	LEFT JOIN dbo.tblMpVarianceCodes v 	ON d.VarianceCode = v.VarianceCode
WHERE @IncludeFinishedGoods = 1 
	AND (i.DfltRevYn IS NULL OR i.DfltRevYn = 1) AND (s.ComponentType = 0) --assembly/finished goods
	AND (@ItemIdFrom IS NULL OR d.ComponentId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR d.ComponentId <= @ItemIdThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

--LotNumber
SELECT l.PostRun, l.TransId, l.EntryNum, l.LotNum, l.QtyFilled 
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlDtlExt l ON r.PostRun = l.PostRun AND r.TransId = l.TransId 
WHERE l.LotNum IS NOT NULL

--Serial Number
SELECT s.PostRun, s.TransId, s.EntryNum, s.LotNum, s.SerNum, s.CostUnit 
FROM #tmpTransHistorylist tmp INNER JOIN dbo.tblMpHistoryOrderReleases o ON tmp.PostRun = o.PostRun AND tmp.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSer s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpTransactionHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpTransactionHistory_proc';

