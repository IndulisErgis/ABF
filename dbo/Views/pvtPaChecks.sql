
CREATE VIEW dbo.pvtPaChecks
AS

SELECT c.EmployeeId, c.CheckNumber, c.CheckDate, c.GrossPay, c.NetPay, c.TotalHoursWorked, e.LastName 
FROM dbo.tblPaCheck c INNER JOIN dbo.tblSmEmployee e ON c.EmployeeId = e.EmployeeId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaChecks';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaChecks';

