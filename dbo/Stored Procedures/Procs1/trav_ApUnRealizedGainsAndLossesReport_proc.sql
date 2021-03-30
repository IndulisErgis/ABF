
CREATE PROCEDURE dbo.trav_ApUnRealizedGainsAndLossesReport_proc
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

	CREATE TABLE #tmpApUnrealGainsLossrpt
	(
		VendorId pVendorId NULL, 
		[Status] tinyint NULL DEFAULT (0), 
		InvoiceDate datetime NULL, 
		InvoiceNum pInvoiceNum NULL, 
		CurrencyId pCurrency NULL, 
		PmtCurrencyId pCurrency NULL, 
		GrossAmtDuefgn pDecimal NULL DEFAULT (0), 
		GrossAmtDueInv pDecimal NULL DEFAULT (0), 
		PmtExchRate pDecimal NULL DEFAULT (1), 
		ExchRate pDecimal NULL DEFAULT (1), 
		GrossAmtDue pDecimal NULL DEFAULT (0), 
		GLAccGainLoss pGlAcct NULL, 
		CalcGainLoss pDecimal NULL DEFAULT (0), 
		GlPeriod smallint, FiscalYear smallint,  
		CurrBase pCurrency NULL
	)

	INSERT INTO #tmpGainLossAcct (CurrencyID, GainAcct, LossAcct) 
	SELECT t.CurrencyId,ISNULL(g.GlAcctUnrealGain,(SELECT  GlAcctUnrealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')),
		ISNULL(g.GlAcctUnrealLoss,(SELECT GlAcctUnrealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
	FROM #tmpCurrencyList t	LEFT JOIN dbo.tblSmGainLossAccount g ON t.CurrencyId = g.CurrencyID

	INSERT INTO #tmpApUnrealGainsLossrpt
		SELECT i.VendorId, i.Status, i.InvoiceDate, i.InvoiceNum, i.CurrencyId, e.CurrencyTo, 
		(i.GrossAmtDueFgn) AS GrossAmtDue, ROUND(((i.GrossAmtDueFgn)/ISNULL(e.ExchRate,1)), @BaseCurrencyPrecision) AS GrossAmtDueInv,
		ISNULL(e.ExchRate,1) PmtExchRate, i.ExchRate, (i.GrossAmtDue) AS GrossAmtDue,
		CASE WHEN ((((i.GrossAmtDueFgn-i.DiscAmtFgn)/ISNULL(e.ExchRate,1)) - (i.GrossAmtDue-i.DiscAmt)) < 0) 
		THEN g.GainAcct ELSE g.LossAcct END AS GLAccGainLoss, 
		-Round(((i.GrossAmtDueFgn)/ISNULL(e.ExchRate,1))  - (i.GrossAmtDue), @BaseCurrencyPrecision) AS CalcGainLoss,	
		i.GlPeriod, i.FiscalYear, @BaseCurrency
	FROM dbo.tblApOpenInvoice i	INNER JOIN #tmpGainLossAcct g ON i.CurrencyId = g.CurrencyId
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.CurrencyID <> @BaseCurrency AND i.Status NOT IN(3,4) 
		AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod))
		AND i.ExchRate <> ISNULL(e.ExchRate,1) 
		AND ((i.DistCode NOT IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @BaseCurrency)  
		AND i.CurrencyId <> e.CurrencyTo )
		OR (i.DistCode IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @BaseCurrency)))

	SELECT * FROM #tmpApUnrealGainsLossrpt

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesReport_proc';

