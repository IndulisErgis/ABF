
CREATE PROCEDURE dbo.trav_ApTransPost_OpenInvoice_proc
AS
BEGIN TRY
DECLARE @PostRun nvarchar(14), @InHsVendor pVendorID,
@CurrBase pCurrency, @PrecCurr smallint,@Held bit,@ApJcYn bit

--Retrieve global values
SELECT @InHsVendor = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'InHsVendor'
SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
SELECT @Held = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Held'
SELECT @ApJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApJcYn'

IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @Held IS NULL OR @ApJcYn IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

SET @InHsVendor = ISNULL(@InHsVendor,'')

CREATE TABLE #tmpGainLossAcct 
(
CurrencyID pCurrency NOT NULL, 
RealGainAcct pGlAcct NOT NULL, 
RealLossAcct pGlAcct NOT NULL,
UnrealGainAcct pGlAcct NOT NULL,
UnrealLossAcct pGlAcct NOT NULL,
)

--capture Gain/Loss Accounts
INSERT INTO #tmpGainLossAcct (CurrencyID
	, RealGainAcct, RealLossAcct, UnRealGainAcct, UnRealLossAcct) 
SELECT c.CurrencyId
	, ISNULL(g.GlAcctRealGain, (SELECT GlAcctRealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
	, ISNULL(g.GlAcctRealLoss, (SELECT GlAcctRealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
	, ISNULL(g.GlAcctUnRealGain, (SELECT GlAcctUnRealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
	, ISNULL(g.GlAcctUnRealLoss , (SELECT GlAcctUnRealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~'))
FROM #tmpCurrencyList c LEFT JOIN dbo.tblSmGainLossAccount g ON c.CurrencyId = g.CurrencyID

-- append prepaid invoices where balance due = 0
INSERT dbo.tblApOpenInvoice (VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
	, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CheckNum, CheckDate, CurrencyId, ExchRate
	, GlPeriod, FiscalYear, TermsCode, BankId, CheckPeriod, CheckYear, PmtCurrencyId, PmtExchRate 
	, CalcGainLoss, GLAccGainLoss, Notes, PostRun, TransId) 
SELECT h.VendorId, h.InvoiceNum, 3, h.Ten99InvoiceYN, h.DistCode, h.InvoiceDate, h.InvoiceDate, h.InvoiceDate, SIGN(TransType) * CashDisc
	, SIGN(TransType) * CashDiscFgn, SIGN(TransType) * (PrepaidAmt + CashDisc)
	, SIGN(TransType) * ROUND(((PrepaidAmtFgn + CashDiscFgn) / h.ExchRate), @PrecCurr), SIGN(TransType) * (PrepaidAmtFgn + CashDiscFgn)
	, h.CheckNum, h.CheckDate, h.CurrencyId, h.ExchRate, h.GLPeriod, h.FiscalYear, h.TermsCode, h.BankId, h.ChkGlPeriod, h.ChkFiscalYear
	, CASE WHEN (h.CurrencyId <> @CurrBase) THEN PmtCurrencyId ELSE @CurrBase END
	, CASE WHEN (h.CurrencyId <> @CurrBase) THEN PmtExchRate ELSE 1 END
	, -(ROUND((CashDiscFgn + PrepaidAmtFgn) / h.ExchRate, @PrecCurr)
				- ROUND((CashDiscFgn / h.ExchRate), @PrecCurr) 
				- ROUND((PrepaidAmtFgn / h.PmtExchRate), @PrecCurr))
	, CASE WHEN (-(ROUND(ROUND(((CashDiscFgn + PrepaidAmtFgn) / h.ExchRate), @PrecCurr)
			- ROUND((CashDiscFgn / h.ExchRate), @PrecCurr) 
			- ROUND((PrepaidAmtFgn / h.PmtExchRate), @PrecCurr), @PrecCurr)) < 0) 
		THEN 
			g.RealGainAcct 
		WHEN 
			(-(ROUND(ROUND(((CashDiscFgn + PrepaidAmtFgn) / h.ExchRate), @PrecCurr)
			- ROUND((CashDiscFgn / h.ExchRate), @PrecCurr) 
			- ROUND((PrepaidAmtFgn / h.PmtExchRate), @PrecCurr), @PrecCurr)) > 0) 
		THEN 
			g.RealLossAcct 
		ELSE 
			NULL
		END

	, Notes, @PostRun, h.TransId 
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	INNER JOIN #tmpGainLossAcct g ON h.CurrencyId = g.CurrencyId 
	LEFT JOIN dbo.tblApDistCode dc ON h.DistCode = dc.DistCode 
	LEFT JOIN dbo.tblGlAcctHdr a ON a.AcctId = dc.PayablesGLAcct 
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor) AND h.PrepaidAmt <> 0 AND PmtAmt1 + PmtAmt2 + PmtAmt3 = 0 

-- append prepaid invoices where balance due <> 0
INSERT dbo.tblApOpenInvoice (VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
	, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CheckNum, CheckDate, CurrencyId, ExchRate, GlPeriod, FiscalYear
	, TermsCode, BankId, CheckPeriod, CheckYear, PmtCurrencyId, PmtExchRate
	, CalcGainLoss, GLAccGainLoss, Notes, PostRun, TransId) 
SELECT h.VendorId, h.InvoiceNum, 3, h.Ten99InvoiceYN, h.DistCode, h.InvoiceDate, h.InvoiceDate, h.InvoiceDate
	, SIGN(TransType) * PrepaidAmt, SIGN(TransType) * ROUND((PrepaidAmtfgn / h.ExchRate), @PrecCurr)
	, SIGN(TransType) * PrepaidAmtFgn, h.CheckNum, h.CheckDate, h.CurrencyId, h.ExchRate, h.GLPeriod, h.FiscalYear
	, h.TermsCode, h.BankId, h.ChkGlPeriod, h.ChkFiscalYear
	, CASE WHEN (h.CurrencyId <> @CurrBase) THEN PmtCurrencyId ELSE @CurrBase END PmtCurrencyId
	, CASE WHEN (h.CurrencyId <> @CurrBase) THEN PmtExchRate ELSE 1 END PmtExchRate
	, Case When h.ExchRate <> h.PmtExchRate
		THEN ROUND(ROUND((PrepaidAmtFgn / h.PmtExchRate), @PrecCurr) 
			- ROUND((PrepaidAmtFgn / h.ExchRate), @PrecCurr), @PrecCurr) 
		ELSE 0 
		End --calculate the Gain/Loss when the exchange rates differ
	, Case When h.ExchRate = h.PmtExchRate
	Then
		NULL --no gain/loss 	
	Else
		CASE WHEN (((PrepaidAmtFgn / h.PmtExchRate) - (PrepaidAmtFgn / h.ExchRate)) < 0) --PTS 45583 (2)
		THEN 
			g.RealGainAcct 
		ELSE 
			g.RealLossAcct 
		END
	End
	, Notes, @PostRun, h.TransId  
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId 
INNER JOIN #tmpGainLossAcct g ON h.CurrencyId = g.CurrencyId 
LEFT JOIN dbo.tblApDistCode dc ON h.DistCode = dc.DistCode 
LEFT JOIN dbo.tblGlAcctHdr a ON a.AcctId = dc.PayablesGLAcct 
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor) AND h.PrepaidAmt <> 0 AND PmtAmt1 + PmtAmt2 + PmtAmt3 <> 0 

-- append PmtAmt1 + CashDisc invoices where balance due <> 0 and prepaid amount <> 0
INSERT INTO dbo.tblApOpenInvoice (VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
	, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CurrencyId, ExchRate
	, GLPeriod, FiscalYear, TermsCode, Notes, PostRun, TransId,BankId) 
SELECT h.VendorId, h.InvoiceNum, CASE WHEN @Held = 0 THEN h.Status ELSE 1 END, h.Ten99InvoiceYN, h.DistCode
	, h.InvoiceDate, h.DueDate1, h.DiscDueDate, SIGN(TransType) * CashDisc, SIGN(TransType) * CashDiscFgn
	, SIGN(TransType) * (PmtAmt1 + CashDisc), SIGN(TransType) * (PmtAmt1 + CashDisc)
	, SIGN(TransType) * (PmtAmt1Fgn + CashDiscFgn), h.CurrencyId, h.ExchRate, h.GLPeriod, h.FiscalYear
	, h.TermsCode, Notes, @PostRun, h.TransId , v.DefaultPayBankId
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId  
	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor) AND h.PmtAmt1 + CashDisc <> 0 AND h.PrepaidAmt <> 0 AND PmtAmt1 + PmtAmt2 + PmtAmt3 <> 0 

-- append PmtAmt1 + CashDisc invoices where prepaid amount = 0
INSERT INTO dbo.tblApOpenInvoice (VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
	, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CurrencyId, ExchRate
	, GLPeriod, FiscalYear, TermsCode, Notes, PostRun, TransId,BankId) 
SELECT h.VendorId, h.InvoiceNum, CASE WHEN @Held = 0 THEN h.Status ELSE 1 END, h.Ten99InvoiceYN, h.DistCode
	, h.InvoiceDate, h.DueDate1, h.DiscDueDate, SIGN(TransType) * CashDisc, SIGN(TransType) * CashDiscFgn
	, SIGN(TransType) * (PmtAmt1 + CashDisc), SIGN(TransType) * (PmtAmt1 + CashDisc)
	, SIGN(TransType) * (PmtAmt1Fgn + CashDiscFgn), h.CurrencyId, h.ExchRate, h.GLPeriod, h.FiscalYear
	, h.TermsCode, Notes, @PostRun, h.TransId , v.DefaultPayBankId
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId  
	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor) AND h.PmtAmt1 + CashDisc <> 0 AND h.PrepaidAmt = 0

-- append PmtAmt2 invoices
INSERT dbo.tblApOpenInvoice (VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
	, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CurrencyId, ExchRate, GLPeriod, FiscalYear, TermsCode, Notes
	, PostRun, TransId,BankId) 
SELECT h.VendorId, h.InvoiceNum, CASE WHEN @Held = 0 THEN h.Status ELSE 1 END, h.Ten99InvoiceYN, h.DistCode
	, h.InvoiceDate, h.DueDate2, h.DiscDueDate, SIGN(TransType) * (PmtAmt2), SIGN(TransType) * (PmtAmt2)
	, SIGN(TransType) * PmtAmt2Fgn, h.CurrencyId, h.ExchRate, h.GLPeriod, h.FiscalYear, h.TermsCode, Notes
	, @PostRun, h.TransId , v.DefaultPayBankId
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId  
	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor) AND h.PmtAmt2 <> 0

-- append PmtAmt3 invoices
INSERT dbo.tblApOpenInvoice (VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
	, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CurrencyId, ExchRate, GLPeriod, FiscalYear, TermsCode, Notes
	, PostRun, TransId,BankId) 
SELECT h.VendorId, h.InvoiceNum, CASE WHEN @Held = 0 THEN h.Status ELSE 1 END, h.Ten99InvoiceYN, h.DistCode
	, h.InvoiceDate, h.DueDate3, h.DiscDueDate, SIGN(TransType) * (PmtAmt3), SIGN(TransType) * (PmtAmt3)
	, SIGN(TransType) * PmtAmt3Fgn, h.CurrencyId, h.ExchRate, h.GLPeriod, h.FiscalYear, h.TermsCode, Notes
	, @PostRun, h.TransId , v.DefaultPayBankId
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId  
	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor) AND h.PmtAmt3 <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_OpenInvoice_proc';

