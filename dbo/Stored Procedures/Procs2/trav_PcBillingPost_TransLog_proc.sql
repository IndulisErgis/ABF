
CREATE PROCEDURE dbo.trav_PcBillingPost_TransLog_proc
AS
BEGIN TRY

	DECLARE @PrecCurr tinyint
			
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	
	IF @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	--update the transaction summary log table
	INSERT INTO #TransactionSummary ([FiscalYear], [FiscalPeriod]
		, [TransAmt], [RcptAmtApplied], [RcptAmtUnapplied]
		, [CurrencyId], [TransAmtFgn], [RcptAmtAppliedFgn], [RcptAmtUnappliedFgn])
	SELECT FiscalYear, FiscalPeriod
		, SUM(SIGN(TransType)*(TaxSubtotal+NonTaxSubtotal+SalesTax+TaxAmtAdj+CalcGainLoss))
		, SUM(SIGN(TransType)*ISNULL(pmt.DepositTotal,0)), 0
		, CurrencyId
		, SUM(SIGN(TransType)*(TaxSubtotalFgn+NonTaxSubtotalFgn+SalesTaxFgn+TaxAmtAdjFgn))
		, SUM(SIGN(TransType)*ISNULL(pmt.DepositTotalFgn,0)), 0
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
		LEFT JOIN (SELECT l.TransID, SUM(p.DepositAmtApply) DepositTotal, 
			SUM(ROUND(p.DepositAmtApply * h.ExchRate, ISNULL(c.CurrDecPlaces, @PrecCurr))) DepositTotalFgn 
			FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId 
			INNER JOIN dbo.tblPcInvoiceDeposit p ON h.TransId = p.TransId 
			LEFT JOIN #tmpCurrencyList c ON h.CurrencyID = c.CurrencyId  
			GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	WHERE h.VoidYn = 0
	GROUP BY FiscalYear, FiscalPeriod, CurrencyId
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_TransLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_TransLog_proc';

