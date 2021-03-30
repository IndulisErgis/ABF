
CREATE VIEW dbo.pvtPaTransactionDeductions
AS

SELECT d.EmployeeId, d.DeductCode, c.Description, d.TransDate, d.Hours, d.Amount 
FROM dbo.tblPaTransDeduct d 
	INNER JOIN dbo.tblPaDeductCode c ON d.DeductCode = c.DeductionCode
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaTransactionDeductions';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaTransactionDeductions';

