
--PET:http://problemtrackingsystem.osas.com/view.php?id=263034

CREATE Procedure [dbo].[trav_MpWorkCentersLoadProfile_proc]
AS
BEGIN TRY
SET NOCOUNT ON

CREATE TABLE #tmpRequirements 
(
	TransId int  NOT NULL,
	ReleaseId int NOT NULL,
	ReqId int NOT NULL,
	ParentId int NULL,
	[Type] tinyint NOT NULL,
	BLT int NOT NULL,
	QTY pDecimal NOT NULL,
	ReqSeq int NOT NULL,	
	EstCompletionDate datetime	
)

CREATE TABLE #tmpReqsOpTime 
(
	TransId int  NOT NULL, 
	OpTime int NULL
)

Create table #tmpMpWCLoadProfile
(	
	TransId int  NOT NULL,
	ParentId int NULL,
	[Status] tinyint Null,
	OrderNo pTransId Null,
	ReleaseNo int Null,
	ReqId int Null,
	AssemblyId pItemId Null,
	WorkCenterId nvarchar(10) Null,
	MachineGroupId nvarchar(10) Null,
	LaborTypeId nvarchar(10) Null,
	Qty pDecimal Null DEFAULT(0),
	RemainingHours pDecimal Null DEFAULT(0),
	RequiredDate datetime NULL,
	ReqFinishDate datetime NULL,
	LeadTime int NULL DEFAULT(0),
)

INSERT INTO #tmpRequirements(TransId, ReleaseId, ReqId, ParentId, [Type], BLT, r.QTY, ReqSeq, EstCompletionDate)
SELECT r.TransId, r.ReleaseId, r.ReqId, r.ParentId, r.[Type], r.BLT, r.QTY, r.ReqSeq, o.EstCompletionDate
FROM #tmpWorkCentersLoadlist t INNER JOIN dbo.tblMpRequirements r ON t.TransId = r.TransId 
	INNER JOIN dbo.tblMpOrderReleases o ON r.ReleaseId = o.Id

INSERT INTO #tmpReqsOpTime(TransId, OpTime)
	SELECT TransId, OpTime
	FROM  ( SELECT r.TransId, CAST(ISNULL(CASE WHEN r.Type = 1 THEN c.EstTime ELSE c.BLTTime END, 0) AS int)  AS OpTime
			FROM  dbo.#tmpRequirements AS r 
				INNER JOIN ( SELECT r1.TransId, CASE WHEN isnull(s.OverlapYn, 0) = 0 THEN isnull(s.MoveTimeEst, 0) + isnull(s.WaitTimeEst, 0) 
								   ELSE 0 END + ISNULL(CASE WHEN s.MachineSetupEst > s.LaborSetupEst THEN s.MachineSetupEst ELSE s.LaborSetupEst END, 0) 
								   + ISNULL(s.QueueTimeEst, 0) + ISNULL(CASE WHEN s.MachineRunEst > s.LaborEst THEN s.MachineRunEst ELSE s.LaborEst END, 0) 
								   AS EstTime, r1.BLT - COALESCE
									   (( SELECT TOP (1) BLT
										   FROM dbo.tblMpRequirements AS r2
										   WHERE (ParentId = r1.ParentId) AND (ReqSeq > r1.ReqSeq)
										   ORDER BY ReqSeq),
										( SELECT BLT
										   FROM  dbo.tblMpRequirements AS r3
										   WHERE TransId = r1.ParentId)
									  ) AS BLTTime
							FROM  dbo.#tmpRequirements AS r1 				
								LEFT OUTER JOIN  ( SELECT     s1.TransId, s1.OverlapYn, s1.MoveTimeEst, s1.WaitTimeEst, s1.QueueTimeEst, s1.MachineSetupEst, 
													ISNULL(d1.MachineSetupAct, 0) AS MachSetupAct, CASE WHEN s1.MachineSetupEst > isnull(d1.MachineSetupAct, 0) 
													THEN s1.MachineSetupEst - isnull(d1.MachineSetupAct, 0) ELSE 0 END AS MachineSetupRemain, s1.MachineRunEst, 
													ISNULL(d1.MachineRunAct, 0) AS MachineRunAct, CASE WHEN s1.MachineRunEst > isnull(d1.MachineRunAct, 0) 
													THEN s1.MachineRunEst - isnull(d1.MachineRunAct, 0) ELSE 0 END AS MachineRunRemain, s1.LaborSetupEst, 
													ISNULL(d1.LaborSetupAct, 0) AS LaborSetupAct, CASE WHEN s1.LaborSetupEst > isnull(d1.LaborSetupAct, 0) 
													THEN s1.LaborSetupEst - isnull(d1.LaborSetupAct, 0) ELSE 0 END AS LaborSetupRemain, s1.LaborEst
												 FROM dbo.tblMpTimeSum AS s1 
													LEFT OUTER JOIN (SELECT  TransId, SUM(ISNULL(MachineSetup / (MachineSetupIn / 60.0), 0)) AS MachineSetupAct, 
																		 SUM(ISNULL(MachineRun / (MachineRunIn / 60.0), 0)) AS MachineRunAct, 
																		 SUM(ISNULL(LaborSetup / (LaborSetupIn / 60.0), 0)) AS LaborSetupAct, SUM(ISNULL(Labor / (LaborIn / 60.0), 0)) AS LaborAct
																  FROM dbo.tblMpTimeDtl
																  GROUP BY TransId
																) AS d1 ON s1.TransId = d1.TransId
												) AS s ON s.TransId = r1.TransId
							) AS c ON r.TransId = c.TransId
		) AS ReqsOpTime

