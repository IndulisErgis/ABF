
CREATE PROCEDURE [dbo].[trav_PaEmployeeCount_proc]
@groupCode TINYINT
AS
BEGIN TRY
	SET NOCOUNT ON
	SELECT COUNT(p.[EmployeeId]) AS [EmpCount] FROM [dbo].[tblPaEmployee] p INNER JOIN [dbo].[tblSmEmployee] s 
	ON p.EmployeeId = s.EmployeeId WHERE p.[GroupCode] = @groupCode AND s.[Status] = 0
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmployeeCount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmployeeCount_proc';

