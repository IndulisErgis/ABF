
CREATE VIEW dbo.trav_PcTimeTicket_view
AS

SELECT t.Id, p.ProjectName, d.[Description], c.CustId, d.ProjectManager, d.TaskId, d.PhaseId,
	t.EmployeeId, t.TransDate, t.BatchId, e.LastName, e.FirstName, r.DepartmentId, r.EmployeeStatus, 
	r.StartDate, r.TerminationDate, e.BirthDate, e.[Status]
FROM dbo.tblPcTimeTicket t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	INNER JOIN dbo.tblSmEmployee e ON t.EmployeeId = e.EmployeeId 
	LEFT JOIN dbo.tblPaEmployee r ON e.EmployeeId = r.EmployeeId
	LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcTimeTicket_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PcTimeTicket_view';

