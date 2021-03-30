
CREATE PROCEDURE [dbo].[trav_PaEmpHistWHAmount_proc]
@employeeId pEmpId,
@paYear SMALLINT,
@taxAuthorityType TINYINT,
@state nvarchar(2),
@local nvarchar(2),
@whCode pCode,
@emplrPaid BIT,
@paMonth TINYINT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON
	SELECT SUM([EarningAmount]) AS [EarningAmount], SUM([WithholdAmount]) AS [WithholdAmount],SUM([TaxableAmount]) AS [TaxableAmount]  FROM [dbo].[tblPaEmpHistWithhold]
	WHERE [EmployeeId] = @employeeId AND [PaYear] = @paYear 
	AND [PaMonth]= ISNULL(@paMonth,[PaMonth]) 
	AND [TaxAuthorityType] = @taxAuthorityType AND ISNULL([State],1) = ISNULL(@state,1)
	AND ISNULL([Local],1) = ISNULL(@local,1) AND [WithholdingCode] = @whCode AND [EmployerPaid] = @emplrPaid 
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistWHAmount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmpHistWHAmount_proc';

