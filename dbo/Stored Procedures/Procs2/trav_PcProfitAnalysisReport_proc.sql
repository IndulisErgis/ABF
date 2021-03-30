
CREATE PROCEDURE dbo.trav_PcProfitAnalysisReport_proc 
@IncludeTask bit = 0, 
@FiscalPeriodFrom smallint, 
@FiscalYearFrom smallint, 
@FiscalPeriodThru smallint, 
@FiscalYearThru smallint

AS
BEGIN TRY
DECLARE @typeCounter tinyint
SET NOCOUNT ON

CREATE TABLE #tmpProjectDetail 
(
	[ProjectDetailId] int NOT NULL,
	[ExtFinalInc] Decimal(28,3) NOT NULL DEFAULT(0),
	[PTDBilled] Decimal(28,3) NOT NULL DEFAULT(0),
	[ExtCost] Decimal(28,3) NOT NULL DEFAULT(0),
	[Profit] Decimal(28,3) NOT NULL DEFAULT(0),
	[Percent] Decimal(28,10) NOT NULL DEFAULT(0)
	CONSTRAINT [PK_#tmpProjectDetail] PRIMARY KEY CLUSTERED ([ProjectDetailId]) ON [PRIMARY] 
)

INSERT INTO #tmpProjectDetail(ProjectDetailId)
SELECT d.Id
FROM dbo.tblPcProject p INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
WHERE d.Billable = 1 --Billable project/task
	AND p.Id IN (SELECT ProjectId FROM #tmpProjectList)

--Income, cost
UPDATE #tmpProjectDetail SET ExtFinalInc = e.ExtIncome, ExtCost = e.ExtCost 
FROM #tmpProjectDetail 
	INNER JOIN 
	(
		SELECT d.ProjectDetailId, SUM(a.ExtIncome) AS ExtIncome, SUM(a.ExtCost) AS ExtCost 
		FROM dbo.#tmpProjectDetail d 
			INNER JOIN 
			(
				SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost, ExtIncome 
				FROM dbo.tblPcActivity 
				WHERE [Type] BETWEEN 0 AND 3 AND [Status] < 6 
					AND FiscalYear * 1000 + FiscalPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom 
						AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
				UNION ALL 
				SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty
					, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END
					, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtIncome/b.Qty) END 
				FROM dbo.tblPcActivity a 
					INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
				WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Source] = 12 
					AND a.FiscalYear * 1000 + a.FiscalPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom 
						AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
			) a ON d.ProjectDetailId = a.ProjectDetailId 
		GROUP BY d.ProjectDetailId
	) e ON #tmpProjectDetail.ProjectDetailId = e.ProjectDetailId

--Project to Date billed
UPDATE #tmpProjectDetail SET PTDBilled = e.BilledAmount 
FROM #tmpProjectDetail 
	INNER JOIN 
	(
		SELECT d.Id, SUM(CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled WHEN a.[Type] = 6 
							THEN a.ExtIncome WHEN a.[Type] = 7 THEN -a.ExtIncome ELSE 0 END) AS BilledAmount 
		FROM dbo.#tmpProjectDetail t 
			INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
		WHERE ((d.FixedFee = 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4) --Non fixed fee billing
					OR (d.FixedFee = 1 AND a.[Type] = 6 AND (a.[Status] = 2 OR a.[Status] = 5)) --Fixed fee billing
					OR (a.[Type] IN (4,5,7) AND a.[Status] = 2)) --Deposit, Deposit applied, Credit memo
			AND a.FiscalYear * 1000 + a.FiscalPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom 
				AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
		GROUP BY d.Id
	) e ON #tmpProjectDetail.ProjectDetailId = e.Id
	
IF @IncludeTask = 1
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, d.PhaseId, d.TaskId, d.[Description], t.ExtFinalInc, t.ExtCost, t.PTDBilled, (t.PTDBilled - t.ExtCost) AS Variance, 
		CASE WHEN t.PTDBilled = 0 THEN 0 ELSE (t.PTDBilled - t.ExtCost)/t.PTDBilled END * 100 AS [Percent]
	FROM #tmpProjectDetail t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
END
ELSE
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, NULL AS PhaseId, NULL AS TaskId, p.[Description], 
		SUM(t.ExtFinalInc) AS ExtFinalInc, SUM(t.ExtCost) AS ExtCost, SUM(t.PTDBilled) AS PTDBilled,
		SUM(t.PTDBilled) - SUM(t.ExtCost) AS Variance, 
		CASE WHEN SUM(t.PTDBilled) = 0 THEN 0 ELSE (SUM(t.PTDBilled) - SUM(t.ExtCost))/SUM(t.PTDBilled) END * 100 AS [Percent]
	FROM #tmpProjectDetail t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.trav_PcProject_view p ON d.ProjectId = p.Id 
	GROUP BY p.CustId, p.ProjectName, p.[Description] 
END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProfitAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProfitAnalysisReport_proc';

