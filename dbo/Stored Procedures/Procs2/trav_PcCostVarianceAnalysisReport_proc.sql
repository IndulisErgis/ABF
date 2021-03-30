
CREATE PROCEDURE dbo.trav_PcCostVarianceAnalysisReport_proc 
@IncludeTask bit = 0,
@Prec tinyint = 2,
@IncludeZeroCost bit = 0, 
@CostVarianceOption tinyint = 2, --0;Positive;1;Negative;2;All;
@FiscalPeriodFrom smallint, 
@FiscalYearFrom smallint, 
@FiscalPeriodThru smallint, 
@FiscalYearThru smallint

AS
BEGIN TRY
DECLARE @typeCounter tinyint
SET NOCOUNT ON

CREATE TABLE #tmpProjectDetailType 
(
	ProjectDetailId int NOT NULL,
	[Type] tinyint NOT NULL,
	[EstimateQty] decimal(28,10) NOT NULL DEFAULT(0),
	[ActualQty] decimal(28,10) NOT NULL DEFAULT(0),
	[EstimateCost] decimal(28,10) NOT NULL DEFAULT(0),
	[ActualCost] decimal(28,10) NOT NULL DEFAULT(0)
	CONSTRAINT [PK_#tmpProjectDetailType] PRIMARY KEY CLUSTERED ([ProjectDetailId],[Type]) ON [PRIMARY] 
)

SET @typeCounter = 0

WHILE @typeCounter < 4
BEGIN
	--Activity type is Time,Material,Expense,Other
	INSERT INTO #tmpProjectDetailType(ProjectDetailId, [Type])
	SELECT d.Id, @typeCounter
	FROM dbo.tblPcProject p INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
	WHERE p.Id IN (SELECT ProjectId FROM #tmpProjectList)
	SET @typeCounter = @typeCounter + 1
END

--Estimate
UPDATE #tmpProjectDetailType SET EstimateCost = e.EstimateCost, EstimateQty = e.Qty
FROM #tmpProjectDetailType INNER JOIN (SELECT d.Id, e.[Type], SUM(ROUND(e.Qty * e.UnitCost,@Prec)) AS EstimateCost, SUM(e.Qty) AS Qty 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId
	GROUP BY d.Id, e.[Type]) e ON #tmpProjectDetailType.ProjectDetailId = e.Id AND #tmpProjectDetailType.[Type] = e.[Type]

--Actual
UPDATE #tmpProjectDetailType SET ActualCost = e.ExtCost, ActualQty = e.Qty 
FROM #tmpProjectDetailType 
	INNER JOIN 
	(
		SELECT d.Id, a.[Type], SUM(a.ExtCost) AS ExtCost, SUM(a.Qty) AS Qty 
		FROM dbo.tblPcProjectDetail d 
			INNER JOIN 
			(
				SELECT ProjectDetailId, [Type], Qty, ExtCost 
				FROM dbo.tblPcActivity 
				WHERE Status < 6 
					AND FiscalYear * 1000 + FiscalPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom 
						AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
				UNION ALL 
				SELECT a.ProjectDetailId, a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END 
				FROM dbo.tblPcActivity a 
					INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
				WHERE a.[Source] = 12
					AND a.FiscalYear * 1000 + a.FiscalPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom 
						AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
			) a ON d.Id = a.ProjectDetailId 
		GROUP BY d.Id, a.[Type]
	) e ON #tmpProjectDetailType.ProjectDetailId = e.Id AND #tmpProjectDetailType.[Type] = e.[Type]

IF @IncludeTask = 1
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, d.PhaseId, d.TaskId, d.[Description], t.[Type], t.ActualQty, t.EstimateQty, 
		t.EstimateQty - t.ActualQty AS VarianceQty, CASE WHEN t.EstimateQty = 0 THEN 0 ELSE (t.EstimateQty - t.ActualQty)/t.EstimateQty END * 100 AS PercentQty,
		t.ActualCost, t.EstimateCost, t.EstimateCost - t.ActualCost AS VarianceCost, CASE WHEN t.EstimateCost = 0 THEN 0 ELSE (t.EstimateCost - t.ActualCost)/t.EstimateCost END * 100 AS PercentCost,
		CASE t.[Type] WHEN 0 THEN t.ActualQty ELSE 0 END TimeActualQty,
		CASE t.[Type] WHEN 0 THEN t.EstimateQty ELSE 0 END TimeEstimateQty,
		CASE t.[Type] WHEN 0 THEN t.ActualCost ELSE 0 END TimeActualCost,
		CASE t.[Type] WHEN 0 THEN t.EstimateCost ELSE 0 END TimeEstimateCost,
		CASE t.[Type] WHEN 1 THEN t.ActualQty ELSE 0 END MaterialActualQty,
		CASE t.[Type] WHEN 1 THEN t.EstimateQty ELSE 0 END MaterialEstimateQty,
		CASE t.[Type] WHEN 1 THEN t.ActualCost ELSE 0 END MaterialActualCost,
		CASE t.[Type] WHEN 1 THEN t.EstimateCost ELSE 0 END MaterialEstimateCost,
		CASE t.[Type] WHEN 2 THEN t.ActualQty ELSE 0 END ExpenseActualQty,
		CASE t.[Type] WHEN 2 THEN t.EstimateQty ELSE 0 END ExpenseEstimateQty,
		CASE t.[Type] WHEN 2 THEN t.ActualCost ELSE 0 END ExpenseActualCost,
		CASE t.[Type] WHEN 2 THEN t.EstimateCost ELSE 0 END ExpenseEstimateCost,
		CASE t.[Type] WHEN 3 THEN t.ActualQty ELSE 0 END OtherActualQty,
		CASE t.[Type] WHEN 3 THEN t.EstimateQty ELSE 0 END OtherEstimateQty,
		CASE t.[Type] WHEN 3 THEN t.ActualCost ELSE 0 END OtherActualCost,
		CASE t.[Type] WHEN 3 THEN t.EstimateCost ELSE 0 END OtherEstimateCost
	FROM #tmpProjectDetailType t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		LEFT JOIN (SELECT ProjectDetailId, [Type] FROM #tmpProjectDetailType GROUP BY ProjectDetailId, [Type]
			HAVING SUM(ActualCost) = 0) l ON t.ProjectDetailId = l.ProjectDetailId AND t.[Type] = l.[Type]
	WHERE (@IncludeZeroCost = 1 OR l.ProjectDetailId IS NULL) AND 
		(@CostVarianceOption = 2 OR (@CostVarianceOption = 0 AND t.EstimateCost > t.ActualCost) 
			OR (@CostVarianceOption = 1 AND t.EstimateCost < t.ActualCost))
