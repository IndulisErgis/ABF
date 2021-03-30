
CREATE PROCEDURE dbo.trav_PsRewardActivityPost_BuildLog_proc 
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE	@CompId [sysname], @PostRun pPostRun, @PostDtlYn bit, @PrecCurr smallint, @CurrBase pCurrency
		, @WrkStnDate datetime, @SourceCode nvarchar(2), @FiscalYear smallint, @FiscalPeriod smallint

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @SourceCode = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'SourceCode'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'


	IF @PostRun IS NULL OR @PostDtlYn IS NULL OR @CurrBase IS NULL OR @WrkStnDate IS NULL 
		OR @SourceCode IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	--use a temp table to pre-process transactional information
	CREATE TABLE #TransPostLog 
	(
		[ActivityID] [bigint] NOT NULL,
		[Grouping] [smallint] NULL, 
		[TransDate] [datetime] NULL, 
		[Descr] [pDescription] NULL, --cut to 30 for #GlPostLogs
		[Reference] [nvarchar](15) NULL, 
		[GlAcct] [pGlAcct] NULL, 
		[CreditAmount] [pDecimal] NULL, 
		[DebitAmount] [pDecimal] NULL, 
		[LinkID] [nvarchar](255) NULL, 	
	)

	--capture the reward point liability (Credit)
	INSERT INTO #TransPostLog ([ActivityID], [Grouping], [TransDate], [Descr], [Reference]
		, [GlAcct], [CreditAmount], [DebitAmount], [LinkID])
	SELECT l.[ID], 10, a.[TransDate], p.[Description], 'Accrual'
		, a.[LiabilityAccount]
		, CASE WHEN ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) >= 0 THEN ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) ELSE 0 END
		, CASE WHEN ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) < 0 THEN -ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) ELSE 0 END
		, CAST(l.[ID] AS nvarchar(255))
	FROM #ActivityList l
	INNER JOIN dbo.tblPsRewardActivity a on l.[ID] = a.[ID]
	LEFT JOIN dbo.tblPsRewardProgram p on a.[ProgramID] = p.[ID]
	WHERE a.[Type] = 0 --Accruals
		AND a.[PostRun] IS NULL --unposted


	--capture the reward point expense (Debit)
	INSERT INTO #TransPostLog ([ActivityID], [Grouping], [TransDate], [Descr], [Reference]
		, [GlAcct], [CreditAmount], [DebitAmount], [LinkID])
	SELECT l.[ID], 20, a.[TransDate], p.[Description], 'Accrual'
		, a.[GLAccount]
		, CASE WHEN ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) < 0 THEN -ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) ELSE 0 END
		, CASE WHEN ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) >= 0 THEN ROUND(a.[PointValue] * p.[RedemptionRate] / 100.0, @PrecCurr) ELSE 0 END
		, CAST(l.[ID] AS nvarchar(255))
	FROM #ActivityList l
	INNER JOIN dbo.tblPsRewardActivity a on l.[ID] = a.[ID]
	LEFT JOIN dbo.tblPsRewardProgram p on a.[ProgramID] = p.[ID]
	WHERE a.[Type] = 0 --Accruals
		AND a.[PostRun] IS NULL --unposted


	--populate the GL Log table
	IF (@PostDtlYn = 0)
	BEGIN
		--Summarize credit/debit entries separately
		--Credit entry
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, AmountFgn, Reference
			, [Description], DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, SourceCode
			, PostDate, TransDate, CurrencyId, ExchRate, CompId)
		SELECT @PostRun, @FiscalYear, @FiscalPeriod, [Grouping], [GlAcct], -SUM([CreditAmount]), 'PS'
			, CASE WHEN [Grouping] = 10 THEN 'Accrual Liability' WHEN [Grouping] = 20 THEN 'Accrual Expense' ELSE 'Unknown' END
			, 0, SUM([CreditAmount]), 0, SUM([CreditAmount]), @SourceCode
			, @WrkStnDate, @WrkStnDate, @CurrBase, 1.0, @CompId
		FROM #TransPostLog 
		WHERE [CreditAmount] <> 0
		GROUP BY [Grouping], [GlAcct]

		--Debit entry
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, AmountFgn, Reference
			, [Description], DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, SourceCode
			, PostDate, TransDate, CurrencyId, ExchRate, CompId)
		SELECT @PostRun, @FiscalYear, @FiscalPeriod, [Grouping], [GlAcct], SUM([DebitAmount]), 'PS'
			, CASE WHEN [Grouping] = 10 THEN 'Accrual Liability' WHEN [Grouping] = 20 THEN 'Accrual Expense' ELSE 'Unknown' END
			, SUM([DebitAmount]), 0, SUM([DebitAmount]), 0, @SourceCode
			, @WrkStnDate, @WrkStnDate, @CurrBase, 1.0, @CompId
		FROM #TransPostLog 
		WHERE [DebitAmount] <> 0
		GROUP BY [Grouping], [GlAcct]
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, AmountFgn, Reference, [Description], DebitAmount, CreditAmount, 
			DebitAmountFgn, CreditAmountFgn, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT @PostRun, @FiscalYear, @FiscalPeriod, [Grouping], [GlAcct], ([DebitAmount] - [CreditAmount])
			, [Reference], LEFT([Descr], 30), [DebitAmount], [CreditAmount], [DebitAmount], [CreditAmount]
			, @SourceCode, @WrkStnDate, [TransDate], @CurrBase, 1.0, @CompId, [LinkID], NULL, NULL
		FROM #TransPostLog 
		WHERE [CreditAmount] <> 0 OR [DebitAmount] <> 0
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPost_BuildLog_proc';

