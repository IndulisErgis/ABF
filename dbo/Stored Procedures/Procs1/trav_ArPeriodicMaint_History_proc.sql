
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_History_proc
AS

SET NOCOUNT ON
BEGIN TRY
	DECLARE @DeleteHistoryDate datetime

	--Retrieve global values
	SELECT @DeleteHistoryDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DeleteHistoryDate'

	--================
	--Delete detail history with invoice dates prior to the given date
	--================
	IF @DeleteHistoryDate IS NOT NULL
	BEGIN
		DELETE dbo.tblArHistHeader WHERE InvcDate < @DeleteHistoryDate

		DELETE dbo.tblArHistTax 
			WHERE NOT EXISTS (SELECT 1 FROM dbo.tblArHistHeader h WHERE h.PostRun = dbo.tblArHistTax.PostRun AND h.TransId = dbo.tblArHistTax.TransId)

		DELETE dbo.tblArHistDetail FROM dbo.tblArHistHeader H 
			WHERE NOT EXISTS (SELECT 1 FROM dbo.tblArHistHeader h WHERE h.PostRun = dbo.tblArHistDetail.PostRun AND h.TransId = dbo.tblArHistDetail.TransId)
	
		DELETE dbo.tblArHistLot 
			WHERE NOT EXISTS (SELECT 1 FROM dbo.tblArHistHeader h WHERE h.PostRun = dbo.tblArHistLot.PostRun AND h.TransId = dbo.tblArHistLot.TransId)

		DELETE dbo.tblArHistSer FROM dbo.tblArHistHeader H 
			WHERE NOT EXISTS (SELECT 1 FROM dbo.tblArHistHeader h WHERE h.PostRun = dbo.tblArHistSer.PostRun AND h.TransId = dbo.tblArHistSer.TransId)

	    
		DELETE dbo.tblArHistPmt WHERE PmtDate < @DeleteHistoryDate
	END
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_History_proc';

