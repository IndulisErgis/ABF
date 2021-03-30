
CREATE PROCEDURE [dbo].[trav_PaEmpHistMiscAmount_proc]
@employeeId pEmpId,
@paYear SMALLINT,
@miscCodeId nvarchar(10)
AS
BEGIN TRY
	SET NOCOUNT ON
	SELECT SUM([Amount]) AS [Amount]  FROM [dbo].[tblPaEmpHistMisc]
	WHERE [EmployeeId] = @employeeId AND [PaYear] = @paYear AND [MiscCodeId] = @miscCodeId
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistMiscAmount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistMiscAmount_proc';

