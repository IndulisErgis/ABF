
CREATE VIEW dbo.pvtPaCheckDeductions
AS

SELECT d.DeductionCode, d.DeductionHours, d.DeductionAmount, d.DeductionBalance
	, c.EmployeeId, e.LastName, c.CheckNumber, c.CheckDate 
FROM dbo.tblPaCheck c 
	INNER JOIN dbo.tblSmEmployee e ON c.EmployeeId = e.EmployeeId 
	INNER JOIN dbo.tblPaCheckDeduct d ON c.Id = d.CheckId 
	LEFT JOIN dbo.tblPaDeductCode o ON d.DeductionCode = o.DeductionCode
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckDeductions';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckDeductions';

