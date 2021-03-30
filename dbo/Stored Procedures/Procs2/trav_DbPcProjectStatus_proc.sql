
CREATE PROCEDURE dbo.trav_DbPcProjectStatus_proc
@ProjectManager pEmpID = '', 
@HoursDollars tinyint, -- 0 = Hours, 1 = Dollars
@PercentComplete pDecimal, 
@IncludeTask bit, 
@ProjectId int, 
@CurrencyPrecision tinyint, 
@PercentagePrecision tinyint

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmpProjectDetail
	(
		[ProjectDetailId] int NOT NULL, 
		[ActualHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[EstimateHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[ActualCost] decimal(28, 10) NOT NULL DEFAULT(0), 
		[EstimateCost] decimal(28, 10) NOT NULL DEFAULT(0), 
		CONSTRAINT [PK_#tmpProjectDetail] PRIMARY KEY CLUSTERED ([ProjectDetailId]) ON [PRIMARY]
	)

	CREATE TABLE #tmpResults
	(
		[CustId] pCustID NULL, 
		[ProjectId] int NOT NULL, 
		[ProjectName] varchar(10), 
		[ProjectManager] pEmpID, 
		[PhaseId] pPhaseID, 
		[TaskId] pTaskID, 
		[ActualHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[EstimateHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[PercentCompleteHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[ActualCost] decimal(28, 10) NOT NULL DEFAULT(0), 
		[EstimateCost] decimal(28, 10) NOT NULL DEFAULT(0), 
		[PercentCompleteCost] decimal(28, 10) NOT NULL DEFAULT(0), 
	)

	CREATE TABLE #tmpResultsSummary
	(
		[CustId] pCustID NULL, 
		[ProjectId] int NOT NULL, 
		[ProjectName] varchar(10), 
		[ProjectManager] pEmpID, 
		[PhaseId] pPhaseID, 
		[TaskId] pTaskID, 
		[ActualHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[EstimateHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[PercentCompleteHours] decimal(28, 10) NOT NULL DEFAULT(0), 
		[ActualCost] decimal(28, 10) NOT NULL DEFAULT(0), 
		[EstimateCost] decimal(28, 10) NOT NULL DEFAULT(0), 
		[PercentCompleteCost] decimal(28, 10) NOT NULL DEFAULT(0), 
	)

		INSERT INTO #tmpProjectDetail(ProjectDetailId) 
		SELECT d.Id 
		FROM dbo.tblPcProject p 
			INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId 
		WHERE p.Id IN 
			(
				SELECT proj.Id AS ProjectId 
				FROM dbo.tblPcProject proj 
					INNER JOIN dbo.tblPcProjectDetail projdtl ON proj.Id = projdtl.ProjectId 
				WHERE projdtl.TaskId IS NULL AND projdtl.PhaseId IS NULL 
					AND ((@ProjectManager = '') OR (@ProjectManager = projdtl.ProjectManager)) 
					AND d.[Status] <> 2
			) 
			AND ((@IncludeTask = 0) OR (@IncludeTask <> 0 AND p.Id = @ProjectId))

	-- Estimate Hours
	UPDATE #tmpProjectDetail SET EstimateHours = e.Qty 
	FROM #tmpProjectDetail 
		INNER JOIN 
			(
				SELECT d.Id, SUM(e.Qty) AS Qty 
				FROM dbo.tblPcProjectDetail d 
					INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId 
				WHERE e.[Type] = 0
				GROUP BY d.Id
			) e 
			ON #tmpProjectDetail.ProjectDetailId = e.Id

	-- Estimate Cost
	UPDATE #tmpProjectDetail SET EstimateCost = e.EstimateCost 
	FROM #tmpProjectDetail 
		INNER JOIN 
			(
				SELECT d.Id, SUM(ROUND(e.Qty * e.UnitCost, @CurrencyPrecision)) AS EstimateCost 
				FROM dbo.tblPcProjectDetail d 
					INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId 
				WHERE e.[Type] IN (0, 1, 2, 3)
				GROUP BY d.Id
			) e 
			ON #tmpProjectDetail.ProjectDetailId = e.Id

	-- Actual Hours
	UPDATE #tmpProjectDetail SET ActualHours = e.Qty 
	FROM #tmpProjectDetail 
		INNER JOIN 
			(
				SELECT d.Id, SUM(a.Qty) AS Qty 
				FROM dbo.tblPcProjectDetail d 
					INNER JOIN 
						(
							SELECT ProjectDetailId, Qty 
							FROM dbo.tblPcActivity WHERE [Status] < 6 AND [Type] = 0 
							UNION ALL 
							SELECT a.ProjectDetailId, -a.Qty
							FROM dbo.tblPcActivity a 
								INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
							WHERE a.[Source] = 12 AND a.[Type] = 0
						) a 
						ON d.Id = a.ProjectDetailId 
				GROUP BY d.Id
			) e 
			ON #tmpProjectDetail.ProjectDetailId = e.Id

	-- Actual Cost
	UPDATE #tmpProjectDetail SET ActualCost = e.ExtCost 
	FROM #tmpProjectDetail 
		INNER JOIN 
			(
				SELECT d.Id, SUM(a.ExtCost) AS ExtCost 
				FROM dbo.tblPcProjectDetail d 
					INNER JOIN 
						(
							SELECT ProjectDetailId, ExtCost 
							FROM dbo.tblPcActivity WHERE [Status] < 6 AND [Type] IN (0, 1, 2, 3) 
							UNION ALL 
							SELECT a.ProjectDetailId
								, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost / b.Qty) END 
							FROM dbo.tblPcActivity a 
								INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
							WHERE a.[Source] = 12 AND a.[Type] IN (0, 1, 2, 3)
						) a 
						ON d.Id = a.ProjectDetailId 
				GROUP BY d.Id
			) e 
			ON #tmpProjectDetail.ProjectDetailId = e.Id

	INSERT INTO #tmpResults (CustId, ProjectId, ProjectName, ProjectManager, PhaseId, TaskId, ActualHours, EstimateHours, PercentCompleteHours, ActualCost, EstimateCost, PercentCompleteCost) 
	SELECT ISNULL(p.CustId, '') AS CustId, p.Id, p.ProjectName, ISNULL(d.ProjectManager, '') AS ProjectManager
		, d.PhaseId, d.TaskId
		, t.ActualHours, t.EstimateHours
		, CASE WHEN t.EstimateHours = 0 THEN 0 ELSE (t.ActualHours / t.EstimateHours) * 100 END AS PercentCompleteHours
		, t.ActualCost, t.EstimateCost
		, CASE WHEN t.EstimateCost = 0 THEN 0 ELSE (t.ActualCost / t.EstimateCost) * 100 END AS PercentCompleteCost 
	FROM #tmpProjectDetail t 
		INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 

	IF (@IncludeTask = 1)
	BEGIN
		SELECT LEFT(CustId + REPLICATE(' ',10),10) + '/' + ProjectName AS CustProj, CustId, ProjectId, ProjectName
			, ProjectManager, PhaseId, TaskId, ActualHours, EstimateHours, PercentCompleteHours
			, ActualCost, EstimateCost, PercentCompleteCost 
		FROM #tmpResults
	END
	ELSE
	BEGIN
		INSERT INTO #tmpResultsSummary (CustId, ProjectId, ProjectName, ProjectManager, PhaseId, TaskId, ActualHours, EstimateHours, PercentCompleteHours, ActualCost, EstimateCost, PercentCompleteCost) 	
		SELECT ISNULL(p.CustId, '') AS CustId, tmp.ProjectId, p.ProjectName, ISNULL(p.ProjectManager, '') AS ProjectManager, NULL AS PhaseId, NULL AS TaskId
			, ActualHours, EstimateHours
			, ROUND(CASE WHEN EstimateHours = 0 THEN 0 ELSE (ActualHours / EstimateHours) * 100 END, @PercentagePrecision) AS PercentCompleteHours
			, ActualCost, EstimateCost
			, ROUND(CASE WHEN EstimateCost = 0 THEN 0 ELSE (ActualCost / EstimateCost) * 100 END, @PercentagePrecision) AS PercentCompleteCost 
		FROM 
			(
				SELECT ProjectId
					, SUM(ActualHours) AS ActualHours, SUM(EstimateHours) AS EstimateHours
					, SUM(ActualCost) AS ActualCost, SUM(EstimateCost) AS EstimateCost
				FROM #tmpResults
				GROUP BY ProjectId
			) tmp 
			INNER JOIN dbo.trav_PcProject_view p ON p.Id = tmp.ProjectId
			
		SELECT LEFT(CustId + REPLICATE(' ',10),10) + '/' + ProjectName AS CustProj
			, * 
		FROM #tmpResultsSummary 
		WHERE (CASE @HoursDollars WHEN 0 THEN PercentCompleteHours ELSE PercentCompleteCost END) >= @PercentComplete
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbPcProjectStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbPcProjectStatus_proc';

