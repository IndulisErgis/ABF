
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_ACH_proc
AS

SET NOCOUNT ON
BEGIN TRY
	DECLARE @DeleteTransmittedACHDate datetime

	--Retrieve global values
	SELECT @DeleteTransmittedACHDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DeleteTransmittedACHDate'

	--================
	--Delete transmitted ACH history prior to the given date
	--================
	IF @DeleteTransmittedACHDate IS NOT NULL
	BEGIN
		DELETE dbo.tblArPaymentACH WHERE (TransmitDate IS NOT NULL) AND (TransmitDate < @DeleteTransmittedACHDate)
	END
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_ACH_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_ACH_proc';

