
CREATE VIEW dbo.trav_PaEmpHistGrossNet_view
AS

select h.Id, 1 as [Type], h.EntryDate, h.PaYear, h.PaMonth, 
h.EmployeeId, 'Gross' as Code,  h.GrossPayAmount as Amount 
from  dbo.tblPaEmpHistGrossNet h 
Union all

select N.Id, 1 as [Type], N.EntryDate, N.PaYear, N.PaMonth, 
N.EmployeeId, 'Net' as Code,  N.NetPayAmount as Amount 
from  dbo.tblPaEmpHistGrossNet N
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistGrossNet_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistGrossNet_view';

