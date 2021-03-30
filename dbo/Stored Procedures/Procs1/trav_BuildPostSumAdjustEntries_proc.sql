
CREATE PROCEDURE dbo.trav_BuildPostSumAdjustEntries_proc
AS 
BEGIN TRY

		SELECT PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,SUM(DebitAmountFgn) - SUM(CreditAmountFgn) AS AmountFgn,
			Reference, CASE [Grouping] WHEN 500 THEN 'Sum COGS Adjustment' ELSE 'Sum Purchase Price Variance' END AS [Description], 
			CASE WHEN SUM(DebitAmount) - SUM(CreditAmount) > 0 THEN SUM(DebitAmount) - SUM(CreditAmount) ELSE 0 END AS DebitAmount,
			CASE WHEN SUM(DebitAmount) - SUM(CreditAmount) > 0 THEN 0 ELSE ABS(SUM(DebitAmount) - SUM(CreditAmount)) END AS CreditAmount,
			CASE WHEN SUM(DebitAmountFgn) - SUM(CreditAmountFgn) > 0 THEN SUM(DebitAmountFgn) - SUM(CreditAmountFgn) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN SUM(DebitAmountFgn) - SUM(CreditAmountFgn) > 0 THEN 0 ELSE ABS(SUM(DebitAmountFgn) - SUM(CreditAmountFgn)) END AS CreditAmountFgn,
			SourceCode, PostDate, MIN(TransDate) AS TransDate,CurrencyId,ExchRate,CompId
		INTO #GlPostLogsSum 
		FROM #GlPostLogs 
		WHERE [Grouping] IN (500,501) 
		GROUP BY PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,Reference,SourceCode,PostDate,CurrencyId,ExchRate,CompId
		
		DELETE #GlPostLogs WHERE [Grouping] IN (500,501) 
		
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId
		FROM #GlPostLogsSum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BuildPostSumAdjustEntries_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BuildPostSumAdjustEntries_proc';

