
CREATE PROCEDURE dbo.trav_ArUnRealizedGainsAndLossesReport_proc
@FiscalYear Smallint = 2008,
@GlPeriod Smallint = 12,
@BaseCurrency pCurrency = 'USD',
@BaseCurrencyPrecision Tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT i.CustId,i.CurrencyId,i.ExchRate,i.InvcNum,ISNULL(e.ExchRate,1) PdExchRate,i.TransDate,
		AmtFgn - ISNULL((SELECT SUM(AmtFgn)	FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0) AS AmtDueFgn,
		(Amt - ISNULL((SELECT SUM(Amt) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0)) AmtDue,
		ROUND((AmtFgn - ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0))/ISNULL(e.ExchRate,1),CAST(@BaseCurrencyPrecision AS INT)) PmtAmt,
		ROUND((AmtFgn - ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0))/ISNULL(e.ExchRate,1),CAST(@BaseCurrencyPrecision AS INT)) -
			(Amt - ISNULL((SELECT SUM(Amt) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0)) GainLossAmt
	FROM dbo.tblArOpenInvoice i INNER JOIN #tmpCurrencyList t ON i.CurrencyId = t.CurrencyId 
		INNER JOIN dbo.tblArDistCode d ON i.DistCode = d.DistCode
		INNER JOIN dbo.tblGlAcctHdr h ON d.GLAcctReceivables = h.AcctId 
		LEFT JOIN (SELECT CurrencyTo, ExchRate FROM #ExchRateYrPd) e ON i.CurrencyID = e.CurrencyTo
	WHERE i.Currencyid <> @BaseCurrency AND h.CurrencyId = @BaseCurrency  
		AND (i.FiscalYear < @FiscalYear OR (i.FiscalYear = @FiscalYear AND i.GlPeriod <= @GlPeriod))
		AND i.Status <> 4 AND i.RecType > 0 AND AmtFgn > ISNULL((SELECT SUM(AmtFgn) FROM dbo.tblArOpenInvoice WHERE Custid = i.CustId AND InvcNum = i.InvcNum AND RecType < 0),0) 
		AND i.ExchRate <> ISNULL(e.ExchRate,1)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUnRealizedGainsAndLossesReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUnRealizedGainsAndLossesReport_proc';

