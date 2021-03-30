
CREATE VIEW dbo.trav_PcActivity_view
AS
SELECT a.Id, a.[Status], a.Source, a.[Type], a.FiscalPeriod, a.FiscalYear, d.ProjectManager, d.[Status] AS ProjectStatus,
	a.ActivityDate, a.ResourceId, a.LocId, d.ProjectName, d.TaskId, d.PhaseId, d.[Description] AS ProjectDescription,
	a.[Description], d.CustId, d.Billable
FROM dbo.tblPcActivity a INNER JOIN dbo.trav_PcProjectTask_view d ON a.ProjectDetailId = d.Id
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcActivity_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcActivity_view';

