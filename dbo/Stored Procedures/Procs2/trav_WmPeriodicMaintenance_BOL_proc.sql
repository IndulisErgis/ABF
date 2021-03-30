
CREATE PROCEDURE dbo.trav_WmPeriodicMaintenance_BOL_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @DeleteBOLDate DateTime
	
	--Retrieve global values
	SELECT @DeleteBOLDate = Cast([Value] AS DateTime) FROM #GlobalValues WHERE [Key] = 'DeleteBOLDate'

	IF @DeleteBOLDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	
	--purge Bill of lading entries with ship dates prior to the DeleteBOLDate
	DELETE dbo.tblWMBOLHeader
		WHERE [Shipdate] < @DeleteBOLDate
		
	--remove child entries 
	DELETE dbo.tblWmBOLDetailCustomerOrder
		WHERE BOLRef NOT IN (SELECT BOLRef FROM dbo.tblWMBOLHeader)
	
	DELETE dbo.tblWMBOLDetail
		WHERE BOLRef NOT IN (SELECT BOLRef FROM dbo.tblWMBOLHeader)

	DELETE dbo.tblWMBOLDetailHM
		WHERE BOLDtlRef NOT IN (SELECT BOLDtlRef FROM dbo.tblWMBOLDetail)
	

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmPeriodicMaintenance_BOL_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmPeriodicMaintenance_BOL_proc';

