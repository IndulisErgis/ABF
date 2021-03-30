
CREATE PROCEDURE dbo.trav_PcProjectDashboard_Profit_proc 
@ProjectId int,
@PhaseId nvarchar(10),
@ProjectDetailId int,
@PhaseYn bit = 0
AS
BEGIN TRY
DECLARE @typeCounter tinyint
SET NOCOUNT ON

CREATE TABLE #tmpProjectDetailType 
(
	[ProjectDetailId] int NOT NULL,
	[Type] tinyint NOT NULL,
	[TrackIncomeYn] bit NOT NULL,
	CONSTRAINT [PK_#tmpProjectDetailType] PRIMARY KEY CLUSTERED ([ProjectDetailId],[Type]) ON [PRIMARY] 
)

SET @typeCounter = 0

WHILE @typeCounter < 4
BEGIN
	IF (@ProjectDetailId IS NOT NULL) --task level
	BEGIN
		INSERT INTO #tmpProjectDetailType([ProjectDetailId], [Type], [TrackIncomeYn])
		SELECT Id, @typeCounter, CASE WHEN Billable = 0 OR FixedFee = 1 THEN 0 ELSE 1 END
		FROM dbo.tblPcProjectDetail
		WHERE Id = @ProjectDetailId
	END
	ELSE IF @PhaseYn = 1 --phase level
	BEGIN
		INSERT INTO #tmpProjectDetailType([ProjectDetailId], [Type], [TrackIncomeYn])
		SELECT Id, @typeCounter, CASE WHEN Billable = 0 OR FixedFee = 1 THEN 0 ELSE 1 END
		FROM dbo.tblPcProjectDetail
		WHERE ProjectId = @ProjectId AND ((@PhaseId IS NULL AND PhaseId IS NULL AND TaskId IS NOT NULL) OR 
			(@PhaseId IS NOT NULL AND PhaseId = @PhaseId))		
	END
	ELSE --project level
	BEGIN
		INSERT INTO #tmpProjectDetailType([ProjectDetailId], [Type], [TrackIncomeYn])
		SELECT Id, @typeCounter, CASE WHEN Billable = 0 OR FixedFee = 1 THEN 0 ELSE 1 END
		FROM dbo.tblPcProjectDetail
		WHERE ProjectId = @ProjectId	
	END
	
	SET @typeCounter = @typeCounter + 1
END

--by estimate type
SELECT t.[Type] AS Category, SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty,0) ELSE 0 END) AS IncomeQty 
	, SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) AS IncomeAmt 
	, SUM(ISNULL(e.Qty,0)) AS CostQty, SUM(ISNULL(e.Qty * e.UnitCost,0)) AS CostAmt 
	, SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) - SUM(ISNULL(e.Qty * e.UnitCost,0)) AS Profit
	, CASE WHEN SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) = 0 THEN 0 ELSE 
		(SUM(ISNULL(e.Qty * e.UnitPrice,0)) - SUM(ISNULL(e.Qty * e.UnitCost,0)))/SUM(ISNULL(e.Qty * e.UnitPrice,0))*100 END AS ProfitPct
FROM #tmpProjectDetailType t 
LEFT JOIN dbo.tblPcEstimate e ON t.ProjectDetailId = e.ProjectDetailId AND t.[type] = e.[type]
GROUP BY t.[Type]

UNION ALL

--estimate total
SELECT 4 AS [Type], NULL AS IncomeQty, SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) AS IncomeAmt
	, NULL AS CostQty, SUM(ISNULL(e.Qty * e.UnitCost,0)) AS CostAmt
	, SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) - SUM(ISNULL(e.Qty * e.UnitCost,0)) AS Profit
	, CASE WHEN SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) = 0 THEN 0 ELSE 
		(SUM(ISNULL(e.Qty * e.UnitPrice,0)) - SUM(ISNULL(e.Qty * e.UnitCost,0)))/SUM(ISNULL(e.Qty * e.UnitPrice,0))*100 END AS ProfitPct
