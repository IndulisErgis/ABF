
CREATE PROCEDURE dbo.trav_PcIncomeAnalysisReport_proc 
@IncludeTask bit,
@FiscalYear smallint,
@FiscalPeriod smallint,
@Prec tinyint,
@IncludeZeroIncome bit
AS
BEGIN TRY
DECLARE @typeCounter tinyint
SET NOCOUNT ON

CREATE TABLE #tmpProjectDetailType 
(
	ProjectDetailId int NOT NULL,
	[Type] tinyint NOT NULL,
	[Estimate] Decimal(28,3) NOT NULL DEFAULT(0),
	[PTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[YTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[PRTD] Decimal(28,3) NOT NULL DEFAULT(0)
	CONSTRAINT [PK_#tmpProjectDetailType] PRIMARY KEY CLUSTERED ([ProjectDetailId],[Type]) ON [PRIMARY] 
)

SET @typeCounter = 0

WHILE @typeCounter < 4
BEGIN
	--Activity type is Time,Material,Expense,Other
	INSERT INTO #tmpProjectDetailType(ProjectDetailId, [Type])
	SELECT d.Id, @typeCounter
	FROM dbo.tblPcProject p INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
	WHERE p.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0--General, billable non-fixed fee project/task
		AND p.Id IN (SELECT ProjectId FROM #tmpProjectList)
	SET @typeCounter = @typeCounter + 1
END

--Estimate
UPDATE #tmpProjectDetailType SET Estimate = e.Estimate
FROM #tmpProjectDetailType INNER JOIN (SELECT d.Id, e.[Type], SUM(ROUND(e.Qty * e.UnitPrice,@Prec)) AS Estimate 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId
	GROUP BY d.Id, e.[Type]) e ON #tmpProjectDetailType.ProjectDetailId = e.Id AND #tmpProjectDetailType.[Type] = e.[Type]

--Project to Date income
UPDATE #tmpProjectDetailType SET PRTD = e.ExtIncome
FROM #tmpProjectDetailType INNER JOIN (SELECT d.Id, a.[Type], SUM(CASE a.Status WHEN 4 THEN a.ExtIncomeBilled ELSE a.ExtIncome END) AS ExtIncome 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
	WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Status] BETWEEN 2 AND 4 AND [Source] <> 11 --Activity type is Time,Material,Expense,Other, activity status is Posted,WIP,Billed, no po receipt
		AND ((a.FiscalYear < @FiscalYear) OR (a.FiscalYear = @FiscalYear AND a.FiscalPeriod <= @FiscalPeriod)) 		
		GROUP BY d.Id, a.[Type]) e ON #tmpProjectDetailType.ProjectDetailId = e.Id AND #tmpProjectDetailType.[Type] = e.[Type]
	
--Year to Date income
UPDATE #tmpProjectDetailType SET YTD = e.ExtIncome
FROM #tmpProjectDetailType INNER JOIN (SELECT d.Id, a.[Type], SUM(CASE a.Status WHEN 4 THEN a.ExtIncomeBilled ELSE a.ExtIncome END) AS ExtIncome 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
	WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Status] BETWEEN 2 AND 4  AND [Source] <> 11--Activity type is Time,Material,Expense,Other, activity status is Posted,WIP,Billed, no po receipt
		AND a.FiscalYear = @FiscalYear AND a.FiscalPeriod <= @FiscalPeriod GROUP BY d.Id, a.[Type]) e ON #tmpProjectDetailType.ProjectDetailId = e.Id AND #tmpProjectDetailType.[Type] = e.[Type]
	
--Period to Date income
UPDATE #tmpProjectDetailType SET PTD = e.ExtIncome
FROM #tmpProjectDetailType INNER JOIN (SELECT d.Id, a.[Type], SUM(CASE a.Status WHEN 4 THEN a.ExtIncomeBilled ELSE a.ExtIncome END) AS ExtIncome 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
	WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Status] BETWEEN 2 AND 4  AND [Source] <> 11--Activity type is Time,Material,Expense,Other, activity status is Posted,WIP,Billed, no po receipt
	AND a.FiscalYear = @FiscalYear AND a.FiscalPeriod = @FiscalPeriod GROUP BY d.Id, a.[Type]) e ON #tmpProjectDetailType.ProjectDetailId = e.Id AND #tmpProjectDetailType.[Type] = e.[Type]

