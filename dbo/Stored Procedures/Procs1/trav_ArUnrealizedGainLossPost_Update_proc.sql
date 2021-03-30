
CREATE PROCEDURE dbo.trav_ArUnrealizedGainLossPost_Update_proc
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
	IF (SELECT Count(*) FROM dbo.tblSmFunctionFlag WHERE FunctionID = 'ArUnReGnLs' AND GlYear = @FiscalYear AND Period = @FiscalPeriod) > 0
	BEGIN
		DECLARE @msg nvarchar(255)
		SELECT @msg = 'Post has been done for ' + CAST(@FiscalYear AS nvarchar) + '/' + CAST(@FiscalPeriod AS nvarchar)
		RAISERROR(@msg, 16, 1)
	END

	CREATE TABLE #UnrealGainLoss 
	(
		CurrencyId pCurrency NOT NULL, 
		AcctAR pGlAcct NOT NULL, 
		GainLossAmt pDecimal NOT NULL
	)

	CREATE TABLE #Invoices
	(
		CustId pCustId NOT NULL, 
		CurrencyID pCurrency NOT NULL, 
		ExchRate pDecimal NOT NULL, 
		AmtDue pDecimal NOT NULL, 
		AmtDueBase pDecimal NOT NULL, 
		AcctAR pGlAcct NOT NULL
	)

	/* build a list of GL accounts for which unrealized gains / losses will not be processed */
	CREATE TABLE #GainLossAccounts 
	(
		CurrencyId pCurrency NOT NULL, 
		UnrealGainAcct pGlAcct NOT NULL, 
		UnrealLossAcct pGlAcct NOT NULL
	)

	-- capture the list of gain/loss accounts for the available currency ids
	INSERT INTO #GainLossAccounts (CurrencyId, UnrealGainAcct, UnrealLossAcct)
	SELECT c.CurrencyId
		, ISNULL(g.GlAcctUnrealGain, (SELECT GlAcctUnrealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
		, ISNULL(g.GlAcctUnrealLoss, (SELECT GlAcctUnrealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
	FROM #CurrencyInfo c 
	LEFT JOIN dbo.tblSmGainLossAccount g ON c.CurrencyId = g.CurrencyId


	-- build a list of open invoices
	INSERT INTO #Invoices ( CustId, CurrencyId, ExchRate, AmtDue, AmtDueBase, AcctAR )
	SELECT i.CustId, i.CurrencyId, i.ExchRate
		, AmtFgn - ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0), 0) AS AmtDue
		, Amt - ISNULL((SELECT SUM(Amt) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0), 0) AS AmtDueBase
		, d.GLAcctReceivables
	FROM dbo.tblArOpenInvoice i 
	INNER JOIN dbo.tblArDistCode d ON i.DistCode = d.DistCode
	INNER JOIN dbo.tblGlAcctHdr h ON d.GLAcctReceivables = h.AcctId 
	WHERE i.Currencyid <> @BaseCurrency AND h.CurrencyId = @BaseCurrency 
		AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @FiscalPeriod))
		AND i.[Status] <> 4 AND i.RecType > 0 
		AND AmtFgn > ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0), 0)


	-- calculate the gain/loss amount
	INSERT INTO #UnrealGainLoss(CurrencyId, AcctAR, GainLossAmt)
	SELECT j.CurrencyID, AcctAR, ROUND(j.AmtDue / ISNULL(e.ExchRate, 1), @Preccurr) - j.AmtDueBase
	FROM #Invoices j 
	LEFT JOIN #ExchRatePd e ON j.CurrencyID = e.CurrencyTo 
	WHERE j.ExchRate <> ISNULL(e.ExchRate, 1) 


	--conditionally summarize the gain/loss entries to be created
	IF @PostGainLossDtl = 1
	BEGIN
		INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode], [Reference]
			, [DebitAmount], [CreditAmount], [FiscalYear], [FiscalPeriod], [PostRun]
			, [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
			, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
		SELECT CASE WHEN GainLossAmt > 0 THEN a.UnrealGainAcct ELSE a.UnrealLossAcct END
			, @TransDate, 'Unrealized Gains/Losses', 'G1', 'AR'
			, CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END
			, CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END
			, @FiscalYear, @FiscalPeriod, @PostRun
			, CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END
			, CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END
			, @BaseCurrency, 1.0
			, @CompId, @WksDate, -4, 1, 100, -GainLossAmt
		FROM #UnrealGainLoss t INNER JOIN #GainLossAccounts a ON t.CurrencyID = a.CurrencyID 

		INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode], [Reference]
			, [DebitAmount], [CreditAmount], [FiscalYear], [FiscalPeriod], [PostRun]
			, [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
			, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
		SELECT AcctAR, @TransDate, 'Unrealized Gains/Losses', 'G1', 'AR'
			, CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END
			, CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END
			, @FiscalYear, @FiscalPeriod, @PostRun
			, CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END
			, CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END
			, @BaseCurrency, 1.0
			, @CompId, @WksDate, -4, 1, 100, GainLossAmt
		FROM #UnrealGainLoss t INNER JOIN #GainLossAccounts a ON t.CurrencyID = a.CurrencyID 
	END
	ELSE
	BEGIN
		INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode], [Reference]
			, [DebitAmount], [CreditAmount], [FiscalYear], [FiscalPeriod], [PostRun]
			, [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
			, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
		SELECT CASE WHEN GainLossAmt > 0 THEN a.UnrealGainAcct ELSE a.UnrealLossAcct END
			, @TransDate, 'Unrealized Gains/Losses', 'G1', 'AR'
			, SUM(CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END)
			, SUM(CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END)
			, @FiscalYear, @FiscalPeriod, @PostRun
			, SUM(CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END)
			, SUM(CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END)
			, @BaseCurrency, 1.0
			, @CompId, @WksDate, -4, 1, 100, SUM(-GainLossAmt)
		FROM #UnrealGainLoss t INNER JOIN #GainLossAccounts a ON t.CurrencyID = a.CurrencyID 
		GROUP BY CASE WHEN GainLossAmt > 0 THEN a.UnrealGainAcct ELSE a.UnrealLossAcct END

		INSERT INTO #GlPostLogs ([GlAccount], [TransDate], [Description], [SourceCode], [Reference]
			, [DebitAmount], [CreditAmount], [FiscalYear], [FiscalPeriod], [PostRun]
			, [DebitAmountFgn], [CreditAmountFgn], [CurrencyId], [ExchRate]
			, [CompId], [PostDate], [LinkIdSubLine], [URG], [Grouping], [AmountFgn])
		SELECT AcctAR, @TransDate, 'Unrealized Gains/Losses', 'G1', 'AR'
			, SUM(CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END)
			, SUM(CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END)
			, @FiscalYear, @FiscalPeriod, @PostRun
			, SUM(CASE WHEN GainLossAmt > 0 THEN GainLossAmt ELSE 0 END)
			, SUM(CASE WHEN GainLossAmt > 0 THEN 0 ELSE ABS(GainLossAmt) END)
			, @BaseCurrency, 1.0
			, @CompId, @WksDate, -4, 1, 100, SUM(GainLossAmt)
		FROM #UnrealGainLoss t INNER JOIN #GainLossAccounts a ON t.CurrencyID = a.CurrencyID 
		GROUP BY AcctAR
	END


	-- reverse then entries in next period
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
	VALUES ('ArUnReGnLs', @FiscalYear, @FiscalPeriod)


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUnrealizedGainLossPost_Update_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUnrealizedGainLossPost_Update_proc';

