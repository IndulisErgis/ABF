
--PET:http://webfront:801/view.php?id=240316

CREATE PROCEDURE dbo.trav_DbMpProductionWorkLoad_proc
@ItemCount int, 
@MachineLabor tinyint -- 0 = Machine, 1 = Labor

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmpOrderRelease
	(
		ReleaseId int NOT NULL 
		PRIMARY KEY CLUSTERED (ReleaseId)
	)

	CREATE TABLE #tmpDetail
	(
		Id nvarchar(10), 
		RemHours Decimal(28,10) NOT NULL DEFAULT(0)	
	)

	CREATE TABLE #tmpResults
	(
		Id nvarchar(10), 
		RemHours Decimal(28,10) NOT NULL DEFAULT(0)	
	)

	INSERT INTO #tmpOrderRelease (ReleaseId) 
	SELECT r.Id 
	FROM dbo.tblMpOrderReleases r 
		INNER JOIN dbo.tblMpOrder o ON o.OrderNo = r.OrderNo
	WHERE r.[Status] = 4

	IF (@MachineLabor = 0)
	BEGIN
		INSERT INTO #tmpDetail (Id, RemHours) 
		SELECT Id, SUM(RemHours) AS RemHours 
		FROM
			(
				SELECT s.MachineGroupId AS Id
					, CASE WHEN ((s.MachineRunEst / 60.0) - ISNULL(d.ActualHours, 0)) < 0 THEN 0 
						ELSE ((s.MachineRunEst / 60.0) - ISNULL(d.ActualHours, 0)) END AS RemHours 
				FROM dbo.tblMpTimeSum s	
					LEFT JOIN 
						(
							SELECT TransId, SUM(COALESCE(MachineRun / MachineRunIn, 0)) AS ActualHours 
							FROM dbo.tblMpTimeDtl 
							GROUP BY TransId
						) d ON d.TransId = s.TransId 
					INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId 
					INNER JOIN dbo.tblMpOrderReleases o ON o.Id = r.ReleaseId 
					INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
					INNER JOIN #tmpOrderRelease t ON  o.Id = t.ReleaseId 
				WHERE ISNULL(s.MachineGroupId, '') <> '' AND s.[Status] <> 6
				UNION ALL
				SELECT s.MachineGroupId AS Id
					, CASE WHEN ((s.MachineSetupEst / 60.0) - ISNULL(d.ActualHours, 0)) < 0 THEN 0 
						ELSE ((s.MachineSetupEst / 60.0) - ISNULL(d.ActualHours, 0)) END AS RemHours 
				FROM dbo.tblMpTimeSum s	
					LEFT JOIN 
						(
							SELECT TransId, SUM(COALESCE(MachineSetup / MachineSetupIn, 0)) AS ActualHours 
							FROM dbo.tblMpTimeDtl 
							GROUP BY TransId
						) d ON d.TransId = s.TransId 
					INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId 
					INNER JOIN dbo.tblMpOrderReleases o ON o.Id = r.ReleaseId 
					INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
					INNER JOIN #tmpOrderRelease t ON  o.Id = t.ReleaseId
				WHERE ISNULL(s.MachineGroupId, '') <> '' AND s.[Status] <> 6
			) r 
			WHERE RemHours > 0 
			GROUP BY r.Id
	END
	ELSE
	BEGIN
		INSERT INTO #tmpDetail (Id, RemHours) 
		SELECT Id, SUM(RemHours) AS RemHours 
		FROM
			(
				SELECT s.LaborTypeId AS Id
					, CASE WHEN ((s.LaborEst / 60.0) - ISNULL(d.ActualHours, 0)) < 0 THEN 0 
						ELSE ((s.LaborEst / 60.0) - ISNULL(d.ActualHours, 0)) END AS RemHours 
				FROM dbo.tblMpTimeSum s	
					LEFT JOIN 
						(
							SELECT TransId, SUM(COALESCE(Labor / LaborIn, 0)) AS ActualHours 
							FROM dbo.tblMpTimeDtl 
							GROUP BY TransId
						) d ON d.TransId = s.TransId 
					INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId 
					INNER JOIN dbo.tblMpOrderReleases o ON o.Id = r.ReleaseId 
					INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
					INNER JOIN #tmpOrderRelease t ON  o.Id = t.ReleaseId 
				WHERE ISNULL(s.LaborTypeId, '') <> '' AND s.[Status] <> 6
				UNION ALL
				SELECT s.LaborSetupTypeId AS Id
					, CASE WHEN ((s.LaborSetupEst / 60.0) - ISNULL(d.ActualHours, 0)) < 0 THEN 0 
						ELSE ((s.LaborSetupEst / 60.0) - ISNULL(d.ActualHours, 0)) END AS RemHours 
				FROM dbo.tblMpTimeSum s	
					LEFT JOIN 
						(
							SELECT TransId, SUM(COALESCE(LaborSetup / LaborSetupIn, 0)) AS ActualHours 
							FROM dbo.tblMpTimeDtl 
							GROUP BY TransId
						) d ON d.TransId = s.TransId 
					INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId 
					INNER JOIN dbo.tblMpOrderReleases o ON o.Id = r.ReleaseId 
					INNER JOIN dbo.tblMpOrder h ON o.OrderNo = h.OrderNo
					INNER JOIN #tmpOrderRelease t ON  o.Id = t.ReleaseId 
				WHERE ISNULL(s.LaborSetupTypeId, '') <> '' AND s.[Status] <> 6
			) r 
			WHERE RemHours > 0 
			GROUP BY r.Id
	END

	INSERT INTO #tmpResults(Id, RemHours) 
	SELECT Id, SUM(RemHours) AS RemHours 
	FROM #tmpDetail 
	GROUP BY Id

	SET ROWCOUNT @ItemCount

	SELECT Id, RemHours 
	FROM #tmpResults ORDER BY RemHours DESC

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbMpProductionWorkLoad_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbMpProductionWorkLoad_proc';

