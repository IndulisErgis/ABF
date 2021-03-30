
CREATE PROCEDURE dbo.trav_ApUnRealizedGainsAndLossesPost_GlLog_proc
AS
BEGIN TRY

	DECLARE @FiscalYear smallint, @GlPeriod smallint, @ReversePeriod smallint, @ReverseYear smallint, @CurrBase pCurrency,
		@PostRun pPostRun, @PostGainLossDtl bit, @TransDate datetime, @WksDate datetime, @CompId nvarchar(3)

	SELECT @FiscalYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @GlPeriod = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod'
	SELECT @ReverseYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'ReverseYear'
	SELECT @ReversePeriod = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'ReversePeriod'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PostGainLossDtl = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostGainLossDtl'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @TransDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'TransDate'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate'

	IF @FiscalYear IS NULL OR @GlPeriod IS NULL OR @CurrBase IS NULL OR @PostRun IS NULL OR @PostGainLossDtl IS NULL 
		OR @ReverseYear IS NULL OR @ReversePeriod IS NULL OR @CompId IS NULL OR @TransDate IS NULL OR @WksDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	IF @PostGainLossDtl = 1
		INSERT INTO #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,LinkIDSubLine,URG)
		SELECT @PostRun, @FiscalYear, @GlPeriod,100, AcctId, ABS(DebitAmt) - ABS(CreditAmt), 'AP', 'Unrealized Gains/Losses', ABS(DebitAmt),
			ABS(CreditAmt), ABS(DebitAmt), ABS(CreditAmt), 'G1', @WksDate, @TransDate, @CurrBase, 1, @CompId,-4,1
		FROM #tmpUnrealGainLoss 
	ELSE
		INSERT INTO #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,LinkIDSubLine,URG)
		SELECT @PostRun, @FiscalYear, @GlPeriod,100, AcctId, SUM(DebitAmt) - SUM(CreditAmt), 'AP', 'Unrealized Gains/Losses', 
			CASE WHEN SUM(DebitAmt) - SUM(CreditAmt) > 0 THEN SUM(DebitAmt) - SUM(CreditAmt) ELSE 0 END,
			CASE WHEN SUM(DebitAmt) - SUM(CreditAmt) > 0 THEN 0 ELSE ABS(SUM(DebitAmt) - SUM(CreditAmt)) END,
			CASE WHEN SUM(DebitAmt) - SUM(CreditAmt) > 0 THEN SUM(DebitAmt) - SUM(CreditAmt) ELSE 0 END,
			CASE WHEN SUM(DebitAmt) - SUM(CreditAmt) > 0 THEN 0 ELSE ABS(SUM(DebitAmt) - SUM(CreditAmt)) END,			
			'G1', @WksDate, @TransDate, @CurrBase, 1, @CompId,-4,1
		FROM #tmpUnrealGainLoss 
		GROUP BY AcctId

	--reverse entry in next period 
	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,LinkIDSubLine,URG)
	SELECT PostRun,@ReverseYear,@ReversePeriod,200,GlAccount,-AmountFgn,Reference,'Unrealized Gains/Losses Rev',CreditAmount,
		DebitAmount,CreditAmountFgn,DebitAmountFgn,'G2',PostDate,TransDate,CurrencyId,ExchRate,CompId,LinkIDSubLine,URG
	FROM #GlPostLogs

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesPost_GlLog_proc';

