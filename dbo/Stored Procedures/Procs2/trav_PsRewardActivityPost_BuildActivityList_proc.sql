
CREATE PROCEDURE dbo.trav_PsRewardActivityPost_BuildActivityList_proc 
AS
SET NOCOUNT ON
BEGIN TRY

	--uses an existing temporary table that supports the following
	--CREATE TABLE ##ActivityList
	--(
	--	[ID] [bigint], 
	--	PRIMARY KEY CLUSTERED ([ID])
	--)

	--build list of Activity to include in processing
	INSERT INTO #ActivityList ([ID])
	SELECT a.[ID]
		FROM dbo.tblPsRewardActivity a 
		WHERE a.[PostRun] is null --unposted

	--return the rowcount to identify if there is data to process
	SELECT @@ROWCOUNT AS [RecordCount]


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPost_BuildActivityList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPost_BuildActivityList_proc';

