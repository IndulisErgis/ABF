
CREATE PROCEDURE dbo.trav_GlUnrealizedGainsAndLossesReport_proc
@FiscalYear Smallint,
@GlPeriod Smallint,
@BaseCurrency pCurrency,
@BaseCurrencyPrecision Tinyint
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT j.AcctId,@FiscalYear [Year],@GlPeriod Period,j.CurrencyId,ISNULL(e.ExchRate,1) PdExchRate
		, CASE WHEN t.AcctCode < 0 THEN 
			ROUND((j.CreditAmtFgn - j.DebitAmtFgn)/ISNULL(e.ExchRate,1), @BaseCurrencyPrecision) - (j.CreditAmt - j.DebitAmt) 
		ELSE 
			ROUND((j.DebitAmtFgn - j.CreditAmtFgn)/ISNULL(e.ExchRate,1), @BaseCurrencyPrecision) - (j.DebitAmt - j.CreditAmt) 
		END AS Gain
		, b.Actual Balance,j.ExchRate,j.TransDate,j.CreditAmtFgn,j.DebitAmtFgn
	FROM #tmpCurrencyList c INNER JOIN  dbo.tblGlJrnl j (NOLOCK) ON c.CurrencyId = j.CurrencyId 
		INNER JOIN dbo.tblGlAcctHdr h (NOLOCK) ON j.AcctId = h.AcctId 
		INNER JOIN dbo.tblGlAcctType t (NOLOCK) ON h.AcctTypeId = t.AcctTypeId 
		INNER JOIN (SELECT AcctId,SUM(Actual) Actual FROM dbo.tblGlAcctDtl WHERE [Year] = @FiscalYear AND Period <= @GlPeriod GROUP BY AcctID) b ON j.AcctId = b.AcctId
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON j.CurrencyID = e.CurrencyTo
	WHERE j.CurrencyId <> @BaseCurrency AND (j.[Year] < @FiscalYear OR (j.[Year] = @FiscalYear AND j.Period <= @GlPeriod)) AND j.PostedYn = -1 
		AND t.AcctClassId IN (115,200) AND j.URG = 0
		AND (ROUND((j.DebitAmtFgn - j.CreditAmtFgn)/ISNULL(e.ExchRate,1), @BaseCurrencyPrecision) - (j.DebitAmt - j.CreditAmt)) <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlUnrealizedGainsAndLossesReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlUnrealizedGainsAndLossesReport_proc';

