
CREATE PROCEDURE [dbo].[trav_MpDispatchCalendar_Proc]
      @ResourceType tinyint = 1
AS
SET NOCOUNT ON

BEGIN TRY
	
	CREATE TABLE #tmpRequirements 
	(
		TransId int  NOT NULL,
		ReleaseId int NOT NULL,
		ReqId int NOT NULL,
		ParentId int NULL,
		[Type] tinyint NOT NULL,
		EstCompletionDate datetime NULL,
		ReqSeq int NOT NULL 
	)
      
	CREATE TABLE #tmpReqsFinishDate
	(
		TransId int  NOT NULL,
		ReqFinishDate datetime
	) 
	      
	INSERT INTO #tmpRequirements(TransId, ReleaseId, ReqId, ParentId, [Type], EstCompletionDate, ReqSeq )
	SELECT s.TransId, r.ReleaseId, r.ReqId, r.ParentId, r.[Type], o.EstCompletionDate, r.ReqSeq
	FROM dbo.tblMpTimeSum s 
	INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId
	INNER JOIN dbo.tblMpOrderReleases o ON r.ReleaseId = o.Id  
	INNER JOIN #tmpResourceId  rs ON rs.ResourceId = s.WorkCenterId
	WHERE @ResourceType = 1 AND s.Status <> 6 

	UNION ALL

	SELECT s.TransId, r.ReleaseId, r.ReqId, r.ParentId, r.[Type], o.EstCompletionDate, r.ReqSeq
	FROM dbo.tblMpTimeSum s 
	INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId
	INNER JOIN dbo.tblMpOrderReleases o ON r.ReleaseId = o.Id
	INNER JOIN #tmpResourceId  rs ON rs.ResourceId = s.MachineGroupID     
	WHERE @ResourceType = 2 AND s.Status <> 6 	 

	UNION ALL 

	SELECT s.TransId, r.ReleaseId, r.ReqId, r.ParentId, r.[Type], o.EstCompletionDate, r.ReqSeq
	FROM dbo.tblMpTimeSum s 
	INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId
	INNER JOIN dbo.tblMpOrderReleases o ON r.ReleaseId = o.Id    
	INNER JOIN #tmpResourceId  rs ON rs.ResourceId = s.LaborTypeId OR rs.ResourceId = s.LaborSetupTypeId 
	WHERE @ResourceType = 3  AND s.Status <> 6 	  
      
	INSERT INTO #tmpReqsFinishDate (TransId, ReqFinishDate)
	SELECT t.TransId, CASE WHEN t.Type = 0 THEN t.EstCompletionDate ELSE Pri.RequiredDate END AS ReqFinishDate
	FROM #tmpRequirements t 
    LEFT OUTER JOIN 
	( 
		SELECT  chi.TransId 
		, COALESCE
			((	SELECT TOP (1) TransId
				FROM  dbo.tblMpRequirements AS r1
				WHERE r1.ParentId = chi.ParentId AND r1.ReqSeq > chi.ReqSeq
				ORDER BY ReqSeq ), par.TransId
			) AS PriorTransId
		FROM  dbo.#tmpRequirements AS chi 
        LEFT OUTER JOIN dbo.tblMpRequirements AS par ON chi.ParentId = par.TransId 
	) AS PriorMap ON t.TransId = PriorMap.TransId 
	LEFT OUTER JOIN 
	( 
		SELECT TransId, RequiredDate FROM dbo.tblMpMatlSum
		UNION ALL
		SELECT  TransId, RequiredDate FROM dbo.tblMpTimeSum
		UNION ALL
		SELECT TransId, RequiredDate FROM  dbo.tblMpSubContractSum
	) AS Pri ON PriorMap.PriorTransId = Pri.TransId 
                                    
	IF @ResourceType = 1
	BEGIN
		--WorkCenter
		SELECT CAST(CONVERT(nvarchar(8), s.RequiredDate, 112) AS nvarchar) AS EstStartDateSort
			, s.WSeqNo SeqNo, r.OrderNo, r.ReleaseNo, rq.ReqId, r.CustId, o.AssemblyID, s.OperationId, s.TransId
			, s.QtyProducedEst, t.ReqFinishDate AS EstFinishDate, s.RequiredDate AS EstStartDate, r.Priority
			, ((s.MachineSetupEst + s.MachineRunEst) + (s.LaborSetupEst + s.LaborEst))/ 60.0 AS EstTotalHours
			, (((s.MachineSetupEst + s.MachineRunEst) + (s.LaborSetupEst + s.LaborEst))/ 60.0) 
			- ((ISNULL(d.TotMachSetup, 0) + ISNULL(d.TotMachRun, 0)) + (ISNULL(d.TotLaborSetup, 0) + ISNULL(d.TotLaborRun, 0))) AS EstHoursRemaining 
			, s.WorkCenterID AS ResourceId, r.OrderNo + '/'+ CAST(r.ReleaseNo AS nvarchar)  AS OrderReleaseNumber, rq.[Description] AS Description
		FROM dbo.tblMpTimeSum s             
		INNER JOIN dbo.tblMpRequirements rq ON rq.TransId = s.TransId                 
		INNER JOIN dbo.tblMpOrderReleases r ON  r.Id = rq.ReleaseId
		INNER JOIN dbo.#tmpReqsFinishDate t ON s.TransId = t.TransId
		INNER JOIN dbo.tblMpOrder o ON r.OrderNo = o.OrderNo
		INNER JOIN #tmpResourceId rs ON rs.ResourceId =  s.WorkCenterID
		LEFT JOIN 
		( 
			SELECT TransId
				, SUM(MachineSetup / MachineSetupIn)  TotMachSetup, SUM(MachineRun / MachineRunIn) TotMachRun 
				, SUM(LaborSetup / LaborSetupIn) TotLaborSetup, SUM(Labor / LaborIn) TotLaborRun 
			FROM dbo.tblMpTimeDtl GROUP BY TransId
		) d ON s.TransId = d.TransId
		WHERE s.Status <> 6 
	END
	ELSE IF @ResourceType = 2
	BEGIN
			--Machine Group
			SELECT CAST(CONVERT(nvarchar(8), s.RequiredDate, 112) AS nvarchar) AS EstStartDateSort
				, s.MSeqNo SeqNo, r.OrderNo, r.ReleaseNo, rq.ReqId, r.CustId, o.AssemblyID, s.OperationId, s.TransId, s.QtyProducedEst, t.ReqFinishDate AS EstFinishDate
				, s.RequiredDate AS EstStartDate, r.Priority, (s.MachineSetupEst + s.MachineRunEst) / 60.0 AS EstTotalHours
				, ((s.MachineSetupEst + s.MachineRunEst) / 60.0) - (ISNULL(d.TotMachSetup, 0) + ISNULL(d.TotMachRun, 0)) AS EstHoursRemaining 
				, s.MachineGroupID AS ResourceId,  r.OrderNo + '/'+ CAST(r.ReleaseNo AS nvarchar)  AS OrderReleaseNumber, rq.[Description] AS Description
			FROM dbo.tblMpTimeSum s 
			INNER JOIN dbo.tblMpRequirements rq ON rq.TransId = s.TransId         
			INNER JOIN dbo.tblMpOrderReleases r ON r.Id = rq.ReleaseId 
			INNER JOIN dbo.#tmpReqsFinishDate t ON s.TransId = t.TransId
			INNER JOIN dbo.tblMpOrder o ON r.OrderNo = o.OrderNo 
			INNER JOIN #tmpResourceId rs ON rs.ResourceId =  s.MachineGroupID
			LEFT JOIN 
			( 
				SELECT TransId
					, SUM(MachineSetup / MachineSetupIn) TotMachSetup, SUM(MachineRun / MachineRunIn) TotMachRun 
				FROM dbo.tblMpTimeDtl GROUP BY TransId
			) d ON s.TransId = d.TransId
			WHERE s.Status <> 6 
	END
	ELSE
	BEGIN
			--LaborType
			SELECT CAST(CONVERT(nvarchar(8), s.RequiredDate, 112) AS nvarchar) AS EstStartDateSort
			, s.LSeqNo SeqNo, r.OrderNo, r.ReleaseNo, rq.ReqId, r.CustId, o.AssemblyID, s.OperationId, s.TransId, s.QtyProducedEst, t.ReqFinishDate AS EstFinishDate
			, s.RequiredDate AS EstStartDate, r.Priority, (s.LaborSetupEst + s.LaborEst) / 60.0 AS EstTotalHours
			, ((s.LaborSetupEst + s.LaborEst) / 60.0) - (ISNULL(d.TotLaborSetup, 0) + ISNULL(d.TotLaborRun, 0)) AS EstHoursRemaining 
			, COALESCE(s.LaborTypeId,s.LaborSetupTypeId) AS ResourceId,  r.OrderNo + '/'+ CAST(r.ReleaseNo AS nvarchar)  AS OrderReleaseNumber, rq.[Description] AS Description
			FROM dbo.tblMpTimeSum s 
			INNER JOIN dbo.tblMpRequirements rq ON rq.TransId = s.TransId         
			INNER JOIN dbo.tblMpOrderReleases r ON r.Id = rq.ReleaseId 
			INNER JOIN dbo.#tmpReqsFinishDate t ON s.TransId = t.TransId
			INNER JOIN dbo.tblMpOrder o ON r.OrderNo = o.OrderNo 
			INNER JOIN #tmpResourceId rs ON s.LaborTypeId = rs.ResourceId OR s.LaborSetupTypeId = rs.ResourceId
			LEFT JOIN 
			(	SELECT TransId
					, SUM(LaborSetup / LaborSetupIn) TotLaborSetup, SUM(Labor / LaborIn) TotLaborRun 
				FROM dbo.tblMpTimeDtl GROUP BY TransId
			) d ON s.TransId = d.TransId
			WHERE s.Status <> 6 
	END

END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpDispatchCalendar_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpDispatchCalendar_Proc';

