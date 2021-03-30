
CREATE PROCEDURE dbo.trav_PcProjectPercentCompleteView_proc

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
	
	INSERT INTO #tmpDashboard([Category], [TimeQty], [TimeCost], [MaterialQty], [MaterialCost]
		, [ExpenseQty], [ExpenseCost], [OtherQty], [OtherCost], [TotalCost], [ProjectDetailID]) 
	-- by activity status
	SELECT t.[Status] AS Category
		, SUM(CASE a.[Type] WHEN 0 THEN a.Qty ELSE 0 END) AS TimeQty
		, SUM(CASE a.[Type] WHEN 0 THEN a.ExtCost ELSE 0 END) AS TimeCost
		, SUM(CASE a.[Type] WHEN 1 THEN a.Qty ELSE 0 END) AS MaterialQty
		, SUM(CASE a.[Type] WHEN 1 THEN a.ExtCost ELSE 0 END) AS MaterialCost
		, SUM(CASE a.[Type] WHEN 2 THEN a.Qty ELSE 0 END) AS ExpenseQty
		, SUM(CASE a.[Type] WHEN 2 THEN a.ExtCost ELSE 0 END) AS ExpenseCost
		, SUM(CASE a.[Type] WHEN 3 THEN a.Qty ELSE 0 END) AS OtherQty
		, SUM(CASE a.[Type] WHEN 3 THEN a.ExtCost ELSE 0 END) AS OtherCost
		, SUM(CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtCost ELSE 0 END) AS TotalCost
		, t.[ProjectDetailId] 
	FROM #tmpProjectDetailStatus t 
		LEFT JOIN 
		(
			SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost 
			FROM dbo.tblPcActivity 
			WHERE [Status] < 6 
			UNION ALL 
			SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost / b.Qty) END 
			FROM dbo.tblPcActivity a 
				INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
			WHERE a.[Source] = 12
		) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[Status] = a.[Status] 
	GROUP BY t.[Status], t.[ProjectDetailId] 
	UNION ALL 
	-- actual total
	SELECT 6 AS [Status]
		, SUM(CASE a.[Type] WHEN 0 THEN a.Qty ELSE 0 END) AS TimeQty
		, SUM(CASE a.[Type] WHEN 0 THEN a.ExtCost ELSE 0 END) TimeCost
		, SUM(CASE a.[Type] WHEN 1 THEN a.Qty ELSE 0 END) AS MaterialQty
		, SUM(CASE a.[Type] WHEN 1 THEN a.ExtCost ELSE 0 END) MaterialCost
		, SUM(CASE a.[Type] WHEN 2 THEN a.Qty ELSE 0 END) AS ExpenseQty
		, SUM(CASE a.[Type] WHEN 2 THEN a.ExtCost ELSE 0 END) ExpenseCost
		, SUM(CASE a.[Type] WHEN 3 THEN a.Qty ELSE 0 END) AS OtherQty
		, SUM(CASE a.[Type] WHEN 3 THEN a.ExtCost ELSE 0 END) OtherCost
		, SUM(CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtCost ELSE 0 END) TotalCost
		, t.[ProjectDetailId] 
	FROM #tmpProjectDetailStatus t 
		LEFT JOIN 
		(
			SELECT ProjectDetailId, [Status], [Type], Qty, ExtCost 
			FROM dbo.tblPcActivity 
			WHERE Status < 6 
			UNION ALL 
			SELECT a.ProjectDetailId, b.[Status], a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost / b.Qty) END 
			FROM dbo.tblPcActivity a 
				INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
			WHERE a.[Source] = 12
		) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[Status] = a.[Status] 
	GROUP BY t.[ProjectDetailId] 
	UNION ALL 
	-- estimate total
	SELECT 7 AS [Status]
		, SUM(CASE e.[type] WHEN 0 THEN e.Qty ELSE 0 END) AS TimeQty
		, SUM(CASE e.[type] WHEN 0 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END) AS TimeCost
		, SUM(CASE e.[type] WHEN 1 THEN e.Qty ELSE 0 END) AS MaterialQty
		, SUM(CASE e.[type] WHEN 1 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END) AS MaterialCost
		, SUM(CASE e.[type] WHEN 2 THEN e.Qty ELSE 0 END) AS ExpenseQty
		, SUM(CASE e.[type] WHEN 2 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END) AS ExpenseCost
		, SUM(CASE e.[type] WHEN 3 THEN e.Qty ELSE 0 END) AS OtherQty
		, SUM(CASE e.[type] WHEN 3 THEN ROUND(e.Qty * e.UnitCost, 2) ELSE 0 END) AS OtherCost
		, ISNULL(SUM(ROUND(e.Qty * e.UnitCost, 2)), 0) AS TotalCost
		, t.ProjectDetailId 
	FROM 
	(
		SELECT ProjectDetailId FROM #tmpProjectDetailStatus GROUP BY ProjectDetailId
	) t 
		LEFT JOIN dbo.tblPcEstimate e ON t.ProjectDetailId = e.ProjectDetailId 
	GROUP BY t.ProjectDetailId

	SELECT d.Id, p.CustId, c.CustName, p.ProjectName, d.ProjectManager, d.PhaseId, d.TaskId, d.[Description] AS ProDescr
		, p.[Type], d.[Status], d.BillOnHold, d.FixedFeeAmt, d.EstStartDate, d.EstEndDate, d.ActStartDate, d.ActEndDate
		, d.AddnlDesc, d.LastDateBilled, d.RateId, d.Rep2Id, d.Rep1Id, d.CustPoNum, d.OrderDate
		, ISNULL(SUM(bil.BilledAmount), 0) AS BilledPTD, est.TotalCost AS EstimatedCosts, (pos.TotalCost) AS PostedCosts
		, ISNULL(((pos.TotalCost / NULLIF(est.TotalCost, 0)) * 100), 0) AS PctComplete
		, (CASE WHEN pos.TotalCost <= est.TotalCost THEN ISNULL(pos.TotalCost / NULLIF(est.TotalCost, 0), 0) ELSE 100 END) AS PctEarned
		, ((CASE WHEN pos.TotalCost <= est.TotalCost THEN ISNULL(pos.TotalCost / NULLIF(est.TotalCost, 0), 0) ELSE 100 END) 
			* d.FixedFeeAmt) AS EarnedIncome
		, (d.FixedFeeAmt - est.TotalCost) AS EstGrossProfit
		, ISNULL((((d.FixedFeeAmt - est.TotalCost) / NULLIF(d.FixedFeeAmt, 0)) * 100), 0) AS EstGrossMargin
		, ISNULL(pos.TotalCost / NULLIF((CASE WHEN pos.TotalCost <= est.TotalCost 
			THEN ISNULL(pos.TotalCost / NULLIF(est.TotalCost, 0), 0) ELSE 100 END), 0), 0) AS ProjectedCosts
		, (d.FixedFeeAmt - ISNULL(pos.TotalCost / NULLIF((CASE WHEN pos.TotalCost <= est.TotalCost 
			THEN ISNULL(pos.TotalCost / NULLIF(est.TotalCost, 0), 0) ELSE 100 END), 0), 0)) AS ProjectedProfit
		, ISNULL((d.FixedFeeAmt - ISNULL(pos.TotalCost / NULLIF((CASE WHEN pos.TotalCost <= est.TotalCost 
			THEN ISNULL(pos.TotalCost / NULLIF(est.TotalCost, 0), 0) ELSE 100 END), 0), 0)) 
			/ NULLIF(d.FixedFeeAmt, 0), 0) AS ProjectedMargin
		, ta.[Description] AS TaskDescr, ph.[Description] AS PhaseDescr 
	FROM dbo.trav_PcProjectTask_view AS d 
		LEFT JOIN dbo.tblPcProject AS p ON p.Id = d.ProjectId 
		LEFT JOIN dbo.tblArCust AS c ON p.CustId = c.CustId 
		LEFT JOIN (SELECT * FROM #tmpDashboard db WHERE db.Category = 2) pos ON pos.ProjectDetailId = d.Id 
		LEFT JOIN (SELECT * FROM #tmpDashboard db WHERE db.Category = 7) est ON est.ProjectDetailId = d.Id 
		LEFT JOIN dbo.tblPcPhase AS ph ON ph.PhaseId = d.PhaseId 
		LEFT JOIN dbo.tblPcTask AS ta ON ta.TaskId = d.TaskId 
		LEFT JOIN
		(
			SELECT a.ProjectDetailId
				, CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled WHEN a.[Type] = 6 THEN a.ExtIncome 
					WHEN a.[Type] = 7 THEN -a.ExtIncome ELSE 0 END AS BilledAmount 
			FROM dbo.tblPcActivity a
		) bil ON bil.ProjectDetailId = d.Id 
		INNER JOIN #tmpProjectDetailList po ON po.ProjectDetailId = d.Id 
	GROUP BY d.Id, p.CustId, c.CustName, p.ProjectName, d.ProjectManager, d.PhaseId, d.TaskId, d.[Description], p.[Type], d.[Status]
		, d.BillOnHold, d.Billable, d.FixedFeeAmt, d.EstStartDate, d.EstEndDate, d.ActStartDate, d.ActEndDate, d.AddnlDesc
		, d.LastDateBilled, d.RateId, d.Rep2Id, d.Rep1Id, d.CustPoNum, d.OrderDate
		, est.TotalCost, pos.TotalCost, est.TotalCost, pos.TotalCost, ta.[Description], ph.[Description]

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectPercentCompleteView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectPercentCompleteView_proc';

