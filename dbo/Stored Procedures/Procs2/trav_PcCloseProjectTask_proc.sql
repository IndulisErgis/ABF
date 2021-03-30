
CREATE PROCEDURE dbo.trav_PcCloseProjectTask_proc 
@CloseDate datetime = null

AS
BEGIN TRY

	--Not able to close a speculative project/task
	CREATE TABLE #tmpInvalidList 
	(
		ProjectDetailId int NOT NULL,
		ProjectId nvarchar(10) NOT NULL,
		CustId nvarchar(10) NULL,
		PhaseId nvarchar(10) NULL,
		TaskId nvarchar(10),
		Error nvarchar(max)
	)
	
	--Project/task is speculative, should not be included in the process
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Project/task is speculative.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.Speculative = 1
	
	--Project/Task is already completed, should not be included in the process
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Project/task is already completed.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.[Status] = 2
	
	--Unposted overhead allocation transactions exist.
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Unposted overhead allocation transactions exist.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.Id IN (SELECT a.ProjectDetailId FROM dbo.tblPcPrepareOverhead o INNER JOIN dbo.tblPcActivity a ON o.ActivityId = a.Id)
	
	--Unposted adjustments exist.
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Unposted adjustments exist.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.Id IN (SELECT ProjectDetailId FROM dbo.tblPcAdjustment)
	
	--Open purchase orders or unposted transactions exist.
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Open purchase orders or unposted transactions exist.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.Id IN (SELECT ProjectDetailId FROM dbo.tblPcActivity WHERE ([Status] = 0 AND Qty <> 0) OR [Status] = 1 )
	
	--Unbilled or work in process activities exist, billable project/task.
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Unbilled or work in process activities exist.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.Billable = 1 AND d.Id IN (SELECT ProjectDetailId FROM dbo.tblPcActivity WHERE [Type] BETWEEN 0 AND 3 AND [Status] IN (2,3) AND [Source] <> 11)--no po receipt
	
	--Incompleted activities exist, job costing project.
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Incompleted activities exist.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE p.[Type] = 1 AND d.Id IN (SELECT ProjectDetailId FROM dbo.tblPcActivity WHERE ([Type] BETWEEN 0 AND 3 AND [Status] = 4) OR --Activity type is Time, Material, Expense, Other; Activity status is billed.
		([Type] = 6 AND [Status] = 2)) --Activity type is Fixed Fee Billing; Activity status is posted.
	
	--Deposit balance exists.
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Deposit balance exists.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.Id IN (SELECT ProjectDetailId FROM dbo.tblPcActivity WHERE [Type] IN (4,5) GROUP BY ProjectDetailId 
		HAVING SUM(CASE [Type] WHEN 4 THEN 1 ELSE -1 END * ExtIncome) <> 0)
	
	--The amount billed for the project does not equal the Fixed Fee Amount.
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'The amount billed for the project does not equal to the Fixed Fee Amount.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		LEFT JOIN (SELECT ProjectDetailId, SUM(ExtIncome) AS FixedFeeAmtBilled FROM dbo.tblPcActivity WHERE [Type] = 6 GROUP BY ProjectDetailId) f 
			ON d.Id = f.ProjectDetailId
	WHERE d.FixedFee = 1 AND d.FixedFeeAmt <> f.FixedFeeAmtBilled
	
   --Open Work order/Service order exists with the ProjectDetailID
   INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
   SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Open work orders exist.'
		  FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
   INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
		  WHERE d.Id IN (SELECT DISTINCT(w.ProjectDetailID) FROM dbo.tblSvWorkOrder w WHERE  w.ProjectDetailID IS NOT NULL)
	
	--Close tasks
	UPDATE dbo.tblPcProjectDetail SET [Status] = 2, ActEndDate = @CloseDate
	WHERE Id IN (SELECT Id FROM #tmpProjectDetailList)  AND
		Id NOT IN (SELECT ProjectDetailId FROM #tmpInvalidList) AND TaskId IS NOT NULL
	
	--Project with incomplete tasks
	INSERT INTO #tmpInvalidList(ProjectDetailId, ProjectId, CustId, PhaseId, TaskId, Error)
	SELECT d.Id, p.ProjectName, p.CustId, d.PhaseId, d.TaskId, 'Incompelete tasks exist.'
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.TaskId IS NULL AND d.PhaseId IS NULL AND d.ProjectId IN (SELECT ProjectId FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id 
		AND d.TaskId IS NOT NULL AND d.[Status] <> 2)
	
	--Close projects
	UPDATE dbo.tblPcProjectDetail SET [Status] = 2, ActEndDate = @CloseDate
	WHERE Id IN (SELECT Id FROM #tmpProjectDetailList)  AND
		Id NOT IN (SELECT ProjectDetailId FROM #tmpInvalidList) AND TaskId IS NULL AND PhaseId IS NULL
		
	SELECT p.CustId, p.ProjectName AS ProjId, d.PhaseId, d.TaskId
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	WHERE d.[Status] = 2 AND d.Id NOT IN (SELECT ProjectDetailId FROM #tmpInvalidList)
	
	SELECT CustId,ProjectId,PhaseId,TaskId,Error
	FROM #tmpInvalidList
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCloseProjectTask_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCloseProjectTask_proc';

