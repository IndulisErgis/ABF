
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_SalesRep_proc
AS

SET NOCOUNT ON
BEGIN TRY
	DECLARE @ResetRepPTDSales bit, @ResetRepYTDSales bit

	--Retrieve global values
	SELECT @ResetRepPTDSales = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ResetRepPTDSales'
	SELECT @ResetRepYTDSales = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ResetRepYTDSales' 

	IF @ResetRepPTDSales IS NULL OR @ResetRepYTDSales IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--exit if nothing to do
	IF @ResetRepPTDSales = 0 AND @ResetRepYTDSales = 0 RETURN
	

	--================
	--Reset the sales rep sales amount
	--================
	UPDATE dbo.tblArSalesRep 
		SET PTDSales = CASE WHEN @ResetRepPTDSales = 1 THEN 0 ELSE PTDSales END
		, YTDSales = CASE WHEN @ResetRepYTDSales = 1 THEN 0 ELSE YTDSales END
	
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_SalesRep_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_SalesRep_proc';

