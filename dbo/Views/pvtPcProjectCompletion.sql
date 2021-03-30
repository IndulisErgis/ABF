
CREATE VIEW dbo.pvtPcProjectCompletion
AS

SELECT ISNULL(p.CustId, '(NA)') AS 'Customer ID', c.CustName AS 'Customer Name'
	, p.ProjectName AS 'Project ID', ISNULL(d.PhaseId, '(NA)') AS 'Phase Code'
	, ISNULL(d.TaskId, '(NA)') AS 'Task Code'
	, SUM(CASE WHEN a.Type = 0 THEN a.ExtCost ELSE 0 END) AS 'Time in Dollars'
	, SUM(CASE WHEN a.Type = 0 THEN a.Qty ELSE 0 END) AS 'Time in Hours'
	, SUM(CASE WHEN a.Type = 1 THEN a.ExtCost ELSE 0 END) AS 'Material in Dollars'
	, SUM(CASE WHEN a.Type = 2 THEN a.ExtCost ELSE 0 END) AS 'Expense in Dollars'
	, SUM(CASE WHEN a.Type = 3 THEN a.ExtCost ELSE 0 END) AS 'Other in Dollars' 
FROM (SELECT ProjectDetailId, [Type], Qty, ExtCost FROM dbo.tblPcActivity WHERE Status < 6 UNION ALL 
	 SELECT a.ProjectDetailId, a.[Type], -a.Qty, CASE b.Qty WHEN 0 THEN 0 ELSE -a.Qty * (b.ExtCost/b.Qty) END FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id 
	 WHERE a.[Source] = 12) a 
	INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId 
GROUP BY p.CustId, c.CustName, p.ProjectName, d.PhaseId, d.TaskId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPcProjectCompletion';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPcProjectCompletion';

