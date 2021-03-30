
CREATE PROCEDURE dbo.trav_PcBillingPost_OpenInvoice_proc
AS
Set NoCount ON
BEGIN TRY
--PET:http://webfront:801/view.php?id=236845
--MOD:Finance Charge Enhancements
--MOD:Deposit Invoice - Exclude pro forma invoice
--PET:http://webfront:801/view.php?id=239246
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	--append invoices and credit memos 
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp) 
	SELECT h.CustId, SIGN(TransType), CASE WHEN h.TransType < 0 THEN ISNULL(h.OrgInvcNum, ISNULL(NULLIF(h.InvcNum,''), t.DefaultInvoiceNumber)) 
			ELSE ISNULL(NULLIF(h.InvcNum,''), t.DefaultInvoiceNumber)	END, InvcDate, DistCode, TermsCode, CurrencyID, ExchRate, 
		TaxSubtotal + NonTaxSubtotal + SalesTax + TaxAmtAdj, TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn  + TaxAmtAdjFgn, 
		DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, FiscalPeriod, FiscalYear, @PostRun, h.TransId, 
		CASE WHEN ISNULL(a.InvcNum, '') = '' THEN 0 ELSE 1 END, 
		(CASE WHEN TransType < 0 THEN ISNULL(NULLIF(h.InvcNum,''), t.DefaultInvoiceNumber) ELSE NULL END), CustPONum, 3   
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h on t.TransId = h.TransId 
		LEFT JOIN (SELECT CustId, InvcNum FROM dbo.tblArOpenInvoice WHERE RecType > 0 AND RecType<>5 GROUP BY CustId, InvcNum) a 
			ON h.CustId = a.CustId AND h.OrgInvcNum = a.InvcNum 
	WHERE h.VoidYn = 0

	--append gain / loss records for credit memos, set gainlossstatus to 1, rectype -3 is used to indicate gain / loss
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, SourceApp) 
	SELECT h.CustId, -3, ISNULL(h.OrgInvcNum, ISNULL(NULLIF(h.InvcNum,''), t.DefaultInvoiceNumber)), InvcDate, DistCode, TermsCode, @CurrBase, 
		1, h.CalcGainLoss, 0, 0, 0, NetDueDate, NULL, FiscalPeriod, FiscalYear, @PostRun, h.TransId, 1, 3
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h on t.TransId = h.TransId 
		LEFT JOIN #GainLossAccounts g ON h.CurrencyId = g.CurrencyId 
	WHERE h.TransType < 0 AND h.CalcGainLoss <> 0 AND h.VoidYn = 0

    --append negative invoices for deposits with transaction invoice number
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp) 
	SELECT h.CustId, 1, CASE WHEN h.TransType > 0 THEN ISNULL(NULLIF(h.InvcNum,''), t.DefaultInvoiceNumber) ELSE ISNULL(h.OrgInvcNum, ISNULL(NULLIF(h.InvcNum,''), t.DefaultInvoiceNumber)) END, 
		InvcDate, DistCode, TermsCode, CurrencyID, ExchRate, 
		-1 * SIGN(h.TransType) * pmt.DepositTotal, -1 * SIGN(h.TransType) * pmt.DepositTotalFgn, 0, 0, NetDueDate, DiscDueDate, FiscalPeriod, FiscalYear, @PostRun, 
		h.TransId, 0, NULL, CustPONum, 3   
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h on t.TransId = h.TransId 
		INNER JOIN (SELECT l.TransID, SUM(p.DepositAmtApply) DepositTotal, 
			SUM(ROUND(p.DepositAmtApply * h.ExchRate, ISNULL(c.CurrDecPlaces, @PrecCurr))) DepositTotalFgn 
			FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId 
			INNER JOIN dbo.tblPcInvoiceDeposit p ON h.TransId = p.TransId 
			LEFT JOIN #tmpCurrencyList c ON h.CurrencyID = c.CurrencyId  
			GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	WHERE h.VoidYn = 0
	
	--append invoices for deposits with project id as invoice number
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp) 
	SELECT h.CustId, 1, pmt.ProjectName, h.InvcDate, h.DistCode, TermsCode, h.CurrencyID, h.ExchRate, 
		SIGN(h.TransType) * pmt.DepositTotal, SIGN(h.TransType) * pmt.DepositTotalFgn, 
		0, 0, h.NetDueDate, h.DiscDueDate, h.FiscalPeriod, h.FiscalYear, @PostRun, h.TransId, 0, NULL, h.CustPONum, 3   
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h on t.TransId = h.TransId 
			INNER JOIN (SELECT l.TransID, j.ProjectName, SUM(p.DepositAmtApply) DepositTotal, 
			SUM(ROUND(p.DepositAmtApply * h.ExchRate, ISNULL(c.CurrDecPlaces, @PrecCurr))) DepositTotalFgn 
			FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId 
			INNER JOIN dbo.tblPcInvoiceDeposit p ON h.TransId = p.TransId 
			INNER JOIN dbo.tblPcProjectDetail k ON p.ProjectDetailId = k.Id
			INNER JOIN dbo.tblPcProject j ON k.ProjectId = j.Id
			LEFT JOIN #tmpCurrencyList c ON h.CurrencyID = c.CurrencyId  
			GROUP BY l.TransId, j.ProjectName) pmt ON h.TransId = pmt.TransId
	WHERE h.VoidYn = 0
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_OpenInvoice_proc';

