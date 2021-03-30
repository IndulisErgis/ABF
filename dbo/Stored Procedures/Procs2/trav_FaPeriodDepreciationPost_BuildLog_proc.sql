
CREATE PROCEDURE dbo.trav_FaPeriodDepreciationPost_BuildLog_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @PostRun pPostRun, @CurrBase pCurrency
		,@WksDate datetime, @CompId nvarchar(3), @PostDtlYn bit

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	----populates the log table defined as follows
	--CREATE TABLE #PeriodDepreciationPostLog 
	--	(
	--		[Id] [int] Not Null Identity(1, 1), 
	--		[DeprcType] nvarchar(6) Null , 
	--		[FiscalYear] smallint Null , 
	--		[FiscalPeriod] smallint Null , 
	--		[BeginPd] smallint Null , 
	--		[EndPd] smallint Null , 
	--		[TotalDepreciation] pDec Null , 
	--		[AssetCount] int Null , 
	--		[AssetsPosted] int Null , 
	--		[AssetsDepreciated] int Null , 
	--		PRIMARY KEY ([Id])
	--	)

	----populates the activity table defined as follows
	--CREATE TABLE #PeriodDepreciationPostActivity 
	--(
	--	[ID] [int] Not Null Identity(1, 1), 
	--	[DeprcType] nvarchar(6) Null,
	--	[Type] tinyint Null, --Depr Option Type
	--	[AssetID] [pAssetID] Null, 
	--	[DeprID] int Null, 
	--	[GLAccumDepr] pGlAcct Null, 
	--	[GLExpense] pGlAcct Null, 
	--	[Amount] pDec Null , 
	--	[FiscalPeriod] smallint Null, 
	--	[FiscalYear] smallint Null, 
	--	PRIMARY KEY ([Id])
	--)


	--build the posting log
	INSERT INTO #PeriodDepreciationPostLog ([DeprcType], [Type]
		, [FiscalYear], [FiscalPeriod], [BeginPd], [EndPd]
		, [TotalDepreciation], [AssetsPosted], [AssetsDepreciated], [AssetCount])
	SELECT o.[DeprType], o.[Type], o.[FiscalYear], o.[GLPd], o.[BeginPd], o.[EndPd]
		, SUM(d.[CurrDepr]) AS [TotalDepreciation]
		, COUNT(d.[DeprcType]) AS [AssetsPosted]
		, SUM(CASE WHEN d.[CurrDepr] <> 0 THEN 1 ELSE 0 END) AS [AssetsDepreciated]
		, (SELECT COUNT(1) AS [AssetCount] FROM dbo.tblFaAssetDepr ad WHERE ad.[DeprcType] = d.[DeprcType]) AS [AssetCount]
	FROM dbo.tblFaOptionDepr o
		INNER JOIN #PostTransList l ON o.DeprType = l.TransId 
		INNER JOIN dbo.tblFaAssetDepr d ON o.DeprType = d.DeprcType
		INNER JOIN dbo.tblFaAsset a ON d.AssetId = a.AssetID
		INNER JOIN 
		(
			SELECT AssetId, CASE WHEN SUM(CurrDepr) <> 0 THEN 1 ELSE 0 END AS [HasDepreciation] 
			FROM dbo.tblFaAssetDepr 
			GROUP BY AssetId
		) r ON a.AssetId = r.AssetID
	WHERE o.[Process] = 1 
		AND (a.[AssetStatus] = 1 OR (a.[AssetStatus] = 2 AND r.[HasDepreciation] = 1))
	GROUP BY o.[DeprType], d.[DeprcType], o.[Type], o.[FiscalYear], o.[BeginPd], o.[EndPd], o.[GLPd]
	
	
	--Identify the activity entries to generate
	INSERT INTO #PeriodDepreciationPostActivity([DeprcType], [Type]
		, [AssetId], [DeprID]
		, [GlAccumDepr], [GlExpense], [Amount]
		, [FiscalYear], [FiscalPeriod])
	SELECT o.[DeprType], o.[Type]
		, d.[AssetID], d.[Id]
		, a.[GLAccum], a.[GLExpense], d.[CurrDepr]
		, o.[FiscalYear], o.[GLPd]
	FROM dbo.tblFaOptionDepr o
		INNER JOIN #PostTransList l ON o.DeprType = l.TransId 
		INNER JOIN dbo.tblFaAssetDepr d ON o.DeprType = d.DeprcType
		INNER JOIN dbo.tblFaAsset a ON d.AssetId = a.AssetID
	WHERE o.[Process] = 1 
		AND (a.[AssetStatus] = 1 OR a.[AssetStatus] = 2)
		AND d.[CurrDepr] <> 0


	--generate the GL log entries
	IF @PostDtlYn = 0
	BEGIN
		--post summary to GL
		INSERT #GlPostLogs(CompId, PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate)
		SELECT @CompId, @PostRun, [FiscalYear], [FiscalPeriod], 10
			, [GlAccumDepr], SUM(-[Amount]), 'FA', 'Accumulated Depreciation'
			, SUM(CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END) --flip debit/credit map for -[Amount]
			, SUM(CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END)
			, SUM(CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END)
			, SUM(CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END)
			, 'FA', @WksDate, @WksDate, @CurrBase, 1.0
		FROM #PeriodDepreciationPostActivity
		WHERE [Type] = 1 --Only 'Book' Types post to GL
		GROUP BY [FiscalYear], [FiscalPeriod], [GLAccumDepr]
		HAVING SUM([Amount]) <> 0

		INSERT #GlPostLogs(CompId, PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate)
		SELECT @CompId, @PostRun, [FiscalYear], [FiscalPeriod], 20
			, [GLExpense], SUM([Amount]), 'FA', 'Depreciation Expense'
			, SUM(CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END)
			, SUM(CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END)
			, SUM(CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END)
			, SUM(CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END)
			, 'FA', @WksDate, @WksDate, @CurrBase, 1.0
		FROM #PeriodDepreciationPostActivity
		WHERE [Type] = 1 --Only 'Book' Types post to GL
		GROUP BY [FiscalYear], [FiscalPeriod], [GLExpense]
		HAVING SUM([Amount]) <> 0
	END
	ELSE
	BEGIN
		--post detail to GL
		INSERT #GlPostLogs(CompId, PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate)
		SELECT @CompId, @PostRun, [FiscalYear], [FiscalPeriod], 10
			, [GlAccumDepr], -[Amount], [AssetId], 'Accumulated Depreciation'
			, CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END --flip debit/credit map for -[Amount]
			, CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END
			, CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END
			, CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END
			, 'FA', @WksDate, @WksDate, @CurrBase, 1.0
		FROM #PeriodDepreciationPostActivity
		WHERE [Type] = 1 --Only 'Book' Types post to GL
			AND [Amount] <> 0

		INSERT #GlPostLogs(CompId, PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate)
		SELECT @CompId, @PostRun, [FiscalYear], [FiscalPeriod], 20
			, [GLExpense], [Amount], [AssetId], 'Depreciation Expense'
			, CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END
			, CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END
			, CASE WHEN [Amount] > 0 THEN [Amount] ELSE 0 END
			, CASE WHEN [Amount] > 0 THEN 0 ELSE -[Amount] END
			, 'FA', @WksDate, @WksDate, @CurrBase, 1.0
		FROM #PeriodDepreciationPostActivity
		WHERE [Type] = 1 --Only 'Book' Types post to GL
			AND [Amount] <> 0
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaPeriodDepreciationPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaPeriodDepreciationPost_BuildLog_proc';

