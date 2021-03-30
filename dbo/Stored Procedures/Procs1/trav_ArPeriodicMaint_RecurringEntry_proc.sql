
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_RecurringEntry_proc
AS

SET NOCOUNT ON
BEGIN TRY
	DECLARE @DeleteRecurringEntryDate datetime
	DECLARE @DeleteRecurHistoryDate datetime

	--Retrieve global values
	SELECT @DeleteRecurringEntryDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DeleteRecurringEntryDate'
	SELECT @DeleteRecurHistoryDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DeleteRecurHistoryDate'

	--================
	--Delete recurring entries with an ending date prior to the given date
	--================
	IF @DeleteRecurringEntryDate IS NOT NULL
	BEGIN
		--remove header entries
		DELETE dbo.tblArRecurHeader WHERE EndingDate < @DeleteRecurringEntryDate OR EndingDate IS NULL
		
		--remove details for the entries that were deleted
		DELETE dbo.tblArRecurDetail WHERE RecurId NOT IN (SELECT RecurId FROM dbo.tblArRecurHeader)

		--remove history for the entries that were deleted
		DELETE dbo.tblArHistRecur WHERE RecurId NOT IN (SELECT RecurId FROM dbo.tblArRecurHeader)
	END

	 
	--================
	--Delete recurring entry history with a copy date prior to the given date
	--================
	IF @DeleteRecurHistoryDate IS NOT NULL
	BEGIN
		DELETE dbo.tblArHistRecur 
		FROM dbo.tblArHistRecur 
			LEFT JOIN (SELECT RecurID, MIN(ISNULL(BillDate, CopyDate)) AS MinDate 
				FROM dbo.tblArHistRecur WHERE PostRun IS NULL GROUP BY RecurID) d 
			ON d.RecurID = dbo.tblArHistRecur.RecurID 
		WHERE CopyDate < @DeleteRecurHistoryDate 
			AND (ISNULL(BillDate, CopyDate) < d.MinDate OR d.MinDate IS NULL) 
			AND PostRun IS NOT NULL
	END

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_RecurringEntry_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_RecurringEntry_proc';

