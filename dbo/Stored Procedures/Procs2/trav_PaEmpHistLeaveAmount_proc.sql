
CREATE PROCEDURE [dbo].[trav_PaEmpHistLeaveAmount_proc]
@employeeId pEmpId,
@paYear SMALLINT,
@leaveCodeId nvarchar(3)
AS
BEGIN TRY
	SET NOCOUNT ON
	SELECT SUM([AdjustmentAmount]) [Amount]   FROM [dbo].[tblPaEmpHistLeave]
	WHERE [EmployeeId] = @employeeId AND [PaYear] = @paYear AND [LeaveCodeId] = @leaveCodeId
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistLeaveAmount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistLeaveAmount_proc';

