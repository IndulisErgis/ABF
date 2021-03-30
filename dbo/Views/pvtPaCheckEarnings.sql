
CREATE VIEW dbo.pvtPaCheckEarnings
AS

SELECT ce.EarningCode, t.State AS StateCode, ce.DepartmentId, ce.HoursWorked, ce.EarningAmount
	, c.EmployeeId, c.CheckNumber, c.CheckDate, e.LastName 
FROM dbo.tblPaCheck c 
	INNER JOIN dbo.tblSmEmployee e ON c.EmployeeId = e.EmployeeId 
	INNER JOIN dbo.tblPaCheckEarn ce ON c.Id = ce.CheckId 
	INNER JOIN dbo.tblPaEarnCode ec ON ce.EarningCode = ec.Id 
	INNER JOIN dbo.tblPaTaxAuthorityHeader t ON ce.StateTaxAuthorityId = t.Id
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckEarnings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckEarnings';

