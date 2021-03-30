
CREATE PROCEDURE dbo.trav_DRGenerateRunData_Prepare_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE	@RunId pPostRun

	--Retrieve global values
	SELECT @RunId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'RunId'
	
	IF @RunId IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--purge any existing data for the identified RunId
	DELETE [dbo].[tblDrRunInfo] WHERE [RunId] = @RunId
	
	DELETE [dbo].[tblDrRunItemLoc] WHERE [RunId] = @RunId

	DELETE [dbo].[tblDrRunData] WHERE [RunId] = @RunId
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_Prepare_proc';

