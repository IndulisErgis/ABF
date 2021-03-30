
CREATE PROCEDURE dbo.trav_FaDeprActivity_proc
@DeprId int
AS
BEGIN TRY
	SET NOCOUNT ON

	SELECT FiscalYear, FiscalPeriod, TransDate, GLAccumDepr, GLExpense, Amount 
	FROM dbo.tblFaAssetDeprActivity WHERE DeprID = @DeprId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaDeprActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaDeprActivity_proc';

