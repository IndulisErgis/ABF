
CREATE VIEW dbo.trav_PaEmpHistWithhold_view
AS
Select Id, 3 as [Type],
EntryDate, PaYear, PaMonth, EmployeeId, WithholdingCode as Code,
WithholdAmount as Amount from dbo.tblPaEmpHistWithhold
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistWithhold_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistWithhold_view';

