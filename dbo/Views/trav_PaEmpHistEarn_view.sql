
CREATE VIEW dbo.trav_PaEmpHistEarn_view
AS
---PET:http://webfront:801/view.php?id=228828
SELECT Id, 1 as [Type], EntryDate, PaYear, PaMonth,
EmployeeId, EarningCode as Code,  Amount 
From dbo.tblPaEmpHistEarn
union all
SELECT Id, 2 as [Type], EntryDate, PaYear, PaMonth,
EmployeeId, EarningCode as Code,  Hours  
From dbo.tblPaEmpHistEarn
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistEarn_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmpHistEarn_view';

