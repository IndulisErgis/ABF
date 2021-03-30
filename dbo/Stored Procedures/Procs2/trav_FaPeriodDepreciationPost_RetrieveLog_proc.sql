
CREATE PROCEDURE dbo.trav_FaPeriodDepreciationPost_RetrieveLog_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--remap values from the temp table for the post log
	SELECT [Id] AS [Counter]
		, [DeprcType], [Type]
		, [FiscalYear], [FiscalPeriod]
		, [BeginPd], [EndPd]
		, [TotalDepreciation] AS [CurrDepr]
		, [AssetsDepreciated] AS [CurrentAssetCount]
		, [AssetsPosted] AS [ProcessedAssetCount]
		, [AssetCount] AS [TotalAssetCount]
	FROM #PeriodDepreciationPostLog
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaPeriodDepreciationPost_RetrieveLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaPeriodDepreciationPost_RetrieveLog_proc';

