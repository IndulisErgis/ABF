
CREATE PROCEDURE dbo.trav_PcBudgetAnalysisView_proc

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmpProjectDetailStatus
	(
		[ProjectDetailId] int NOT NULL, 
		[Status] tinyint NOT NULL, 
		CONSTRAINT [PK_#tmpProjectDetailStatus] PRIMARY KEY CLUSTERED ([ProjectDetailId], [Status]) ON [PRIMARY]
	)

	CREATE TABLE #tmpDashboard
	(
		Category int NOT NULL, 
		TimeQty [pDecimal], 
		TimeCost [pDecimal], 
		MaterialQty [pDecimal], 
		MaterialCost [pDecimal], 
		ExpenseQty [pDecimal], 
		ExpenseCost [pDecimal], 
		OtherQty [pDecimal], 
		OtherCost [pDecimal], 
		TotalCost [pDecimal], 
		ProjectDetailID int
	)

	DECLARE @StatusCounter tinyint
	SET @StatusCounter = 0

	WHILE @StatusCounter < 6
	BEGIN
		INSERT INTO #tmpProjectDetailStatus([ProjectDetailId], [Status]) 
		SELECT Id, @StatusCounter 
		FROM dbo.tblPcProjectDetail

		SET @StatusCounter = @StatusCounter + 1
	END

	-- by activity status
	INSERT INTO #tmpDashboard([Category], [TimeQty], [TimeCost], [MaterialQty], [MaterialCost]
		, [ExpenseQty], [ExpenseCost], [OtherQty], [OtherCost], [TotalCost], [ProjectDetailID]) 
	SELECT t.[Status] AS Category
		, SUM(CASE a.[type] WHEN 0 THEN a.Qty ELSE 0 END) AS TimeQty
		, SUM(CASE a.[type] WHEN 0 THEN a.ExtCost ELSE 0 END) TimeCost
		, SUM(CASE a.[type] WHEN 1 THEN a.Qty ELSE 0 END) AS MaterialQty
		, SUM(CASE a.[type] WHEN 1 THEN a.ExtCost ELSE 0 END) MaterialCost
		, SUM(CASE a.[type] WHEN 2 THEN a.Qty ELSE 0 END) AS ExpenseQty
		, SUM(CASE a.[type] WHEN 2 THEN a.ExtCost ELSE 0 END) ExpenseCost
		, SUM(CASE a.[type] WHEN 3 THEN a.Qty ELSE 0 END) AS OtherQty
		, SUM(CASE a.[type] WHEN 3 THEN a.ExtCost ELSE 0 END) OtherCost
		, SUM(CASE WHEN a.[type] BETWEEN 0 AND 3 THEN a.ExtCost ELSE 0 END) TotalCost
		, t.[ProjectDetailID] 
	FROM #tmpProjectDetailStatus t 
		LEFT JOIN 
		(
			SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost 
			FROM dbo.tblPcActivity 
			WHERE [Status] < 6 
			UNION ALL 
			SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END 
			FROM dbo.tblPcActivity a 
				INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
			WHERE a.[Source] = 12
		) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[Status] = a.[Status] 
	GROUP BY t.[Status],t.[ProjectDetailID] 

	-- actual total
	INSERT INTO #tmpDashboard([Category], [TimeQty], [TimeCost], [MaterialQty], [MaterialCost]
		, [ExpenseQty], [ExpenseCost], [OtherQty], [OtherCost], [TotalCost], [ProjectDetailID]) 
	SELECT 6 AS [Status]
		, SUM(CASE a.[type] WHEN 0 THEN a.Qty ELSE 0 END) AS TimeQty
		, SUM(CASE a.[type] WHEN 0 THEN a.ExtCost ELSE 0 END) AS TimeCost
		, SUM(CASE a.[type] WHEN 1 THEN a.Qty ELSE 0 END) AS MaterialQty
		, SUM(CASE a.[type] WHEN 1 THEN a.ExtCost ELSE 0 END) AS MaterialCost
		, SUM(CASE a.[type] WHEN 2 THEN a.Qty ELSE 0 END) AS ExpenseQty
		, SUM(CASE a.[type] WHEN 2 THEN a.ExtCost ELSE 0 END) AS ExpenseCost
		, SUM(CASE a.[type] WHEN 3 THEN a.Qty ELSE 0 END) AS OtherQty
		, SUM(CASE a.[type] WHEN 3 THEN a.ExtCost ELSE 0 END) AS OtherCost
		, SUM(CASE WHEN a.[type] BETWEEN 0 AND 3 THEN a.ExtCost ELSE 0 END) AS TotalCost
		, t.[ProjectDetailID] 
	FROM #tmpProjectDetailStatus t 
		LEFT JOIN 
		(
			SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost 
			FROM dbo.tblPcActivity 
			WHERE Status < 6 
			UNION ALL 
			SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END 
			FROM dbo.tblPcActivity a 
				INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
			WHERE a.[Source] = 12
		) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[Status] = a.[Status] 
		GROUP BY t.[ProjectDetailID] 

