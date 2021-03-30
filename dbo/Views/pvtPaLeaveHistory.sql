
CREATE VIEW dbo.pvtPaLeaveHistory
AS

SELECT PaYear, PaMonth, EmployeeId, LeaveCodeId, EarningCode
	, [Description], CheckNumber, AdjustmentAmount, AdjustmentDate 
FROM dbo.tblPaEmpHistLeave
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaLeaveHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaLeaveHistory';

