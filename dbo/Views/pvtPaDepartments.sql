
CREATE VIEW dbo.pvtPaDepartments
AS

SELECT h.Id AS 'Department ID', d.Code, d.GLAcct AS 'GL Account', a.Amount, a.PaYear, a.PaMonth 
FROM dbo.tblPaDept h 
	INNER JOIN dbo.tblPaDeptDtl d ON h.Id = d.DepartmentId 
	INNER JOIN dbo.tblPaDeptDtlAmount a ON d.Id = a.DeptDtlId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaDepartments';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaDepartments';

