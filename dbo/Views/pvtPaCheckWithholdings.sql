
CREATE VIEW dbo.pvtPaCheckWithholdings
AS

SELECT w.WithholdingCode, w.Description, w.WithholdingEarnings, w.WithholdingPayments
	, c.EmployeeId, e.LastName, c.CheckNumber, c.CheckDate 
FROM dbo.tblPaCheck c 
	INNER JOIN dbo.tblSmEmployee e ON c.EmployeeId = e.EmployeeId 
	INNER JOIN dbo.tblPaCheckWithhold w ON c.Id = w.CheckId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckWithholdings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckWithholdings';

