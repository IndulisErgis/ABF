
CREATE PROCEDURE trav_MpVarianceCodeHistory_proc
@VarianceCodeFrom nvarchar(10) = null,
@VarianceCodeThru nvarchar(10) = null,
@DateFrom datetime = null,
@DateThru datetime = null
AS

BEGIN TRY
SET NOCOUNT ON

SELECT 1

--Material
SELECT d.VarianceCode, v.Descr VarianceDescr, d.TransDate, o.OrderNo, o.ReleaseNo, r.ReqId, d.ComponentId Identifier
	, s.EstQtyRequired Estimated, s.UOM EstUOM, d.Qty Actual, d.ActualScrap Scrap, d.UOM ActUOM, d.Notes
FROM dbo.tblMpHistoryOrderReleases o INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId  
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE d.VarianceCode IS NOT NULL AND (@VarianceCodeFrom IS NULL OR d.VarianceCode >= @VarianceCodeFrom) AND (@VarianceCodeThru IS NULL OR d.VarianceCode <= @VarianceCodeThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)
	AND (s.ComponentType = 3 OR s.ComponentType = 4) --stocked OR material 
	
 --Byproduct 
SELECT d.VarianceCode, v.Descr VarianceDescr, d.TransDate, o.OrderNo, o.ReleaseNo, r.ReqId, d.ComponentId Identifier
	, s.EstQtyRequired Estimated, s.UOM EstUOM, d.Qty Actual, d.ActualScrap Scrap, d.UOM ActUOM, d.Notes
FROM dbo.tblMpHistoryOrderReleases o INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId  
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE d.VarianceCode IS NOT NULL AND (@VarianceCodeFrom IS NULL OR d.VarianceCode >= @VarianceCodeFrom) AND (@VarianceCodeThru IS NULL OR d.VarianceCode <= @VarianceCodeThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)
	AND (s.ComponentType = 5) --byproduct

 --Operations
 SELECT d.VarianceCode, v.Descr VarianceDescr, d.TransDate
	, o.OrderNo, o.ReleaseNo, r.ReqId, s.WorkCenterId Identifier
	, CASE WHEN s.MachineSetupEst > s.LaborSetupEst THEN s.MachineSetupEst ELSE s.LaborSetupEst END EstSetup
	, CASE WHEN s.MachineRunEst > s.LaborEst THEN s.MachineRunEst ELSE s.LaborEst END EstRun
	, CASE WHEN d.MachineSetup > d.LaborSetup THEN d.MachineSetup ELSE d.LaborSetup END ActSetup
	, CASE WHEN d.MachineRun > d.Labor THEN d.MachineRun ELSE d.Labor END ActRun
	, s.QtyProducedEst Estimated, d.QtyProduced Actual, d.Notes
FROM dbo.tblMpHistoryOrderReleases o INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId  
	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN (SELECT PostRun, TransId, TransDate, VarianceCode, QtyProduced
		, MachineSetup / CASE WHEN ISNULL(MachineSetupIn, 0) = 0 THEN 1 ELSE MachineSetupIn END MachineSetup
		, MachineRun / CASE WHEN ISNULL(MachineRunIn, 0) = 0 THEN 1 ELSE MachineRunIn END MachineRun
		, LaborSetup / CASE WHEN ISNULL(LaborSetupIn, 0) = 0 THEN 1 ELSE LaborSetupIn END LaborSetup
		, Labor / CASE WHEN ISNULL(LaborIn, 0) = 0 THEN 1 ELSE LaborIn END Labor, Notes
		FROM dbo.tblMpHistoryTimeDtl) d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE d.VarianceCode IS NOT NULL AND (@VarianceCodeFrom IS NULL OR d.VarianceCode >= @VarianceCodeFrom) AND (@VarianceCodeThru IS NULL OR d.VarianceCode <= @VarianceCodeThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

--Subcontract 
SELECT d.VarianceCode, v.Descr VarianceDescr, d.TransDate, o.OrderNo, o.ReleaseNo, r.ReqId, d.VendorId Identifier
	, d.QtySent, d.QtyReceived, d.QtyScrapped, d.Notes
FROM dbo.tblMpHistoryOrderReleases o INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId  
	INNER JOIN dbo.tblMpHistorySubContractDtl d ON r.PostRun = d.PostRun And r.TransId = d.TransId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE d.VarianceCode IS NOT NULL AND (@VarianceCodeFrom IS NULL OR d.VarianceCode >= @VarianceCodeFrom) AND (@VarianceCodeThru IS NULL OR d.VarianceCode <= @VarianceCodeThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru)

--Subassembly
SELECT d.VarianceCode, v.Descr VarianceDescr, d.TransDate, o.OrderNo, o.ReleaseNo, r.ReqId, d.ComponentId Identifier
	, s.EstQtyRequired Estimated, s.UOM EstUOM, d.Qty Actual, d.ActualScrap Scrap, d.UOM ActUOM, d.Notes
FROM dbo.tblMpHistoryOrderReleases o INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId  
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE d.VarianceCode IS NOT NULL AND (@VarianceCodeFrom IS NULL OR d.VarianceCode >= @VarianceCodeFrom) AND (@VarianceCodeThru IS NULL OR d.VarianceCode <= @VarianceCodeThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru) 
	AND (s.ComponentType = 2) --non-stocked subassemblies

--Finished Goods 
SELECT d.VarianceCode, v.Descr VarianceDescr, d.TransDate, o.OrderNo, o.ReleaseNo, r.ReqId, d.ComponentId Identifier
	, s.EstQtyRequired Estimated, s.UOM EstUOM, d.Qty Actual, d.ActualScrap Scrap, d.UOM ActUOM, d.Notes
FROM dbo.tblMpHistoryOrderReleases o INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId  
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
	INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
	LEFT JOIN dbo.tblMpVarianceCodes v ON d.VarianceCode = v.VarianceCode
WHERE d.VarianceCode IS NOT NULL AND (@VarianceCodeFrom IS NULL OR d.VarianceCode >= @VarianceCodeFrom) AND (@VarianceCodeThru IS NULL OR d.VarianceCode <= @VarianceCodeThru)
	AND (@DateFrom IS NULL OR d.TransDate >= @DateFrom) AND (@DateThru IS NULL OR d.TransDate <= @DateThru) 
	AND (s.ComponentType = 0) --finished goods/main assembly

END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpVarianceCodeHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpVarianceCodeHistory_proc';

