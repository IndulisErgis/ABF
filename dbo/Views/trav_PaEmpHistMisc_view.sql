
CREATE VIEW dbo.trav_PaEmpHistMisc_view
AS


SELECT h.Id, 1 as [Type], h.EntryDate, h.PaYear, 
h.PaMonth, h.EmployeeId, h.MiscCodeId as Code, h.Amount 
FROM dbo.tblPaEmpHistMisc h  
Inner Join tblPaMiscCode c On h.MiscCodeId = c.Id
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistMisc_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistMisc_view';

