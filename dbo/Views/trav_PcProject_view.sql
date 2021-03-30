
CREATE VIEW dbo.trav_PcProject_view
AS

SELECT p.Id, p.ProjectName, p.[Type], d.[Description], d.[Status], 
	d.BillOnHold, d.Speculative, d.Billable, d.FixedFee, d.EstStartDate, d.EstEndDate, 
	d.ActStartDate, d.ActEndDate, d.DistCode, d.OhAllCode, d.TaxClass, d.AddnlDesc, d.LastDateBilled, 
	d.RateId, c.CustId, c.CustName, c.ClassId, c.GroupCode, c.AcctType, c.PriceCode, c.DistCode AS CustomerDistCode, 
	c.TerrId, c.CustLevel, c.[Status] AS CustomerStatus, d.Rep1Id, d.Rep2Id, d.ProjectManager, d.Id AS ProjectDetailId,
	d.MaterialMarkup, d.ExpenseMarkup, d.OtherMarkup, d.CustPONum, d.OrderDate   
FROM dbo.tblPcProject p INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
	LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
WHERE d.TaskId IS NULL AND d.PhaseId IS NULL
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcProject_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcProject_view';

