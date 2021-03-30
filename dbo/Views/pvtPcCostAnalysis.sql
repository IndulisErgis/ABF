
CREATE VIEW dbo.pvtPcCostAnalysis
AS

SELECT p.CustId AS 'Customer ID', p.ProjectName AS 'Project ID', d.PhaseId AS 'Phase ID', d.TaskId AS 'Task ID', 
	CASE c.Type WHEN 0 THEN 'Time' WHEN 1 THEN 'Material' WHEN 2 THEN 'Expense' WHEN 3 THEN 'Other' ELSE '' END AS [Type], 
	c.EstimateQty, c.EstimateCost, c.ActualQty,
	c.ActualCost, c.EstimateQty - c.ActualQty AS VarianceQty, c.EstimateCost - c.ActualCost AS VarianceCost, 
	CASE d.[Status] WHEN 0 THEN 'Active' WHEN 1 THEN 'Hold' WHEN 2 THEN 'Completed' ELSE '' END AS [Status],
	CASE WHEN c.EstimateQty = 0 THEN 0 ELSE (c.EstimateQty - c.ActualQty)/c.EstimateQty END * 100 AS PercentQty,
	CASE WHEN c.EstimateCost = 0 THEN 0 ELSE (c.EstimateCost - c.ActualCost)/c.EstimateCost END * 100 AS PercentCost, 
	CASE WHEN(c.EstimateQty - c.ActualQty) < 0 THEN 'Negative Cost Variance' ELSE 'Positive Cost Variance' END AS 'Cost Variance Type' 
FROM
(
SELECT e.Id, e.[Type], e.Qty AS EstimateQty, e.EstimateCost, a.Qty AS ActualQty, a.ExtCost AS ActualCost FROM
(SELECT d.Id, e.[Type], SUM(e.Qty * e.UnitCost) AS EstimateCost, SUM(e.Qty) AS Qty 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId 
	WHERE e.[Type] BETWEEN 0 AND 3
	GROUP BY d.Id, e.[Type]) e INNER JOIN
(SELECT d.Id, a.[Type], SUM(a.ExtCost) AS ExtCost, SUM(a.Qty) AS Qty 
	FROM dbo.tblPcProjectDetail d INNER JOIN (SELECT ProjectDetailId, [Type], Qty, ExtCost FROM dbo.tblPcActivity WHERE Status < 6 UNION ALL 
	 SELECT a.ProjectDetailId, a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	 WHERE a.[Source] = 12) a ON d.Id = a.ProjectDetailId
	WHERE a.[Type] BETWEEN 0 AND 3
	GROUP BY d.Id, a.[Type]) a ON e.Id = a.Id AND e.[Type] = a.[Type]
UNION ALL
SELECT e.Id, e.[Type], e.Qty AS EstimateQty, e.EstimateCost, ISNULL(a.Qty,0) AS ActualQty,  ISNULL(a.ExtCost,0) AS ActualCost FROM
(SELECT d.Id, e.[Type], SUM(e.Qty * e.UnitCost) AS EstimateCost, SUM(e.Qty) AS Qty 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId
	WHERE e.[Type] BETWEEN 0 AND 3
	GROUP BY d.Id, e.[Type]) e LEFT JOIN
(SELECT d.Id, a.[Type], SUM(a.ExtCost) AS ExtCost, SUM(a.Qty) AS Qty 
	FROM dbo.tblPcProjectDetail d INNER JOIN (SELECT ProjectDetailId, [Type], Qty, ExtCost FROM dbo.tblPcActivity WHERE Status < 6 UNION ALL 
	 SELECT a.ProjectDetailId, a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	 WHERE a.[Source] = 12) a ON d.Id = a.ProjectDetailId
	WHERE a.[Type] BETWEEN 0 AND 3
	GROUP BY d.Id, a.[Type]) a ON e.Id = a.Id AND e.[Type] = a.[Type] 
WHERE a.Id IS NULL
UNION ALL
SELECT a.Id, a.[Type], ISNULL(e.Qty,0) AS EstimateQty, ISNULL(e.EstimateCost,0) AS EstimateCost, a.Qty AS ActualQty, a.ExtCost AS ActualCost FROM
(SELECT d.Id, e.[Type], SUM(e.Qty * e.UnitCost) AS EstimateCost, SUM(e.Qty) AS Qty 
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId
	WHERE e.[Type] BETWEEN 0 AND 3
	GROUP BY d.Id, e.[Type]) e RIGHT JOIN
(SELECT d.Id, a.[Type], SUM(a.ExtCost) AS ExtCost, SUM(a.Qty) AS Qty 
	FROM dbo.tblPcProjectDetail d INNER JOIN (SELECT ProjectDetailId, [Type], Qty, ExtCost FROM dbo.tblPcActivity WHERE Status < 6 UNION ALL 
	 SELECT a.ProjectDetailId, a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	 WHERE a.[Source] = 12) a ON d.Id = a.ProjectDetailId
	WHERE a.[Type] BETWEEN 0 AND 3
	GROUP BY d.Id, a.[Type]) a ON e.Id = a.Id AND e.[Type] = a.[Type] 
WHERE e.Id IS NULL
) c INNER JOIN dbo.tblPcProjectDetail d ON c.Id = d.Id
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPcCostAnalysis';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPcCostAnalysis';

