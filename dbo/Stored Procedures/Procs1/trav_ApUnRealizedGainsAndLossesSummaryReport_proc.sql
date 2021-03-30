
CREATE PROCEDURE dbo.trav_ApUnRealizedGainsAndLossesSummaryReport_proc
@FiscalYear Smallint = 2008,
@GlPeriod Smallint = 12,
@BaseCurrency pCurrency = 'USD',
@BaseCurrencyPrecision Tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpGainLossAcct 
	(
		CurrencyID pCurrency NOT NULL,
		GainAcct pGlAcct NOT NULL,
		LossAcct pGlAcct NOT NULL
	)

	CREATE TABLE #tmpUnrealGainLoss 
	(
		GainLossAcct pGlAcct NOT NULL ,
		GainLossAmt pDecimal NULL default (0)
	)

	INSERT INTO #tmpGainLossAcct (CurrencyID, GainAcct, LossAcct) 
	SELECT t.CurrencyId,ISNULL(g.GlAcctUnrealGain,(SELECT  GlAcctUnrealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')),
		ISNULL(g.GlAcctUnrealLoss,(SELECT GlAcctUnrealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
	FROM #tmpCurrencyList t	LEFT JOIN dbo.tblSmGainLossAccount g ON t.CurrencyId = g.CurrencyID

	INSERT INTO #tmpUnrealGainLoss(GainLossAcct, GainLossAmt)
	SELECT CASE WHEN ((SUM((i.GrossAmtDueFgn-i.DiscAmtFgn)/ ISNULL(e.ExchRate,1)) - SUM(i.GrossAmtDue - i.DiscAmt)) < 0) THEN g.GainAcct ELSE g.LossAcct END,
		CASE WHEN ((SUM((i.GrossAmtDueFgn)/ ISNULL(e.ExchRate,1)) - SUM(i.GrossAmtDue )) > 0) THEN
		ROUND((SUM(ROUND(((i.GrossAmtDueFgn)/ ISNULL(e.ExchRate,1)), @BaseCurrencyPrecision)) - SUM(i.GrossAmtDue)), @BaseCurrencyPrecision)
		ELSE ROUND((SUM(ROUND(((i.GrossAmtDueFgn)/ ISNULL(e.ExchRate,1)), @BaseCurrencyPrecision)) - SUM(i.GrossAmtDue)), @BaseCurrencyPrecision) END
	FROM dbo.tblApOpenInvoice i	INNER Join #tmpGainLossAcct g ON i.CurrencyId = g.CurrencyId
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.CurrencyID <> @BaseCurrency
		AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod))
		AND i.Status NOT IN(3,4) 
		AND i.ExchRate <> ISNULL(e.ExchRate,1) 
		AND ((i.DistCode NOT IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @BaseCurrency)  
		AND i.CurrencyId <> e.CurrencyTo )
		OR (i.DistCode in (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @BaseCurrency)))
	GROUP BY i.CurrencyId, i.DistCode, i.vendorId, g.GainAcct, e.ExchRate, g.LossAcct

	INSERT INTO #tmpUnrealGainLoss(	GainLossAcct,  GainLossAmt)
	SELECT g.AcctId,
		CASE WHEN ((SUM((i.GrossAmtDueFgn)/ ISNULL(e.ExchRate,1) ) - SUM(i.GrossAmtDue)) > 0) THEN
		-ROUND((SUM(ROUND(((i.GrossAmtDueFgn)/ ISNULL(e.ExchRate,1) ), @BaseCurrencyPrecision)) - SUM(i.GrossAmtDue)), @BaseCurrencyPrecision)
		ELSE -ROUND((SUM(ROUND(((i.GrossAmtDueFgn)/ ISNULL(e.ExchRate,1) ), @BaseCurrencyPrecision)) - SUM(i.GrossAmtDue)), @BaseCurrencyPrecision) END
	FROM dbo.tblApOpenInvoice i	INNER JOIN tblApDistCode d ON i.DistCode = d.DistCode 
		INNER Join tblGlAcctHdr g ON d.PayablesGLAcct =  g.AcctId 
		INNER JOIN #tmpCurrencyList t ON i.CurrencyID = t.CurrencyId 
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.CurrencyID <> @BaseCurrency
		AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod))
		AND i.Status NOT IN(3,4) 
		AND i.ExchRate <> ISNULL(e.ExchRate,1) 
		AND ((i.DistCode NOT IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @BaseCurrency)  
		AND i.CurrencyId <> e.CurrencyTo )
		OR (i.DistCode in (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @BaseCurrency)))
	GROUP BY g.AcctId,i.CurrencyId, i.DistCode, i.vendorId, g.AcctId, e.ExchRate 

	SELECT GainLossAcct AS GLAcct, CASE WHEN CAST(SUM(GainLossAmt)AS FLOAT) > 0 THEN CAST(SUM(GainLossAmt)AS FLOAT) ELSE 0 END DebitAmt, 
		CASE WHEN SUM(GainLossAmt) < 0 THEN ABS(CAST(SUM(GainLossAmt)AS FLOAT)) ELSE 0 END CreditAmt
	FROM #tmpUnrealGainLoss 
	GROUP BY GainLossAcct 
	ORDER BY GainLossAcct

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesSummaryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesSummaryReport_proc';

