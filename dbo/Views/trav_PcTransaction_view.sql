
CREATE VIEW dbo.trav_PcTransaction_view
AS

SELECT t.Id, p.ProjectName, d.[Description], c.CustId, d.ProjectManager, d.TaskId, d.PhaseId,
	t.TransDate, t.BatchId
FROM dbo.tblPcTrans t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcTransaction_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcTransaction_view';