--	-- estimate total
	INSERT INTO #tmpDashboard([Category], [TimeQty], [TimeCost], [MaterialQty], [MaterialCost]
		, [ExpenseQty], [ExpenseCost], [OtherQty], [OtherCost], [TotalCost], [ProjectDetailID]) 
	SELECT 7 AS [Status]
		, SUM(CASE e.[type] WHEN 0 THEN e.Qty ELSE 0 END) AS TimeQty
		, SUM(CASE e.[type] WHEN 0 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END) AS TimeCost
		, SUM(CASE e.[type] WHEN 1 THEN e.Qty ELSE 0 END) AS MaterialQty
		, SUM(CASE e.[type] WHEN 1 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END) AS MaterialCost
		, SUM(CASE e.[type] WHEN 2 THEN e.Qty ELSE 0 END) AS ExpenseQty
		, SUM(CASE e.[type] WHEN 2 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END) AS ExpenseCost
		, SUM(CASE e.[type] WHEN 3 THEN e.Qty ELSE 0 END) AS OtherQty
		, SUM(CASE e.[type] WHEN 3 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END)AS  OtherCost
		, SUM(ROUND(ISNULL(e.Qty, 0) * ISNULL(e.UnitCost, 0), 2)) AS TotalCost
		, t.[ProjectDetailID] 
	FROM (SELECT ProjectDetailId FROM #tmpProjectDetailStatus GROUP BY ProjectDetailId) t 
		LEFT JOIN dbo.tblPcEstimate e ON t.ProjectDetailId = e.ProjectDetailId 
	GROUP BY t.[ProjectDetailID]

	SELECT d.Id, p.CustId, c.CustName, d.CustPoNum, p.ProjectName, d.ProjectManager, d.PhaseId, ph.[Description] AS PhaseDescription
		, d.TaskId, ta.[Description] AS TaskDescription, d.[Description] AS ProjectDescription, p.[Type], d.[Status]
		, d.Billable, d.Speculative, d.FixedFee, d.FixedFeeAmt, d.EstStartDate, d.EstEndDate, d.ActStartDate, d.ActEndDate
		, d.AddnlDesc, d.LastDateBilled, d.Rep2Id, d.Rep1Id, ISNULL(f.AmountBilled, 0) AS FixedFeeAmtBilled, d.BillOnHold
		, ISNULL(ac.DepositAmount, 0) AS DepositAmount, ISNULL(ac.DepositApplied, 0) AS DepositApplied, est.TimeQty AS EstHours, act.TimeQty AS ActHours
		, (est.TimeQty - act.TimeQty) AS HoursVariance, est.TimeCost AS EstLaborCost, act.TimeCost AS ActLaborCost
		, (est.TimeCost - act.TimeCost) AS LaborCostVariance
		, (est.MaterialCost + est.ExpenseCost + est.OtherCost) AS EstMaterialCost
		, ((act.MaterialCost - ord.MaterialCost) + (act.ExpenseCost - ord.ExpenseCost) 
			+ (act.OtherCost - ord.OtherCost)) AS ActMaterialCostEX
		, ((est.MaterialCost + est.ExpenseCost + est.OtherCost) - ((act.MaterialCost - ord.MaterialCost) 
			+ (act.ExpenseCost - ord.ExpenseCost) + (act.OtherCost - ord.OtherCost))) AS MaterialCostVarianceEX
		, (est.TimeCost + (est.MaterialCost + est.ExpenseCost + est.OtherCost)) AS TotalEstCost
		, (act.TimeCost + ((act.MaterialCost - ord.MaterialCost) + (act.ExpenseCost - ord.ExpenseCost) 
			+ (act.OtherCost - ord.OtherCost))) AS TotalActCostEX
		, ((est.TimeCost + (est.MaterialCost + est.ExpenseCost + est.OtherCost)) 
			- (act.TimeCost + ((act.MaterialCost - ord.MaterialCost) + (act.ExpenseCost - ord.ExpenseCost) 
			+ (act.OtherCost - ord.OtherCost)))) AS TotalVarianceEX
		, (d.FixedFeeAmt - (est.TimeCost + (est.MaterialCost + est.ExpenseCost + est.OtherCost))) AS BudgetedGrossProfit
		, (ISNULL(ac.DepositAmount, 0) - (act.TimeCost + ((act.MaterialCost - ord.MaterialCost) 
			+ (act.ExpenseCost - ord.ExpenseCost) + (act.OtherCost - ord.OtherCost)))) AS CashPosition
		, ord.TotalCost AS OnOrderCost
		, (act.MaterialCost + act.ExpenseCost + act.OtherCost) AS ActMaterialCostIN
		, ((est.MaterialCost + est.ExpenseCost + est.OtherCost) 
			- (act.MaterialCost + act.ExpenseCost + act.OtherCost)) AS MaterialCostVarianceIN
		, (act.TimeCost + (act.MaterialCost + act.ExpenseCost + act.OtherCost)) AS TotalActCostIN
		, ((est.TimeCost + (est.MaterialCost + est.ExpenseCost + est.OtherCost)) 
			- (act.TimeCost + (act.MaterialCost + act.ExpenseCost + act.OtherCost))) AS TotalVarianceIN
		, (ISNULL((act.TimeCost + (act.MaterialCost + act.ExpenseCost + act.OtherCost)) 
			/ (NULLIF((est.TimeCost + (est.MaterialCost + est.ExpenseCost + est.OtherCost)), 0)), 0) * 100) AS [SpentPercentVariance]
		, (ISNULL(((est.TimeCost + (est.MaterialCost + est.ExpenseCost + est.OtherCost)) 
			- (act.TimeCost + (act.MaterialCost + act.ExpenseCost + act.OtherCost))) 
			/ (NULLIF((est.TimeCost + (est.MaterialCost + est.ExpenseCost + est.OtherCost)), 0)), 0) * 100) AS [RemainingPercentVariance] 
	FROM dbo.trav_PcProjectTask_view d 
		LEFT JOIN dbo.tblPcProject p ON p.Id = d.ProjectId 
		LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId 
		LEFT JOIN 
		(
			SELECT ProjectDetailId
				, (SELECT SUM(ExtIncome) FROM tblPcActivity WHERE ([Type] = 6 AND [Status] IN (2, 5))) AmountBilled 
			FROM dbo.tblPcActivity 
			GROUP BY ProjectDetailId
		) f ON d.Id = f.ProjectDetailId 
		LEFT JOIN (SELECT * FROM #tmpDashboard db WHERE db.Category = 0) ord ON ord.ProjectDetailId = d.Id 
		LEFT JOIN (SELECT * FROM #tmpDashboard db WHERE db.Category = 6) act ON act.ProjectDetailId = d.Id 
		LEFT JOIN (SELECT * FROM #tmpDashboard db WHERE db.Category = 7) est ON est.ProjectDetailId = d.Id 
		LEFT JOIN
		(
			SELECT ProjectDetailId
				, SUM(DepositAmount) AS DepositAmount, SUM(DepositApplied) AS DepositApplied 
			FROM
			(
				SELECT a.ProjectDetailId
					, CASE WHEN a.[Type] = 4 THEN a.ExtIncome ELSE 0 END DepositAmount
					, CASE WHEN a.[Type] = 5 THEN a.ExtIncome ELSE 0 END DepositApplied 
					 FROM #tmpProjectDetailStatus t 
					INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id 
					INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId AND t.[Status]=a.[Status]
					WHERE( a.[Type] IN (4, 5))
			) BillingDetail 
			GROUP BY ProjectDetailId
		) ac ON d.Id = ac.ProjectDetailId 
		LEFT JOIN tblPcPhase ph ON ph.PhaseId = d.PhaseId 
		LEFT JOIN tblPcTask ta ON ta.TaskId = d.TaskId 
		INNER JOIN #tmpBudgetDetailList AS de ON de.ProjectDetailId = d.Id 
	ORDER BY p.ProjectName
 
 END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBudgetAnalysisView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBudgetAnalysisView_proc';