IF @IncludeTask = 1
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, d.PhaseId, d.TaskId, d.[Description], t.[Type], t.Estimate, t.PTD, t.YTD, t.PRTD, (t.PRTD - t.Estimate) AS Variance, 
		CASE WHEN t.Estimate = 0 THEN 0 ELSE (t.PRTD - t.Estimate)/t.Estimate END * 100 AS [Percent],
		CASE t.[Type] WHEN 0 THEN t.Estimate ELSE 0 END TimeEstimate,
		CASE t.[Type] WHEN 0 THEN t.PTD ELSE 0 END TimePTD,
		CASE t.[Type] WHEN 0 THEN t.YTD ELSE 0 END TimeYTD,
		CASE t.[Type] WHEN 0 THEN t.PRTD ELSE 0 END TimePRTD,
		CASE t.[Type] WHEN 1 THEN t.Estimate ELSE 0 END MaterialEstimate,
		CASE t.[Type] WHEN 1 THEN t.PTD ELSE 0 END MaterialPTD,
		CASE t.[Type] WHEN 1 THEN t.YTD ELSE 0 END MaterialYTD,
		CASE t.[Type] WHEN 1 THEN t.PRTD ELSE 0 END MaterialPRTD,
		CASE t.[Type] WHEN 2 THEN t.Estimate ELSE 0 END ExpenseEstimate,
		CASE t.[Type] WHEN 2 THEN t.PTD ELSE 0 END ExpensePTD,
		CASE t.[Type] WHEN 2 THEN t.YTD ELSE 0 END ExpenseYTD,
		CASE t.[Type] WHEN 2 THEN t.PRTD ELSE 0 END ExpensePRTD,
		CASE t.[Type] WHEN 3 THEN t.Estimate ELSE 0 END OtherEstimate,
		CASE t.[Type] WHEN 3 THEN t.PTD ELSE 0 END OtherPTD,
		CASE t.[Type] WHEN 3 THEN t.YTD ELSE 0 END OtherYTD,
		CASE t.[Type] WHEN 3 THEN t.PRTD ELSE 0 END OtherPRTD
	FROM #tmpProjectDetailType t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		LEFT JOIN (SELECT ProjectDetailId, [Type] FROM #tmpProjectDetailType GROUP BY ProjectDetailId, [Type]
			HAVING SUM(PTD + YTD + PRTD) = 0) l ON t.ProjectDetailId = l.ProjectDetailId AND t.[Type] = l.[Type]
	WHERE @IncludeZeroIncome = 1 OR l.ProjectDetailId IS NULL
END
ELSE
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, NULL AS PhaseId, NULL AS TaskId,p.[Description] AS [Description], t.[Type], SUM(t.Estimate) AS Estimate, 
		SUM(t.PTD) AS PTD, SUM(t.YTD) AS YTD, SUM(t.PRTD) AS PRTD, (SUM(t.PRTD) - SUM(t.Estimate)) AS Variance, 
		CASE WHEN SUM(t.Estimate) = 0 THEN 0 ELSE (SUM(t.PRTD) - SUM(t.Estimate))/SUM(t.Estimate) END * 100 AS [Percent],
		CASE t.[Type] WHEN 0 THEN SUM(t.Estimate) ELSE 0 END TimeEstimate,
		CASE t.[Type] WHEN 0 THEN SUM(t.PTD) ELSE 0 END TimePTD,
		CASE t.[Type] WHEN 0 THEN SUM(t.YTD) ELSE 0 END TimeYTD,
		CASE t.[Type] WHEN 0 THEN SUM(t.PRTD) ELSE 0 END TimePRTD,
		CASE t.[Type] WHEN 1 THEN SUM(t.Estimate) ELSE 0 END MaterialEstimate,
		CASE t.[Type] WHEN 1 THEN SUM(t.PTD) ELSE 0 END MaterialPTD,
		CASE t.[Type] WHEN 1 THEN SUM(t.YTD) ELSE 0 END MaterialYTD,
		CASE t.[Type] WHEN 1 THEN SUM(t.PRTD) ELSE 0 END MaterialPRTD,
		CASE t.[Type] WHEN 2 THEN SUM(t.Estimate) ELSE 0 END ExpenseEstimate,
		CASE t.[Type] WHEN 2 THEN SUM(t.PTD) ELSE 0 END ExpensePTD,
		CASE t.[Type] WHEN 2 THEN SUM(t.YTD) ELSE 0 END ExpenseYTD,
		CASE t.[Type] WHEN 2 THEN SUM(t.PRTD) ELSE 0 END ExpensePRTD,
		CASE t.[Type] WHEN 3 THEN SUM(t.Estimate) ELSE 0 END OtherEstimate,
		CASE t.[Type] WHEN 3 THEN SUM(t.PTD) ELSE 0 END OtherPTD,
		CASE t.[Type] WHEN 3 THEN SUM(t.YTD) ELSE 0 END OtherYTD,
		CASE t.[Type] WHEN 3 THEN SUM(t.PRTD) ELSE 0 END OtherPRTD
	FROM #tmpProjectDetailType t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.trav_PcProject_view p ON d.ProjectId = p.Id 
		LEFT JOIN (SELECT ProjectDetailId, [Type] FROM #tmpProjectDetailType GROUP BY ProjectDetailId, [Type]
			HAVING SUM(PTD + YTD + PRTD) = 0) l ON t.ProjectDetailId = l.ProjectDetailId AND t.[Type] = l.[Type]
	WHERE @IncludeZeroIncome = 1 OR l.ProjectDetailId IS NULL
	GROUP BY p.CustId, p.ProjectName, t.[Type], p.[Description] 
END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcIncomeAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcIncomeAnalysisReport_proc';

