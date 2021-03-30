
CREATE PROCEDURE dbo.trav_PcProjectDashboard_Cost_proc 
@ProjectId int,
@PhaseId nvarchar(10),
@ProjectDetailId int,
@PhaseYn bit = 1,
@PrecCurr tinyint = 2
AS
BEGIN TRY
DECLARE @statusCounter tinyint
SET NOCOUNT ON

CREATE TABLE #tmpProjectDetailStatus 
(
	[ProjectDetailId] int NOT NULL,
	[Status] tinyint NOT NULL,
	CONSTRAINT [PK_#tmpProjectDetailStatus] PRIMARY KEY CLUSTERED ([ProjectDetailId],[Status]) ON [PRIMARY] 
)

SET @statusCounter = 0

WHILE @statusCounter < 6
BEGIN
	IF (@ProjectDetailId IS NOT NULL) --task level
	BEGIN
		INSERT INTO #tmpProjectDetailStatus([ProjectDetailId], [Status])
		SELECT Id, @statusCounter
		FROM dbo.tblPcProjectDetail
		WHERE Id = @ProjectDetailId
	END
	ELSE IF @PhaseYn = 1 --phase level
	BEGIN
		INSERT INTO #tmpProjectDetailStatus([ProjectDetailId], [Status])
		SELECT Id, @statusCounter
		FROM dbo.tblPcProjectDetail
		WHERE ProjectId = @ProjectId AND ((@PhaseId IS NULL AND PhaseId IS NULL AND TaskId IS NOT NULL) OR 
			(@PhaseId IS NOT NULL AND PhaseId = @PhaseId))		
	END
	ELSE --project level
	BEGIN
		INSERT INTO #tmpProjectDetailStatus([ProjectDetailId], [Status])
		SELECT Id, @statusCounter
		FROM dbo.tblPcProjectDetail
		WHERE ProjectId = @ProjectId	
	END
	
	SET @statusCounter = @statusCounter + 1
END

--by activity status
SELECT t.[Status] AS Category, SUM(CASE a.[type] WHEN 0 THEN a.Qty ELSE 0 END) AS TimeQty, 
	SUM(CASE a.[type] WHEN 0 THEN a.ExtCost ELSE 0 END) TimeCost,
	SUM(CASE a.[type] WHEN 1 THEN a.Qty ELSE 0 END) AS MaterialQty, 
	SUM(CASE a.[type] WHEN 1 THEN a.ExtCost ELSE 0 END) MaterialCost,
	SUM(CASE a.[type] WHEN 2 THEN a.Qty ELSE 0 END) AS ExpenseQty, 
	SUM(CASE a.[type] WHEN 2 THEN a.ExtCost ELSE 0 END) ExpenseCost,
	SUM(CASE a.[type] WHEN 3 THEN a.Qty ELSE 0 END) AS OtherQty, 
	SUM(CASE a.[type] WHEN 3 THEN a.ExtCost ELSE 0 END) OtherCost,
	SUM(CASE WHEN a.[type] BETWEEN 0 AND 3 THEN a.ExtCost ELSE 0 END) TotalCost
FROM #tmpProjectDetailStatus t LEFT JOIN 
	(SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost FROM dbo.tblPcActivity WHERE Status < 6 UNION ALL 
	 SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	 WHERE a.[Source] = 12) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[Status] = a.[Status]
GROUP BY t.[Status]
UNION ALL
--actual total
SELECT 6 AS [Status], SUM(CASE a.[type] WHEN 0 THEN a.Qty ELSE 0 END) AS TimeQty, 
	SUM(CASE a.[type] WHEN 0 THEN a.ExtCost ELSE 0 END) TimeCost,
	SUM(CASE a.[type] WHEN 1 THEN a.Qty ELSE 0 END) AS MaterialQty, 
	SUM(CASE a.[type] WHEN 1 THEN a.ExtCost ELSE 0 END) MaterialCost,
	SUM(CASE a.[type] WHEN 2 THEN a.Qty ELSE 0 END) AS ExpenseQty, 
	SUM(CASE a.[type] WHEN 2 THEN a.ExtCost ELSE 0 END) ExpenseCost,
	SUM(CASE a.[type] WHEN 3 THEN a.Qty ELSE 0 END) AS OtherQty, 
	SUM(CASE a.[type] WHEN 3 THEN a.ExtCost ELSE 0 END) OtherCost,
	SUM(CASE WHEN a.[type] BETWEEN 0 AND 3 THEN a.ExtCost ELSE 0 END) TotalCost
FROM #tmpProjectDetailStatus t LEFT JOIN 
	(SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost FROM dbo.tblPcActivity WHERE Status < 6 UNION ALL 
	 SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	 WHERE a.[Source] = 12) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[Status] = a.[Status]
UNION ALL
--estimate total
SELECT 7 AS [Status], SUM(CASE e.[type] WHEN 0 THEN e.Qty ELSE 0 END) AS TimeQty, 
	SUM(CASE e.[type] WHEN 0 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) TimeCost,
	SUM(CASE e.[type] WHEN 1 THEN e.Qty ELSE 0 END) AS MaterialQty, 
	SUM(CASE e.[type] WHEN 1 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) MaterialCost,
	SUM(CASE e.[type] WHEN 2 THEN e.Qty ELSE 0 END) AS ExpenseQty, 
	SUM(CASE e.[type] WHEN 2 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) ExpenseCost,
	SUM(CASE e.[type] WHEN 3 THEN e.Qty ELSE 0 END) AS OtherQty, 
	SUM(CASE e.[type] WHEN 3 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) OtherCost,
	ISNULL(SUM(ROUND(e.Qty * e.UnitCost,@PrecCurr)),0) TotalCost
FROM (SELECT ProjectDetailId FROM #tmpProjectDetailStatus GROUP BY ProjectDetailId) t 
	LEFT JOIN dbo.tblPcEstimate e ON t.ProjectDetailId = e.ProjectDetailId
UNION ALL
--variance
SELECT 8 AS [Status], SUM(TimeQty) AS TimeQty, SUM(TimeCost) AS TimeCost, SUM(MaterialQty) AS MaterialQty,
	SUM(MaterialCost) AS MaterialCost, SUM(ExpenseQty) AS ExpenseQty, SUM(ExpenseCost) AS ExpenseCost,
	SUM(OtherQty) AS OtherQty, SUM(OtherCost) AS OtherCost, SUM(TotalCost) AS TotalCost
FROM 
(
--actual total
SELECT -SUM(CASE a.[type] WHEN 0 THEN a.Qty ELSE 0 END) AS TimeQty, 
	-SUM(CASE a.[type] WHEN 0 THEN a.ExtCost ELSE 0 END) TimeCost,
	-SUM(CASE a.[type] WHEN 1 THEN a.Qty ELSE 0 END) AS MaterialQty, 
	-SUM(CASE a.[type] WHEN 1 THEN a.ExtCost ELSE 0 END) MaterialCost,
	-SUM(CASE a.[type] WHEN 2 THEN a.Qty ELSE 0 END) AS ExpenseQty, 
	-SUM(CASE a.[type] WHEN 2 THEN a.ExtCost ELSE 0 END) ExpenseCost,
	-SUM(CASE a.[type] WHEN 3 THEN a.Qty ELSE 0 END) AS OtherQty, 
	-SUM(CASE a.[type] WHEN 3 THEN a.ExtCost ELSE 0 END) OtherCost,
	-SUM(CASE WHEN a.[type] BETWEEN 0 AND 3 THEN a.ExtCost ELSE 0 END) TotalCost
FROM #tmpProjectDetailStatus t LEFT JOIN 
	(SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost FROM dbo.tblPcActivity WHERE Status < 6 UNION ALL 
	 SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	 WHERE a.[Source] = 12) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[Status] = a.[Status]
UNION ALL
--estimate total
SELECT SUM(CASE e.[type] WHEN 0 THEN e.Qty ELSE 0 END) AS TimeQty, 
	SUM(CASE e.[type] WHEN 0 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) TimeCost,
	SUM(CASE e.[type] WHEN 1 THEN e.Qty ELSE 0 END) AS MaterialQty, 
	SUM(CASE e.[type] WHEN 1 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) MaterialCost,
	SUM(CASE e.[type] WHEN 2 THEN e.Qty ELSE 0 END) AS ExpenseQty, 
	SUM(CASE e.[type] WHEN 2 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) ExpenseCost,
	SUM(CASE e.[type] WHEN 3 THEN e.Qty ELSE 0 END) AS OtherQty, 
	SUM(CASE e.[type] WHEN 3 THEN ROUND(e.Qty * e.UnitCost,@PrecCurr) ELSE 0 END) OtherCost,
	ISNULL(SUM(ROUND(e.Qty * e.UnitCost,@PrecCurr)),0) TotalCost
FROM (SELECT ProjectDetailId FROM #tmpProjectDetailStatus GROUP BY ProjectDetailId) t 
	LEFT JOIN dbo.tblPcEstimate e ON t.ProjectDetailId = e.ProjectDetailId
) Variance


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectDashboard_Cost_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectDashboard_Cost_proc';

