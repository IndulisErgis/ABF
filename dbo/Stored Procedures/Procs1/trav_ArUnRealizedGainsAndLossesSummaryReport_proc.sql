
CREATE PROCEDURE dbo.trav_ArUnRealizedGainsAndLossesSummaryReport_proc
@FiscalYear Smallint = 2008,
@GlPeriod Smallint = 12,
@BaseCurrency pCurrency = 'USD',
@BaseCurrencyPrecision Tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpUnrealGainLoss 
	(
		GLAcct pGlAcct NOT NULL ,
		Amt pDecimal NOT NULL
	)

	INSERT INTO #tmpUnrealGainLoss(GLAcct,Amt)
	SELECT CASE WHEN ROUND((AmtFgn - ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0))/ISNULL(e.ExchRate,1),CAST(@BaseCurrencyPrecision AS INT)) -
		ROUND((AmtFgn - ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0))/i.ExchRate,CAST(@BaseCurrencyPrecision AS INT)) > 0 THEN t.GainAcct ELSE t.LossAcct END GainLossAcct,
		ROUND((AmtFgn - ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0))/ISNULL(e.ExchRate,1),CAST(@BaseCurrencyPrecision AS INT)) -
		Round((Amt - ISNULL((SELECT SUM(Amt) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0)),CAST(@BaseCurrencyPrecision AS INT)) GainLossAmt
	FROM dbo.tblArOpenInvoice i INNER JOIN #tmpCurrencyList c ON i.CurrencyId = c.CurrencyId
		INNER JOIN dbo.tblArDistCode d ON i.DistCode = d.DistCode
		INNER JOIN dbo.tblGlAcctHdr h ON d.GLAcctReceivables = h.AcctId 
		INNER JOIN (SELECT c.CurrencyId,ISNULL(g.GlAcctUnrealGain,(SELECT GlAcctUnrealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')) AS GainAcct,
			ISNULL(g.GlAcctUnrealLoss,(SELECT GlAcctUnrealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')) AS LossAcct
			FROM #tmpCurrencyList c LEFT JOIN dbo.tblSmGainLossAccount g ON c.CurrencyId = g.CurrencyID) t ON i.CurrencyID = t.CurrencyId 
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.Currencyid <> @BaseCurrency AND h.CurrencyId = @BaseCurrency AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod))
		AND i.Status <> 4 AND i.RecType > 0 AND AmtFgn > ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0) 
		AND i.ExchRate <> ISNULL(e.ExchRate,1) 
	UNION ALL
	SELECT d.GLAcctReceivables,
		-(ROUND((AmtFgn - ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0))/ISNULL(e.ExchRate,1),CAST(@BaseCurrencyPrecision AS INT)) -
		Round((Amt - ISNULL((SELECT SUM(Amt) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0)),CAST(@BaseCurrencyPrecision AS INT))) GainLossAmt
	FROM dbo.tblArOpenInvoice i INNER JOIN #tmpCurrencyList c ON i.CurrencyId = c.CurrencyId
		INNER JOIN dbo.tblArDistCode d ON i.DistCode = d.DistCode
		INNER JOIN dbo.tblGlAcctHdr h ON d.GLAcctReceivables = h.AcctId 
		INNER JOIN (SELECT c.CurrencyId,ISNULL(g.GlAcctUnrealGain,(SELECT GlAcctUnrealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')) AS GainAcct,
			ISNULL(g.GlAcctUnrealLoss,(SELECT GlAcctUnrealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')) AS LossAcct
			FROM #tmpCurrencyList c LEFT JOIN dbo.tblSmGainLossAccount g ON c.CurrencyId = g.CurrencyID) t ON i.CurrencyID = t.CurrencyId 
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.Currencyid <> @BaseCurrency AND h.CurrencyId = @BaseCurrency AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod))
		AND i.Status <> 4 AND i.RecType > 0 AND AmtFgn > ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0) 
		AND i.ExchRate <> ISNULL(e.ExchRate,1) 

	SELECT GlAcct, CASE WHEN SUM(Amt) > 0 THEN SUM(Amt) ELSE 0 END CreditAmt, 
		CASE WHEN SUM(Amt) < 0 THEN ABS(SUM(Amt)) ELSE 0 END DebitAmt
	FROM #tmpUnrealGainLoss 
	GROUP BY GlAcct

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUnRealizedGainsAndLossesSummaryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUnRealizedGainsAndLossesSummaryReport_proc';

