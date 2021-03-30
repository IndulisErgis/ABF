
CREATE PROCEDURE dbo.trav_GlUnrealizedGainLossPost_Update_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @CompID [sysname]
	DECLARE @PostRun pPostRun
	DECLARE @FiscalYear smallint, @FiscalPeriod smallint
	DECLARE @ReversalPeriod smallint, @ReversalYear smallint
	DECLARE @TransDate datetime, @WksDate datetime
	DECLARE @BaseCurrency pCurrency, @PrecCurr tinyint, @PostGainLossDtl bit

	--Retrieve global values
	SELECT @CompID = DB_Name();
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @ReversalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'ReversalYear'
	SELECT @ReversalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'ReversalPeriod'
	SELECT @TransDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'TransDate'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @BaseCurrency = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'BaseCurrency'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BaseCurrencyPrec'
	SELECT @PostGainLossDtl = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostGainLossDtl'

	IF @CompID IS NULL OR @PostRun IS NULL 
		OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL 
		OR @ReversalPeriod IS NULL OR @ReversalYear IS NULL 
		OR @TransDate IS NULL OR @WksDate IS NULL 
		OR @BaseCurrency IS NULL OR @PrecCurr IS NULL OR @PostGainLossDtl IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--reversing entries must be made in the next period
	IF NOT((@FiscalYear = @ReversalYear AND @FiscalPeriod < @ReversalPeriod) OR (@FiscalYear < @ReversalYear AND @ReversalPeriod = 1))
	BEGIN
		RAISERROR('Invalid reversing period/year values.',16,1)
	END

	-- check the function flag (exit if already done)
	IF (SELECT Count(*) FROM dbo.tblSmFunctionFlag WHERE FunctionID = 'GlUnReGnLs' AND GlYear = @FiscalYear AND Period = @FiscalPeriod) > 0
	BEGIN
		DECLARE @msg nvarchar(255)
		SELECT @msg = 'Post has been done for ' + CAST(@FiscalYear AS nvarchar) + '/' + CAST(@FiscalPeriod AS nvarchar)
		RAISERROR(@msg, 16, 1)
	END

	CREATE TABLE #GainLossAccounts 
	(
		CurrencyId pCurrency NOT NULL, 
		UnrealGainAcct pGlAcct NOT NULL, 
		UnrealLossAcct pGlAcct NOT NULL, 
		Prec tinyint NOT NULL
	)

	CREATE TABLE #UnrealGainLoss 
	(
		AcctID pGlAcct NOT NULL,
		AcctCurrencyID pCurrency NOT NULL,
		AcctExchRate pDecimal NULL,
		URGAcctID pGlAcct NULL,
		URGCurrencyID pCurrency NULL,
		URGExchRate pDecimal NULL,
		URGBalance pCurrDecimal NULL,
		URGBaseBalance pCurrDecimal NULL,
		PRIMARY KEY (AcctID)
	)

	-- capture the list of gain/loss accounts for the available currency ids
	INSERT INTO #GainLossAccounts (CurrencyId, Prec, UnrealGainAcct, UnrealLossAcct)
	SELECT c.CurrencyId, c.Prec
		, ISNULL(g.GlAcctUnrealGain, (SELECT GlAcctUnrealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
		, ISNULL(g.GlAcctUnrealLoss, (SELECT GlAcctUnrealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
	FROM #CurrencyInfo c 
	LEFT JOIN dbo.tblSmGainLossAccount g ON c.CurrencyId = g.CurrencyId

	-- Summarize and compare the current account currency value in base to the original base value to calculate the Base currency URG amount
	--	(Original Acct Currency / Period Exchange from Base) - Original Base Currency = URG Adjustment in Base
	--	non-base curreny transactions as of the period being processed 
	--	that have been posted
	--*Applies rounding to to summarized account totals to reduce the possible rounding variance in the summarized entries
	INSERT INTO #UnrealGainLoss(AcctId, AcctCurrencyId, AcctExchRate, URGBaseBalance)
		SELECT j.AcctId, j.CurrencyId, e.ExchRate
			, ROUND(SUM(((j.DebitAmtFgn - j.CreditAmtFgn) / e.ExchRate)), @PrecCurr) - SUM(j.DebitAmt - j.CreditAmt)
		FROM dbo.tblGlJrnl j 
			INNER JOIN dbo.tblGlAcctHdr h ON j.AcctId = h.AcctId 
			INNER JOIN dbo.tblGlAcctType t ON h.AcctTypeId = t.AcctTypeId 
			LEFT JOIN #ExchRatePd e ON j.CurrencyID = e.CurrencyTo 
		WHERE j.CurrencyID <> @BaseCurrency AND (j.[Year] < @FiscalYear OR (j.[Year] = @FiscalYear AND j.Period <= @FiscalPeriod)) 
			AND j.PostedYn <> 0 AND t.AcctClassId IN (115, 200) 
		GROUP BY j.AcctId, j.CurrencyID, e.ExchRate
		HAVING (ROUND(SUM(((j.DebitAmtFgn - j.CreditAmtFgn) / e.ExchRate)), @PrecCurr) - SUM(j.DebitAmt - j.CreditAmt)) <> 0 --Exclude accounts that do not need a URG adjustment

	--Update net gains (Retrieve the URGAcctID, CurrencyID, ExchRate and Calculate the URGBalance in URGAccount Currency)
	--	Standard: URG Accounts are required to be BASE currency
	UPDATE #UnrealGainLoss
		SET URGAcctId = ci.UnrealGainAcct
			, URGCurrencyID = acct.CurrencyID 
			, URGExchRate = 1
			, URGBalance = t.URGBaseBalance
		FROM #UnrealGainLoss t
		INNER JOIN #GainLossAccounts ci ON t.AcctCurrencyID = ci.CurrencyID --Gain acct from GainLossAccounts
		INNER JOIN dbo.tblGlAcctHdr acct ON ci.UnrealGainAcct = acct.AcctId --Gain acct currency from AcctHdr
		WHERE t.URGBaseBalance > 0

	--Update net losses (Retrieve the URGAcctID, CurrencyID, ExchRate and Calculate the URGBalance in URGAccount Currency)
	--	Standard: URG Accounts are required to be BASE currency
	UPDATE #UnrealGainLoss
		SET URGAcctId = ci.UnrealLossAcct
			, URGCurrencyID = acct.CurrencyID 
			, URGExchRate = 1
			, URGBalance = t.URGBaseBalance
		FROM #UnrealGainLoss t
		INNER JOIN #GainLossAccounts ci ON t.AcctCurrencyID = ci.CurrencyID --Gain acct from GainLossAccounts
		INNER JOIN dbo.tblGlAcctHdr acct ON ci.UnrealLossAcct = acct.AcctId --Loss acct currency from AcctHdr
		WHERE t.URGBaseBalance <= 0


	--conditionally summarize the gain/loss entries to be created
	IF @PostGainLossDtl = 1
	BEGIN
		--URGAccount entries
		INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode]
			, [Reference], [FiscalYear], [FiscalPeriod], [PostRun]
			, [DebitAmount], [CreditAmount], [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
			, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
		SELECT [URGAcctID], @TransDate, 'Unrealized Gains/Losses', 'G1'
			, [AcctCurrencyID], @FiscalYear, @FiscalPeriod, @PostRun
			, CASE WHEN [URGBaseBalance] < 0 THEN -[URGBaseBalance] ELSE 0 END
			, CASE WHEN [URGBaseBalance] > 0 THEN [URGBaseBalance] ELSE 0 END
			, CASE WHEN [URGBalance] < 0 THEN -[URGBalance] ELSE 0 END
			, CASE WHEN [URGBalance] > 0 THEN [URGBalance] ELSE 0 END
			, [URGCurrencyID], [URGExchRate]
			, @CompID, @WksDate, -4, 1, 100, [URGBalance]
		FROM #UnrealGainLoss
	END
	ELSE
	BEGIN
		--URGAccount entries
		INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode]
			, [Reference], [FiscalYear], [FiscalPeriod], [PostRun]
			, [DebitAmount], [CreditAmount], [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
			, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
		SELECT [URGAcctID], @TransDate, 'Unrealized Gains/Losses', 'G1'
			, [AcctCurrencyID], @FiscalYear, @FiscalPeriod, @PostRun
			, CASE WHEN SUM([URGBaseBalance]) < 0 THEN -SUM([URGBaseBalance]) ELSE 0 END
			, CASE WHEN SUM([URGBaseBalance]) > 0 THEN SUM([URGBaseBalance]) ELSE 0 END
			, CASE WHEN SUM([URGBalance]) < 0 THEN -SUM([URGBalance]) ELSE 0 END
			, CASE WHEN SUM([URGBalance]) > 0 THEN SUM([URGBalance]) ELSE 0 END
			, [URGCurrencyID], [URGExchRate]
			, @CompID, @WksDate, -4, 1, 100, SUM([URGBalance])
		FROM #UnrealGainLoss
		GROUP BY [URGAcctID], [URGCurrencyID], [AcctCurrencyID], [URGExchRate]
		HAVING SUM([URGBaseBalance]) <> 0 OR SUM([URGBalance]) <> 0
	END

	--Account Adjustments (already summarized by AcctID)
	INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode]
		, [Reference], [FiscalYear], [FiscalPeriod], [PostRun]
		, [DebitAmount], [CreditAmount], [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
		, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
	SELECT [AcctID], @TransDate, 'Unrealized Gains/Losses', 'G1'
		, [AcctCurrencyID], @FiscalYear, @FiscalPeriod, @PostRun
		, CASE WHEN [URGBaseBalance] > 0 THEN [URGBaseBalance] ELSE 0 END
		, CASE WHEN [URGBaseBalance] < 0 THEN -[URGBaseBalance] ELSE 0 END
		, 0
		, 0
		, [AcctCurrencyID], [AcctExchRate]
		, @CompID, @WksDate, -4, 1, 100, 0
	FROM #UnrealGainLoss


	-- reverse all the entries in next period
	INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode], [Reference]
		, [DebitAmount], [CreditAmount], [FiscalYear], [FiscalPeriod]
		, [PostRun], [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
		, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
	SELECT [GlAccount], [TransDate], 'Unrealized Gains/Losses Rev', 'G2', [Reference]
		, [CreditAmount], [DebitAmount], @ReversalYear, @ReversalPeriod
		, @PostRun, [CreditAmountFgn], [DebitAmountFgn], [CurrencyId], [ExchRate]
		, [CompId], [PostDate], [LinkIdSubLine], [URG], 200, [AmountFgn]
	FROM #GlPostLogs


	-- set the function flag
	INSERT INTO dbo.tblSmFunctionFlag (FunctionID, GlYear, Period)
	VALUES ('GlUnReGnLs', @FiscalYear, @FiscalPeriod)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlUnrealizedGainLossPost_Update_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlUnrealizedGainLossPost_Update_proc';