INSERT INTO #tmpMpWCLoadProfile(TransId, ParentId, [Status], OrderNo, ReleaseNo, ReqId, WorkCenterId, MachineGroupId, LaborTypeId, RequiredDate, LeadTime, ReqFinishDate) 	  
SELECT tmp.TransId, r.ParentId, CASE WHEN o.[Status] <> 4 THEN 0 ELSE CASE WHEN ISNULL(d.DetailCount,0) > 0 THEN 1 ELSE 2 END END, --0 complete/1 current/2 future  
	o.OrderNo, o.ReleaseNo, r.ReqId, s.WorkCenterId, s.MachineGroupId, s.LaborTypeId, r.EstStartDate, t.OpTime, r.EstCompletionDate
FROM #tmpWorkCentersLoadlist tmp INNER JOIN dbo.tblMpTimeSum s ON tmp.TransId = s.TransId
	INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId 
	INNER JOIN dbo.tblMpOrderReleases o  ON o.Id=r.ReleaseId 
	INNER JOIN dbo.#tmpReqsOpTime t ON s.Transid = t.TransId  	
	LEFT JOIN (SELECT TransId, COUNT(*) AS DetailCount, SUM(QtyProduced) AS QtyProduced FROM dbo.tblMpTimeDtl GROUP BY TransId) d ON s.TransId = d.TransId
WHERE ((o.[Status] = 6) --Completed Orders  
	OR (o.[Status] = 4 AND ISNULL(d.DetailCount,0) > 0) --(current orders)Inprocess orders with activity  
	OR (o.[Status] = 4 AND ISNULL(d.DetailCount,0) = 0) )

--set/update additional fields (all status values)
UPDATE #tmpMpWCLoadProfile SET AssemblyId = s.ComponentId
FROM #tmpMpWCLoadProfile INNER JOIN dbo.tblMpRequirements r ON #tmpMpWCLoadProfile.ParentId = r.TransId 
	INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId

UPDATE #tmpMpWCLoadProfile SET Qty = CASE [Status] WHEN 0 THEN d.QtyProduced WHEN 1 THEN d.QtyToProcess WHEN 2 THEN d.QtyProducedEst ELSE 0 END, 
	RemainingHours = CASE [Status] WHEN 0 THEN 0 WHEN 1 THEN CASE WHEN d.RemainingHours > 0 THEN d.RemainingHours ELSE 0 END WHEN 2 THEN d.EstHours ELSE 0 END
FROM #tmpMpWCLoadProfile INNER JOIN 
	(SELECT s.TransId, ISNULL(SUM(QtyProduced),0) AS QtyProduced, (MAX(s.QtyProducedEst) - ISNULL(SUM(QtyProduced),0)) AS QtyToProcess,
		MAX(s.QtyProducedEst) AS QtyProducedEst, CAST(MAX(s.LaborSetupEst + s.LaborEst + s.MachineSetupEst + s.MachineRunEst) as decimal) / 60.0 AS EstHours,
		(CAST(MAX(s.LaborSetupEst + s.LaborEst + s.MachineSetupEst + s.MachineRunEst) as decimal) / 60.0) - 
		(ISNULL(SUM(d.LaborSetup / d.LaborSetupIn),0) + ISNULL(SUM(Labor / LaborIn),0) + ISNULL(SUM(MachineSetup / MachineSetupIn),0) + ISNULL(SUM(MachineRun / MachineRunIn),0)) AS RemainingHours
		FROM dbo.tblMpTimeSum s LEFT JOIN dbo.tblMpTimeDtl d ON s.TransId = d.TransId GROUP BY s.TransId) d ON #tmpMpWCLoadProfile.TransId = d.TransId

---Main
SELECT  t.WorkCenterId, w.Descr 
FROM dbo.#tmpMpWCLoadProfile AS t 
	INNER JOIN  dbo.tblMrWorkCenter AS w ON t.WorkCenterId = w.WorkCenterId
GROUP BY t.WorkCenterId, w.Descr 
  
--upcoming
SELECT WorkCenterId, RequiredDate, CAST(CONVERT(nvarchar(8), RequiredDate, 112) AS nvarchar) AS RequiredDateSortBy
	, OrderNo, ReleaseNo, ReqId, AssemblyId, MachineGroupId, LaborTypeId, Qty, RemainingHours, ReqFinishDate 
FROM dbo.#tmpMpWCLoadProfile 
WHERE [Status] = 2 

 --Current
SELECT WorkCenterId, RequiredDate, CAST(CONVERT(nvarchar(8), RequiredDate, 112) AS nvarchar) AS RequiredDateSortBy
	, OrderNo, ReleaseNo, ReqId, AssemblyId, MachineGroupId, LaborTypeId, Qty, RemainingHours, ReqFinishDate 
FROM #tmpMpWCLoadProfile 
WHERE [Status] = 1 

---Completed
SELECT WorkCenterId, RequiredDate
	, CAST(CONVERT(nvarchar(8), RequiredDate, 112) AS nvarchar) AS RequiredDateSortBy
	, OrderNo, ReleaseNo, ReqId, AssemblyId, MachineGroupId, LaborTypeId, Qty, ReqFinishDate 
FROM #tmpMpWCLoadProfile 
WHERE [Status] = 0 



END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpWorkCentersLoadProfile_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpWorkCentersLoadProfile_proc';

