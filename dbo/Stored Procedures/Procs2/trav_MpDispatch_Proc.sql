
--PET:http://problemtrackingsystem.osas.com/view.php?id=263034
--PET:http://problemtrackingsystem.osas.com/view.php?id=265152

CREATE PROCEDURE [dbo].[trav_MpDispatch_Proc]  

      @ResourceType tinyint = 1,
      @ResourceId nvarchar(10) = NULL,
      @SortBy smallInt = 0

AS
SET NOCOUNT ON

BEGIN TRY
                                    
      IF @ResourceType = 1
      BEGIN     
          --WorkCenter
          SELECT CASE @SortBy 
                             WHEN 0 THEN RIGHT(REPLICATE(' ',10) + CAST(s.WSeqNo AS nvarchar), 10)
                             WHEN 1 THEN CAST(CONVERT(nvarchar(8), rq.EstStartDate, 112) AS nvarchar) 
                             WHEN 2 THEN CAST(r.CustId AS nvarchar) 
                             WHEN 3 THEN CAST(r.OrderNo AS nvarchar) 
                             WHEN 4 THEN RIGHT( REPLICATE(' ',10) + CAST(r.Priority AS nvarchar), 10) END AS SortBy,
                CAST(CONVERT(nvarchar(8), rq.EstStartDate, 112) AS nvarchar) AS EstStartDateSort
                , s.WSeqNo SeqNo, r.OrderNo, r.ReleaseNo, rq.ReqId, r.CustId, o.AssemblyID, s.OperationId, s.TransId
                , s.QtyProducedEst, rq.EstCompletionDate AS EstFinishDate, rq.EstStartDate AS EstStartDate, r.Priority
                , ((s.MachineSetupEst + s.MachineRunEst) + (s.LaborSetupEst + s.LaborEst))/ 60.0 AS EstTotalHours
                , (((s.MachineSetupEst + s.MachineRunEst) + (s.LaborSetupEst + s.LaborEst))/ 60.0) 
                - ((ISNULL(d.TotMachSetup, 0) + ISNULL(d.TotMachRun, 0)) + (ISNULL(d.TotLaborSetup, 0) + ISNULL(d.TotLaborRun, 0))) AS EstHoursRemaining,o.RevisionNo 
          FROM dbo.tblMpTimeSum s             
              INNER JOIN dbo.tblMpRequirements rq ON rq.TransId = s.TransId                 
              INNER JOIN dbo.tblMpOrderReleases r ON  r.Id = rq.ReleaseId
              INNER JOIN dbo.tblMpOrder o ON r.OrderNo = o.OrderNo 
              LEFT JOIN ( SELECT TransId, SUM(MachineSetup / MachineSetupIn)  TotMachSetup, SUM(MachineRun / MachineRunIn) TotMachRun 
                                  , SUM(LaborSetup / LaborSetupIn) TotLaborSetup, SUM(Labor / LaborIn) TotLaborRun 
                                FROM dbo.tblMpTimeDtl GROUP BY TransId
                            ) d ON s.TransId = d.TransId
          WHERE s.WorkCenterID = @ResourceId AND s.Status <> 6 
      END
      ELSE IF @ResourceType = 2
      BEGIN
          --Machine Group
          SELECT CASE @SortBy 
                             WHEN 0 THEN RIGHT(REPLICATE(' ',10) + CAST(s.MSeqNo AS nvarchar), 10)
                             WHEN 1 THEN CAST(CONVERT(nvarchar(8), rq.EstStartDate, 112) AS nvarchar) 
                             WHEN 2 THEN CAST(r.CustId AS nvarchar) 
                             WHEN 3 THEN CAST(r.OrderNo AS nvarchar) 
                             WHEN 4 THEN RIGHT( REPLICATE(' ',10) + CAST(r.Priority AS nvarchar), 10) END AS SortBy,
                CAST(CONVERT(nvarchar(8), rq.EstStartDate, 112) AS nvarchar) AS EstStartDateSort
                , s.MSeqNo SeqNo, r.OrderNo, r.ReleaseNo, rq.ReqId, r.CustId, o.AssemblyID, s.OperationId, s.TransId, s.QtyProducedEst, rq.EstCompletionDate AS EstFinishDate
                , rq.EstStartDate AS EstStartDate, r.Priority, (s.MachineSetupEst + s.MachineRunEst) / 60.0 AS EstTotalHours
                , ((s.MachineSetupEst + s.MachineRunEst) / 60.0) - (ISNULL(d.TotMachSetup, 0) + ISNULL(d.TotMachRun, 0)) AS EstHoursRemaining,o.RevisionNo 
          FROM dbo.tblMpTimeSum s 
                INNER JOIN dbo.tblMpRequirements rq ON rq.TransId = s.TransId         
                INNER JOIN dbo.tblMpOrderReleases r ON r.Id = rq.ReleaseId 
                INNER JOIN dbo.tblMpOrder o ON r.OrderNo = o.OrderNo 
                LEFT JOIN ( SELECT TransId, SUM(MachineSetup / MachineSetupIn) TotMachSetup, SUM(MachineRun / MachineRunIn) TotMachRun 
                                  FROM dbo.tblMpTimeDtl GROUP BY TransId
                                ) d ON s.TransId = d.TransId
          WHERE s.MachineGroupID = @ResourceId AND s.Status <> 6 
      END
      ELSE
      BEGIN
          --LaborType
          SELECT CASE @SortBy 
                             WHEN 0 THEN RIGHT(REPLICATE('0',10) + CAST(s.LSeqNo AS nvarchar), 10)
                             WHEN 1 THEN CAST(CONVERT(nvarchar(8), rq.EstStartDate, 112) AS nvarchar) 
                             WHEN 2 THEN CAST(r.CustId AS nvarchar) 
                             WHEN 3 THEN CAST(r.OrderNo AS nvarchar) 
                             WHEN 4 THEN RIGHT( REPLICATE(' ',10) + CAST(r.Priority AS nvarchar), 10) END AS SortBy,
                CAST(CONVERT(nvarchar(8), rq.EstStartDate, 112) AS nvarchar) AS EstStartDateSort
          , s.LSeqNo SeqNo, r.OrderNo, r.ReleaseNo, rq.ReqId, r.CustId, o.AssemblyID, s.OperationId, s.TransId, s.QtyProducedEst, rq.EstCompletionDate AS EstFinishDate
		  , rq.EstStartDate AS EstStartDate, r.Priority, (s.LaborSetupEst + s.LaborEst) / 60.0 AS EstTotalHours
          , ((s.LaborSetupEst + s.LaborEst) / 60.0) - (ISNULL(d.TotLaborSetup, 0) + ISNULL(d.TotLaborRun, 0)) AS EstHoursRemaining ,o.RevisionNo 
          FROM dbo.tblMpTimeSum s 
                INNER JOIN dbo.tblMpRequirements rq ON rq.TransId = s.TransId         
                INNER JOIN dbo.tblMpOrderReleases r ON r.Id = rq.ReleaseId 
                INNER JOIN dbo.tblMpOrder o ON r.OrderNo = o.OrderNo 
                LEFT JOIN ( SELECT TransId, SUM(LaborSetup / LaborSetupIn) TotLaborSetup, SUM(Labor / LaborIn) TotLaborRun 
                                  FROM dbo.tblMpTimeDtl GROUP BY TransId
                                ) d ON s.TransId = d.TransId
          WHERE (s.LaborTypeId = @ResourceId OR s.LaborSetupTypeId = @ResourceId) AND s.Status <> 6 
      END

END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpDispatch_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpDispatch_Proc';

