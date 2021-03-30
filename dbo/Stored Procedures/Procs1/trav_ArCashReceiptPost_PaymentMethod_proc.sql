
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_PaymentMethod_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun
	DECLARE @ArGlYn bit, @CurrBase pCurrency

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @ArGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlYn'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @PostRun IS NULL OR @ArGlYn IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #PaymentMethodTotals
	(
		PmtMethodId nvarchar(10), 
		FiscalYear smallint, 
		FiscalPeriod smallint, 
		Amount pDecimal, 
		AmountFgn pDecimal, 
		UseBase bit
	)
	
	--summarize the payment method totals
	INSERT INTO #PaymentMethodTotals (PmtMethodId, FiscalYear, FiscalPeriod
		, UseBase, Amount, AmountFgn) 
	SELECT h.PmtMethodID, h.FiscalYear, h.GlPeriod
		, 0, SUM(d.PmtAmt), SUM(d.PmtAmtFgn)
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	INNER JOIN dbo.tblArPmtMethod p ON h.PmtMethodId = p.PmtMethodID
	GROUP BY h.PmtMethodID, h.FiscalYear, h.GlPeriod

	--conditionally identify the amounts that should be processed in base currency
	IF @ArGlYn = 1 
	BEGIN
		UPDATE #PaymentMethodTotals SET UseBase = 1
		FROM #PaymentMethodTotals 
		INNER JOIN dbo.tblArPmtMethod p on #PaymentMethodTotals.PmtMethodId = p.PmtMethodId
		INNER JOIN dbo.tblGlAcctHdr g ON p.GlAcctdebit = g.Acctid
		WHERE g.CurrencyID = @CurrBase
	END

	--create any missing periods to be updated
	INSERT INTO dbo.tblArPmtMethodDetail (PmtMethodID, FiscalYear, GlPeriod) 
	SELECT t.PmtMethodID, t.FiscalYear, t.FiscalPeriod 
	FROM #PaymentMethodTotals t 
	LEFT JOIN dbo.tblArPmtMethodDetail d 
		ON t.PmtMethodID = d.PmtMethodID AND t.FiscalYear = d.FiscalYear AND t.FiscalPeriod = d.GlPeriod 
	WHERE d.PmtMethodID IS NULL

	--udpate the payment mehtods
	UPDATE dbo.tblArPmtMethodDetail 
		SET Pmt = Pmt + (CASE WHEN t.UseBase = 1 THEN t.Amount ELSE t.AmountFgn END) 
	FROM #PaymentMethodTotals t 
		INNER JOIN dbo.tblArPmtMethodDetail  
			ON t.FiscalPeriod = dbo.tblArPmtMethodDetail.GLPeriod 
			AND t.FiscalYear = dbo.tblArPmtMethodDetail.FiscalYear 
			AND t.PmtMethodId = dbo.tblArPmtMethodDetail.PmtMethodID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_PaymentMethod_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_PaymentMethod_proc';

