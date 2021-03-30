
CREATE PROCEDURE dbo.trav_FaPeriodDepreciationPost_Update_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @PostRun pPostRun,@WksDate datetime

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	
	IF @PostRun IS NULL OR @WksDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	
	--create depreciation activity records 
	DECLARE @MaxId int
	SELECT @MaxId = MAX([ID]) FROM dbo.tblFaAssetDeprActivity
	SELECT @MaxId = ISNULL(@MaxId, 0)
	
	INSERT INTO dbo.tblFaAssetDeprActivity ([ID], [DeprID], [TransType], [EntryDate], [TransDate]
		, [GLAccumDepr], [GLExpense], [Amount], [FiscalPeriod], [FiscalYear], [PostRun])
	SELECT @MaxId + [ID]
		, [DeprID], 0, @WksDate, @WksDate
		, [GLAccumDepr], [GLExpense], [Amount], [FiscalPeriod], [FiscalYear], @PostRun
	FROM #PeriodDepreciationPostActivity
	WHERE [Amount] <> 0


	--Reset the posted Asset Depreciation entries
	UPDATE dbo.tblFaAssetDepr SET [CurrDepr] = 0
	FROM #PeriodDepreciationPostActivity a
	WHERE dbo.tblFaAssetDepr.[ID] = a.[DeprID]
		AND a.[Amount] <> 0 


	--update the option depreciation entries
	UPDATE dbo.tblFaOptionDepr SET [Process] = 0, [PdProcessed] = [PdProcessed] + ([EndPd] - [BeginPd] + 1)
	FROM dbo.tblFaOptionDepr
		INNER JOIN #PostTransList l ON dbo.tblFaOptionDepr.[DeprType] = l.[TransId] 
	WHERE dbo.tblFaOptionDepr.[Process] = 1
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaPeriodDepreciationPost_Update_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaPeriodDepreciationPost_Update_proc';

