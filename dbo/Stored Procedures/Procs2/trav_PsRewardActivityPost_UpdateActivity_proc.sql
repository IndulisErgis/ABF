
CREATE PROCEDURE dbo.trav_PsRewardActivityPost_UpdateActivity_proc 
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE	@PostRun pPostRun, @WrkStnDate datetime, @FiscalYear smallint, @FiscalPeriod smallint

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'

	--Retrieve global values
	IF @PostRun IS NULL OR @WrkStnDate IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--Update the activity that was processed
	UPDATE dbo.tblPsRewardActivity SET [PostRun] = @PostRun
		, [PostDate] = @WrkStnDate, [FiscalYear] = @FiscalYear, [FiscalPeriod] = @FiscalPeriod
	FROM #ActivityList l
	INNER JOIN dbo.tblPsRewardActivity a on l.[ID] = a.[ID]
	WHERE a.[PostRun] IS NULL --unposted


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPost_UpdateActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPost_UpdateActivity_proc';

