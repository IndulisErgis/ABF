
CREATE PROCEDURE dbo.trav_ApUnRealizedGainsAndLossesPost_Calculate_proc
AS
BEGIN TRY

	DECLARE @FiscalYear smallint, @GlPeriod smallint, @ReversePeriod smallint, @ReverseYear smallint, @CurrBase pCurrency, @PrecCurr tinyint

	SELECT @FiscalYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @GlPeriod = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod'
	SELECT @ReverseYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'ReverseYear'
	SELECT @ReversePeriod = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'ReversePeriod'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @FiscalYear IS NULL OR @GlPeriod IS NULL OR @CurrBase IS NULL
		OR @ReverseYear IS NULL OR @ReversePeriod IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO #tmpUnrealGainLoss (AcctId, DebitAmt, CreditAmt) 
	SELECT CASE WHEN ((SUM((i.GrossAmtDueFgn - i.DiscAmtFgn) / ISNULL(e.ExchRate, 1)) - SUM(i.GrossAmtDue - i.DiscAmt)) < 0) 
		THEN g.GainAcct ELSE g.LossAcct END
		, CASE WHEN ((SUM((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)) - SUM(i.GrossAmtDue)) > 0) 
			THEN ROUND((SUM(ROUND(((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)), @PrecCurr)) - SUM(i.GrossAmtDue)), @PrecCurr) 
			ELSE 0 END
		, CASE WHEN ((SUM((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)) - SUM(i.GrossAmtDue)) < 0) 
			THEN ROUND ((SUM(ROUND(((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)), @PrecCurr)) - SUM(i.GrossAmtDue)), @PrecCurr) 
			ELSE 0 END 
	FROM dbo.tblApOpenInvoice i 
		INNER JOIN #tmpGainLossAccounts g ON i.CurrencyId = g.CurrencyId 
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.CurrencyID <> @CurrBase AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod)) 
		AND i.Status NOT IN (3,4) AND i.ExchRate <> ISNULL(e.ExchRate,1) 
		AND ((i.DistCode NOT IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @CurrBase) 
			AND i.CurrencyId <> e.CurrencyTo) 
			OR (i.DistCode IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @CurrBase))) 
	GROUP BY i.CurrencyId, i.DistCode, i.vendorId, g.GainAcct, e.ExchRate, g.LossAcct

	INSERT INTO #tmpUnrealGainLoss (AcctId, DebitAmt, CreditAmt) 
	SELECT g.AcctId, CASE WHEN ((SUM((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)) - SUM(i.GrossAmtDue)) > 0) 
			THEN 0 ELSE ROUND((SUM(ROUND(((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)), @PrecCurr)) 
			- SUM(i.GrossAmtDue)), @PrecCurr) END
		, CASE WHEN ((SUM((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)) - SUM(i.GrossAmtDue)) < 0) 
			THEN 0 ELSE ROUND((SUM(ROUND(((i.GrossAmtDueFgn) / ISNULL(e.ExchRate, 1)), @PrecCurr)) 
			- SUM(i.GrossAmtDue)), @PrecCurr) END 
	FROM dbo.tblApOpenInvoice i 
		INNER JOIN dbo.tblApDistCode d ON i.DistCode = d.DistCode 
		INNER JOIN dbo.tblGlAcctHdr g ON d.PayablesGLAcct = g.AcctId 
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.CurrencyID <> @CurrBase AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod)) 
		AND i.Status NOT IN (3,4) AND i.ExchRate <> ISNULL(e.ExchRate,1) 
		AND ((i.DistCode NOT IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @CurrBase) 
			AND i.CurrencyId <> e.CurrencyTo) 
			OR (i.DistCode IN (SELECT d.DistCode FROM dbo.tblApDistCode d INNER JOIN dbo.tblGlAcctHdr g on g.AcctId = d.PayablesGLAcct WHERE g.CurrencyId = @CurrBase))) 
	GROUP BY i.CurrencyId, i.DistCode, i.vendorId, g.AcctId, e.ExchRate

	INSERT INTO dbo.tblSmFunctionFlag (FunctionID, GlYear, Period) 
	VALUES ('ApUnReGnLs', @FiscalYear, @GlPeriod)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesPost_Calculate_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApUnRealizedGainsAndLossesPost_Calculate_proc';