END
ELSE
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, NULL AS PhaseId, NULL AS TaskId, p.[Description] AS [Description], t.[Type], 
		SUM(t.ActualQty) AS ActualQty, SUM(t.EstimateQty) AS EstimateQty, SUM(t.ActualCost) AS ActualCost, SUM(t.EstimateCost) AS EstimateCost,
		SUM(t.EstimateQty) - SUM(t.ActualQty) AS VarianceQty, CASE WHEN SUM(t.EstimateQty) = 0 THEN 0 ELSE (SUM(t.EstimateQty) - SUM(t.ActualQty))/SUM(t.EstimateQty) END * 100 AS PercentQty,
		SUM(t.EstimateCost) - SUM(t.ActualCost) AS VarianceCost, CASE WHEN SUM(t.EstimateCost) = 0 THEN 0 ELSE (SUM(t.EstimateCost) - SUM(t.ActualCost))/SUM(t.EstimateCost) END * 100 AS PercentCost,
		CASE t.[Type] WHEN 0 THEN SUM(t.ActualQty) ELSE 0 END TimeActualQty,
		CASE t.[Type] WHEN 0 THEN SUM(t.EstimateQty) ELSE 0 END TimeEstimateQty,
		CASE t.[Type] WHEN 0 THEN SUM(t.ActualCost) ELSE 0 END TimeActualCost,
		CASE t.[Type] WHEN 0 THEN SUM(t.EstimateCost) ELSE 0 END TimeEstimateCost,
		CASE t.[Type] WHEN 1 THEN SUM(t.ActualQty) ELSE 0 END MaterialActualQty,
		CASE t.[Type] WHEN 1 THEN SUM(t.EstimateQty) ELSE 0 END MaterialEstimateQty,
		CASE t.[Type] WHEN 1 THEN SUM(t.ActualCost) ELSE 0 END MaterialActualCost,
		CASE t.[Type] WHEN 1 THEN SUM(t.EstimateCost) ELSE 0 END MaterialEstimateCost,
		CASE t.[Type] WHEN 2 THEN SUM(t.ActualQty) ELSE 0 END ExpenseActualQty,
		CASE t.[Type] WHEN 2 THEN SUM(t.EstimateQty) ELSE 0 END ExpenseEstimateQty,
		CASE t.[Type] WHEN 2 THEN SUM(t.ActualCost) ELSE 0 END ExpenseActualCost,
		CASE t.[Type] WHEN 2 THEN SUM(t.EstimateCost) ELSE 0 END ExpenseEstimateCost,
		CASE t.[Type] WHEN 3 THEN SUM(t.ActualQty) ELSE 0 END OtherActualQty,
		CASE t.[Type] WHEN 3 THEN SUM(t.EstimateQty) ELSE 0 END OtherEstimateQty,
		CASE t.[Type] WHEN 3 THEN SUM(t.ActualCost) ELSE 0 END OtherActualCost,
		CASE t.[Type] WHEN 3 THEN SUM(t.EstimateCost) ELSE 0 END OtherEstimateCost
	FROM #tmpProjectDetailType t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.trav_PcProject_view p ON d.ProjectId = p.Id 
		LEFT JOIN (SELECT ProjectDetailId, [Type] FROM #tmpProjectDetailType GROUP BY ProjectDetailId, [Type]
			HAVING SUM(ActualCost) = 0) l ON t.ProjectDetailId = l.ProjectDetailId AND t.[Type] = l.[Type]
	WHERE (@IncludeZeroCost = 1 OR l.ProjectDetailId IS NULL) AND 
		(@CostVarianceOption = 2 OR (@CostVarianceOption = 0 AND t.EstimateCost > t.ActualCost) 
			OR (@CostVarianceOption = 1 AND t.EstimateCost < t.ActualCost))
	GROUP BY p.CustId, p.ProjectName, t.[Type], p.[Description] 
END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCostVarianceAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCostVarianceAnalysisReport_proc';

