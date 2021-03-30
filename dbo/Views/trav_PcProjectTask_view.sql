
CREATE VIEW dbo.trav_PcProjectTask_view
AS

SELECT p.ProjectName, p.[Type], d.[Description], d.[Status], d.TaskId, d.PhaseId,
	d.BillOnHold, d.Speculative, d.Billable, d.FixedFee, d.EstStartDate, d.EstEndDate, 
	d.ActStartDate, d.ActEndDate, d.DistCode, d.OhAllCode, d.TaxClass, d.AddnlDesc, d.LastDateBilled, 
	d.RateId, c.CustId, c.CustName, c.ClassId, c.GroupCode, c.AcctType, c.PriceCode, c.DistCode AS CustomerDistCode, 
	c.TerrId, c.CustLevel, c.[Status] AS CustomerStatus, d.Id, d.ProjectId, ISNULL(d.Rep1Id,e.Rep1Id) AS Rep1Id, 
	ISNULL(d.Rep2Id, e.Rep2Id) AS Rep2Id, ISNULL(d.ProjectManager,e.ProjectManager) AS ProjectManager,
	d.FixedFeeAmt, d.MaterialMarkup, d.ExpenseMarkup, d.OtherMarkup, d.OverrideRate, d.Rep1Pct, d.Rep2Pct,
	d.Rep1CommRate, d.Rep2CommRate, e.CustPoNum, e.OrderDate
FROM dbo.tblPcProject p INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId 
	INNER JOIN dbo.trav_PcProject_view e ON p.Id = e.Id
	LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcProjectTask_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcProjectTask_view';

