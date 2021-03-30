
CREATE PROCEDURE [dbo].[trav_MpTimeVarianceAnalysis_proc]

@PrintExceptions bit  = 0,
@CriticalVar pDecimal,
@SortBy tinyint

AS
BEGIN TRY
SET NOCOUNT ON
SELECT * FROM (

SELECT CASE @SortBy 
		WHEN 0 THEN s.OperationId 
		WHEN 1 THEN o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10)
		WHEN 2 THEN CONVERT(nvarchar(8), TransDate, 112) 
		WHEN 3 THEN o.AssemblyId 
		WHEN 4 THEN s.LaborTypeId 
		WHEN 5 THEN s.MachineGroupId END AS GrpId1,
	o.OrderNo, o.ReleaseNo, o.AssemblyID, d.TransDate, o.RevisionNo, s.OperationID, o.Routing AS RoutingStep
	, s.WorkCenterID, s.MachineGroupID, s.LaborTypeID
	, s.MachineSetupEst / 60.0 AS MachineSetupEst
	, s.LaborSetupEst / 60.0 AS LaborSetupEst
	, s.MachineRunEst / 60.0 AS MachineRunEst, s.LaborEst / 60.0 AS LaborRunEst
	, SUM(COALESCE(d.MachineSetup / d.MachineSetupIn, 0))  AS ActMachineSetupHrs
	, SUM(COALESCE(d.MachineRun / d.MachineRunIn, 0))  AS ActMachineRunHrs
	, SUM(COALESCE(d.LaborSetup / d.LaborSetupIn, 0))  AS ActLaborSetupHrs
	, SUM(COALESCE(d.Labor / d.LaborIn, 0))  AS ActLaborRunHrs
	, CASE WHEN s.MachineSetupEst <> 0 THEN CONVERT(int, (SUM(d.MachineSetup / d.MachineSetupIn)
		- (s.MachineSetupEst / 60.0)) * 100 / (s.MachineSetupEst / 60.0)) ELSE 0 END AS MachineSetupVariance
	, CASE WHEN s.LaborSetupEst <> 0 THEN CONVERT(int, (SUM(d.LaborSetup / d.LaborSetupIn)  
		- (s.LaborSetupEst / 60.0)) * 100 / (s.LaborSetupEst / 60.0)) ELSE 0 END AS LaborSetupVariance
	, CASE WHEN s.MachineRunEst <> 0 THEN CONVERT(int, (SUM(d.MachineRun / d.MachineRunIn) 
		- (s.MachineRunEst / 60.0)) * 100 / (s.MachineRunEst / 60.0)) ELSE 0 END AS MachineRunVariance
	, CASE WHEN s.LaborEst <> 0 THEN CONVERT(int, (SUM(d.Labor / d.LaborIn) 
		- (s.LaborEst / 60.0)) * 100 / (s.LaborEst / 60.0 )) ELSE 0 END AS LaborRunVariance
FROM #tmpTimeVarianceAnalysis t INNER JOIN dbo.tblMpHistoryTimeDtl d ON t.postrun = d.PostRun AND t.TransId = d.TransId AND t.SeqNo = d.SeqNo
INNER JOIN dbo.tblMpHistoryTimeSum s ON d.PostRun = s.PostRun AND d.TransId = s.TransId 
INNER JOIN dbo.tblMpHistoryRequirements r ON s.PostRun=r.PostRun AND s.TransId = r.TransId
INNER JOIN dbo.tblMpHistoryOrderReleases o ON  o.PostRun=r.PostRun AND o.ReleaseId = r.ReleaseId
GROUP BY o.OrderNo, o.ReleaseNo, o.AssemblyID, o.RevisionNo, s.OperationID, s.WorkCenterID
	, s.MachineGroupID, s.LaborTypeID, s.MachineSetupEst, s.LaborSetupEst, s.MachineRunEst
	, s.LaborEst, d.TransDate,  o.Routing) tmp
 WHERE ((ABS(tmp.MachineSetupVariance) >= COALESCE(@CriticalVar, 0)
	AND @PrintExceptions = 1) OR (ABS(tmp.LaborSetupVariance)  >= COALESCE(@CriticalVar, 0)
	AND @PrintExceptions = 1) OR (ABS(tmp.MachineRunVariance) >= COALESCE(@CriticalVar, 0) 
	AND @PrintExceptions = 1) OR (ABS(tmp.LaborRunVariance) >= COALESCE(@CriticalVar, 0) 
	AND @PrintExceptions = 1)) OR @PrintExceptions = 0 
	
END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpTimeVarianceAnalysis_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpTimeVarianceAnalysis_proc';

