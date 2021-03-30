
CREATE VIEW dbo.pvtPaRecurringDeductions
AS

SELECT Id AS TransID, EmployeeId, DeductCode, LaborClass, Hours, Amount 
FROM dbo.tblPaRecurDeduct
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaRecurringDeductions';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaRecurringDeductions';

