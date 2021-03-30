
CREATE VIEW dbo.pvtPaTransactionEarnings
AS

SELECT e.EmployeeId, e.EarningCode, c.Description, e.DepartmentId, e.Pieces, e.Hours, e.Amount, e.TransDate 
FROM dbo.tblPaTransEarn e 
	INNER JOIN dbo.tblPaEarnCode c ON e.EarningCode = c.Id
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaTransactionEarnings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaTransactionEarnings';

