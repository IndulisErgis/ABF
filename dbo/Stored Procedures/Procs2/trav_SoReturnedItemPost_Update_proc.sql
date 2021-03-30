
CREATE PROCEDURE dbo.trav_SoReturnedItemPost_Update_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE	@WrkStnDate datetime

	--Retrieve global values
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @WrkStnDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	DECLARE @RMAPrefix nvarchar(4)
	SELECT @RMAPrefix = Right(Convert(nvarchar, @WrkStnDate, 12), 4)

	--reset/update values for posted records
	Update dbo.tblSoReturnedItem 
		Set dbo.tblSoReturnedItem.[Status] = 9
			, dbo.tblSoReturnedItem.QtySeqNum = 0
			, dbo.tblSoReturnedItem.QtySeqNumExt = 0
			, dbo.tblSoReturnedItem.RMANumber = ISNULL(dbo.tblSoReturnedItem.RMANumber, @RMAPrefix + dbo.tblSoReturnedItem.TransID)
		From #PostTransList l
		Where dbo.tblSoReturnedItem.[Counter] = l.TransId


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_Update_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_Update_proc';