FROM #tmpProjectDetailType t 
LEFT JOIN dbo.tblPcEstimate e ON t.ProjectDetailId = e.ProjectDetailId AND t.[type] = e.[type]

UNION ALL

--by activity type
SELECT t.[Type] + 5, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.Qty,0) ELSE 0 END) AS IncomeQty 
	, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) AS IncomeAmt
	, SUM(ISNULL(a.Qty,0)) AS CostQty, SUM(ISNULL(a.ExtCost,0)) AS CostAmt 
	, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) - SUM(ISNULL(a.ExtCost,0)) AS Profit
	, CASE WHEN SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) = 0 THEN 0 ELSE (SUM(ISNULL(a.ExtIncome,0)) - SUM(ISNULL(a.ExtCost,0)))/SUM(ISNULL(a.ExtIncome,0))*100 END AS ProfitPct
FROM #tmpProjectDetailType t 
LEFT JOIN 
(
	SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost, ExtIncome,[Source] 
	FROM dbo.tblPcActivity WHERE Status < 6 
	UNION ALL 
	SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END, 
		CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtIncome/b.Qty) END ,a.[Source]
	FROM dbo.tblPcActivity a 
	INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	WHERE a.[Source] = 12
) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[type] = a.[type]
GROUP BY t.[Type]

UNION ALL

--activity total
SELECT 9 AS [Type], NULL AS IncomeQty, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) AS IncomeAmt,
	NULL AS CostQty, SUM(ISNULL(a.ExtCost,0)) AS CostAmt, 
	SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) - SUM(ISNULL(a.ExtCost,0)) AS Profit,
	CASE WHEN SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) = 0 THEN 0 ELSE (SUM(ISNULL(a.ExtIncome,0)) - SUM(ISNULL(a.ExtCost,0)))/SUM(ISNULL(a.ExtIncome,0))*100 END AS ProfitPct
FROM #tmpProjectDetailType t 
LEFT JOIN 
(
	SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost, ExtIncome,[Source] 
	FROM dbo.tblPcActivity WHERE Status < 6 
	UNION ALL 
	SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END, 
		CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtIncome/b.Qty) END ,a.[Source]
	FROM dbo.tblPcActivity a 
	INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	WHERE a.[Source] = 12
) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[type] = a.[type]

UNION ALL

SELECT 10 AS [Type], NULL AS IncomeQty, SUM(IncomeAmt) AS IncomeAmt,
	NULL AS CostQty, SUM(CostAmt) AS CostAmt, SUM(Profit) AS Profit, NULL AS ProfitPct
FROM
(
--estimate total
SELECT -SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) AS IncomeAmt, 
	SUM(ISNULL(e.Qty * e.UnitCost,0)) AS CostAmt, 
	-(SUM(CASE t.TrackIncomeYn WHEN 1 THEN ISNULL(e.Qty * e.UnitPrice,0) ELSE 0 END) - SUM(ISNULL(e.Qty * e.UnitCost,0))) AS Profit
FROM #tmpProjectDetailType t 
LEFT JOIN dbo.tblPcEstimate e ON t.ProjectDetailId = e.ProjectDetailId AND t.[type] = e.[type] 

UNION ALL

--activity total
SELECT SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) AS IncomeAmt,	
	-SUM(ISNULL(a.ExtCost,0)) AS CostAmt, 
	SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN ISNULL(a.ExtIncome,0) ELSE 0 END) - SUM(ISNULL(a.ExtCost,0)) AS Profit
FROM #tmpProjectDetailType t 
LEFT JOIN 
(
	SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost, ExtIncome,[Source]  
	FROM dbo.tblPcActivity WHERE Status < 6 
	UNION ALL 
	SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END, 
		CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtIncome/b.Qty) END ,a.[Source] 
	FROM dbo.tblPcActivity a 
	INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	WHERE a.[Source] = 12) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[type] = a.[type] 
) variance

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectDashboard_Profit_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectDashboard_Profit_proc';

