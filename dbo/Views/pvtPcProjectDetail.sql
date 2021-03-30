
CREATE VIEW dbo.pvtPcProjectDetail
AS

SELECT CASE a.Status 
		WHEN 0 THEN 'On Order'
		WHEN 1 THEN 'Unposted' 
		WHEN 2 THEN 'Posted' 
		WHEN 3 THEN 'Work In Process' 
		WHEN 4 THEN 'Billed' 
		WHEN 5 THEN 'Completed' 
		ELSE '(NA)' END AS [Status]
	, a.SourceReference AS 'Source Reference', ISNULL(p.CustId, '(NA)') AS 'Customer ID', c.CustName AS 'Customer Name'
	, p.ProjectName AS 'Project ID', ISNULL(d.PhaseId, '(NA)') AS 'Phase Code'
	, ISNULL(d.TaskId, '(NA)') AS 'Task Code', a.ResourceId AS 'Resource ID', a.Reference AS 'Reference'
	, a.QtyBilled AS 'Qty Billed', a.Qty AS 'Qty'
	, CASE WHEN a.Qty = 0 THEN a.ExtCost ELSE (a.ExtCost / a.Qty) END AS 'Unit Cost'
	, a.ExtCost AS 'Ext Cost', CASE WHEN a.Qty = 0 THEN a.ExtIncome ELSE (a.ExtIncome / a.Qty) END AS 'Unit Income'
	, CASE WHEN a.QtyBilled = 0 THEN a.ExtIncomeBilled ELSE (a.ExtIncomeBilled / a.QtyBilled) END AS 'Unit Income Billed'
	, a.ExtIncomeBilled AS 'Ext Income Billed', a.ExtIncome AS 'Ext Income', a.ActivityDate AS 'Activity Date'
	, CASE a.Type
		WHEN 0 THEN 'Time' 
		WHEN 1 THEN 'Material' 
		WHEN 2 THEN 'Expense' 
		WHEN 3 THEN 'Other' 
		WHEN 4 THEN 'Deposit' 
		WHEN 5 THEN 'Deposit Applied' 
		WHEN 6 THEN 'Fixed Fee Billing' 
		WHEN 7 THEN 'Credit Memo' 
		ELSE '(NA)' END AS 'Type'
	, CASE a.Source 
		WHEN 0 THEN 'Time Ticket' 
		WHEN 1 THEN 'Transaction' 
		WHEN 2 THEN 'Overhead' 
		WHEN 3 THEN 'Adjustment' 
		WHEN 4 THEN 'Deposit' 
		WHEN 5 THEN 'Billing' 
		WHEN 6 THEN 'Credit Memo' 
		WHEN 7 THEN 'Unbill' 
		WHEN 8 THEN 'AP Invoice' 
		WHEN 9 THEN 'PO' 
		WHEN 10 THEN 'Unknown'
		WHEN 11 THEN 'PO Receipt'
		WHEN 12 THEN 'PO Invoice'
		ELSE '(NA)' END AS 'Source'
	, a.AddnlDesc AS 'Addnl Desc', a.DistCode AS 'Dist Code', a.TaxClass AS 'Tax Class'
	, d.Billable AS 'Billable', d.FixedFee AS 'Fixed Fee'
	, CASE WHEN a.Type BETWEEN 0 AND 3 THEN a.ExtIncomeBilled - a.ExtIncome ELSE 0 END AS 'Write UD'
	, a.FiscalPeriod AS 'Fiscal Period', a.FiscalYear AS 'Fiscal Year', a.OverheadPosted AS 'Overhead Posted'
	, a.RateId AS 'Rate ID', a.Uom AS 'Uom' 
FROM dbo.tblPcActivity a 
	INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId 
WHERE a.[Status] < 6
UNION ALL
SELECT CASE b.Status 
		WHEN 0 THEN 'On Order'
		WHEN 1 THEN 'Unposted' 
		WHEN 2 THEN 'Posted' 
		WHEN 3 THEN 'Work In Process' 
		WHEN 4 THEN 'Billed' 
		WHEN 5 THEN 'Completed' 
		ELSE '(NA)' END AS [Status]
	, a.SourceReference AS 'Source Reference', ISNULL(p.CustId, '(NA)') AS 'Customer ID', c.CustName AS 'Customer Name'
	, p.ProjectName AS 'Project ID', ISNULL(d.PhaseId, '(NA)') AS 'Phase Code'
	, ISNULL(d.TaskId, '(NA)') AS 'Task Code', a.ResourceId AS 'Resource ID', a.Reference AS 'Reference'
	, 0 AS 'Qty Billed', -a.Qty AS 'Qty'
	, CASE WHEN b.Qty = 0 THEN 0 ELSE (b.ExtCost / b.Qty) END AS 'Unit Cost'
	, CASE WHEN b.Qty = 0 THEN 0 ELSE -a.Qty * (b.ExtCost / b.Qty) END AS 'Ext Cost'
	, CASE WHEN b.Qty = 0 THEN 0 ELSE (b.ExtIncome / b.Qty) END AS 'Unit Income'
	, 0 AS 'Unit Income Billed'
	, 0 AS 'Ext Income Billed', 
	CASE WHEN b.Qty = 0 THEN 0 ELSE -a.Qty * (b.ExtIncome / b.Qty) END AS 'Ext Income', a.ActivityDate AS 'Activity Date'
	, CASE a.Type
		WHEN 0 THEN 'Time' 
		WHEN 1 THEN 'Material' 
		WHEN 2 THEN 'Expense' 
		WHEN 3 THEN 'Other' 
		WHEN 4 THEN 'Deposit' 
		WHEN 5 THEN 'Deposit Applied' 
		WHEN 6 THEN 'Fixed Fee Billing' 
		WHEN 7 THEN 'Credit Memo' 
		ELSE '(NA)' END AS 'Type'
	, CASE a.Source 
		WHEN 0 THEN 'Time Ticket' 
		WHEN 1 THEN 'Transaction' 
		WHEN 2 THEN 'Overhead' 
		WHEN 3 THEN 'Adjustment' 
		WHEN 4 THEN 'Deposit' 
		WHEN 5 THEN 'Billing' 
		WHEN 6 THEN 'Credit Memo' 
		WHEN 7 THEN 'Unbill' 
		WHEN 8 THEN 'AP Invoice' 
		WHEN 9 THEN 'PO' 
		WHEN 10 THEN 'Unknown'
		WHEN 11 THEN 'PO Receipt'
		WHEN 12 THEN 'PO Invoice'
		ELSE '(NA)' END AS 'Source'
	, a.AddnlDesc AS 'Addnl Desc', a.DistCode AS 'Dist Code', a.TaxClass AS 'Tax Class'
	, d.Billable AS 'Billable', d.FixedFee AS 'Fixed Fee'
	, CASE WHEN a.Type BETWEEN 0 AND 3 THEN a.ExtIncomeBilled - a.ExtIncome ELSE 0 END AS 'Write UD'
	, a.FiscalPeriod AS 'Fiscal Period', a.FiscalYear AS 'Fiscal Year', a.OverheadPosted AS 'Overhead Posted'
	, a.RateId AS 'Rate ID', a.Uom AS 'Uom' 
FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcActivity b ON a.RcptId = b.Id
	INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId 
WHERE a.[Source] = 12
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPcProjectDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPcProjectDetail';

