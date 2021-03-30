
CREATE PROCEDURE dbo.trav_PoTransPost_OpenInvoice_proc
AS
BEGIN TRY

	DECLARE @PrecCurr smallint,@CurrBase pCurrency,@InHsVendor nvarchar(10),@PoJcYn bit,
		@PostRun nvarchar(14),@PostAsHeld bit

	--Retrieve global values
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PoJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PoJcYn'
	SELECT @InHsVendor = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'InHsVendor'
	SELECT @PostAsHeld = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Held'

	IF @PrecCurr IS NULL OR @CurrBase IS NULL OR @PostRun IS NULL 
		OR @PoJcYn IS NULL OR @PostAsHeld IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	SET @InHsVendor = ISNULL(@InHsVendor,'')

	CREATE TABLE #TransPost1a
	(	Counter int NOT NULL IDENTITY, 
		VendorID nvarchar(10) NOT NULL, 
		InvcNum nvarchar(15) NOT NULL, 
		GLPeriod smallint NULL DEFAULT(0), 
		FiscalYear smallint NULL DEFAULT(0), 
		PaidStatus tinyint NULL, 
		Ten99InvoiceYN bit NOT NULL, 
		DistCode nvarchar(6) NULL, 
		TermsCode nvarchar(6) NULL, 
		InvoiceDate datetime NULL, 
		NetDueDate datetime NULL, 
		DiscDueDate datetime NULL, 
		DiscAmt Decimal(28,10) NULL DEFAULT (0), 
		DiscAmtFgn Decimal(28,10) NULL DEFAULT (0), 
		GrossAmtDue Decimal(28,10) NULL DEFAULT (0), 
		BaseGrossAmtDue Decimal(28,10) NULL DEFAULT (0), 
		GrossAmtDueFgn Decimal(28,10) NULL DEFAULT (0), 
		CheckNum nvarchar(10) NULL, 
		CheckDate datetime NULL, 
		CurrencyID nvarchar(6) NOT NULL, 
		ExchRate pDecimal NULL DEFAULT (1),
		CheckYear smallint NULL DEFAULT(0),
		CheckPeriod smallint NULL DEFAULT(0),
		BankID nvarchar (10) NULL, 
		PmtCurrencyId pCurrency NULL,
		PmtExchRate pDecimal NULL DEFAULT (1),
		CalcGainLoss pDecimal  NULL DEFAULT (0),
		GLAccGainLoss pGlAcct  NULL,
		Notes nvarchar(max) null,   
		PostRun pPostRun NULL ,
		TransID pTransID NULL ,
		PRIMARY KEY (Counter) 
	)

	INSERT INTO #TransPost1a 
	( VendorID, InvcNum, GLPeriod, FiscalYear, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, 
	  InvoiceDate, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CheckNum, 
	  CheckDate, CurrencyId, ExchRate, CheckYear, CheckPeriod, BankID, PmtCurrencyId, PmtExchRate, 
	  CalcGainLoss, GLAccGainLoss, Notes, PostRun, TransId) 
	SELECT h.VendorID, t.InvcNum, t.GLPeriod, t.FiscalYear, 3, t.Ten99InvoiceYN, h.DistCode, h.TermsCode,  
	t.InvcDate, t.InvcDate, t.DiscDueDate, Sign(h.TransType) * CurrDisc, 
	Sign(h.TransType)* CurrDiscFgn, Sign(h.TransType) * (CurrPrepaid + CurrDisc), SIGN(h.TransType) * ROUND(((CurrPrepaidFgn + CurrDiscFgn) / t.InvoiceExchRate), @PrecCurr),
	Sign(h.TransType) * (CurrPrepaidFgn + CurrDiscFgn), 
	t.CurrCheckNo, t.CurrCheckDate, h.CurrencyID, t.InvoiceExchRate, t.CurrChkFiscalYear, 
	t.CurrChkGlPeriod, t.CurrBankID,
	Case When (g.CurrencyId <> @CurrBase) then t.PmtCurrencyId else @CurrBase end,
	Case When (g.CurrencyId <> @CurrBase) then t.PmtExchRate else 1 end, 
	-(ROUND((t.CurrDiscFgn + t.CurrPrepaidFgn) / t.InvoiceExchRate, @PrecCurr)
				- ROUND((t.CurrDiscFgn / t.InvoiceExchRate), @PrecCurr) 
				- ROUND((t.CurrPrepaidFgn / t.PmtExchRate), @PrecCurr)),
	Case When (-(ROUND((t.CurrDiscFgn + t.CurrPrepaidFgn) / t.InvoiceExchRate, @PrecCurr)
				- ROUND((t.CurrDiscFgn / t.InvoiceExchRate), @PrecCurr) 
				- ROUND((t.CurrPrepaidFgn / t.PmtExchRate), @PrecCurr)) < 0) 
	Then g.RealGainAcct 
	Else g.RealLossAcct 
	End,
	h.Notes, @PostRun, h.TransId
	FROM #PostTransList s INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
		Inner Join #GainLossAccounts g on h.CurrencyId = g.CurrencyId
		Left Join (Select d.DistCode, D.[Desc], G.CurrencyId from dbo.tblApDistCode D 
Inner Join dbo.tblGlAcctHdr G on G.AcctId = D.PayablesGLAcct) dc on h.DistCode = dc.DistCode
		WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND t.CurrPrepaid <> 0 AND (CurrPmtAmt1 + CurrPmtAmt2 + CurrPmtAmt3) = 0

	INSERT INTO #TransPost1a 
	( VendorID, InvcNum, GLPeriod, FiscalYear, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, 
	  InvoiceDate, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue,  BaseGrossAmtDue, GrossAmtDueFgn, CheckNum, 
	  CheckDate, CurrencyId, ExchRate, CheckYear, CheckPeriod, BankID, PmtCurrencyId, PmtExchRate, CalcGainLoss, 
	  GLAccGainLoss, Notes, PostRun, TransId) 
	SELECT h.VendorID, t.InvcNum, t.GLPeriod, t.FiscalYear, 3, t.Ten99InvoiceYN, h.DistCode, h.TermsCode, 
	 t.InvcDate, t.InvcDate, t.DiscDueDate, 0, 0, Sign(h.TransType) * CurrPrepaid, Sign(h.TransType) * round((CurrPrepaidfgn / t.InvoiceExchRate), @PrecCurr) , Sign(h.TransType) * CurrPrepaidFgn, 
	 t.CurrCheckNo, t.CurrCheckDate, h.CurrencyID, t.InvoiceExchRate, t.CurrChkFiscalYear, t.CurrChkGlPeriod, t.CurrBankID,
	Case When (h.CurrencyId <> @CurrBase) then t.PmtCurrencyId else @CurrBase end,
	Case When (h.CurrencyId <> @CurrBase) then t.PmtExchRate else 1 end, 
	Case When t.InvoiceExchRate <> t.PmtExchRate
		then Round((Round((CurrPrepaidFgn/t.PmtExchRate), @PrecCurr) - Round((CurrPrepaidFgn/t.InvoiceExchRate) , @PrecCurr)), @PrecCurr) 
		Else 0 
		End, --calculate the Gain/Loss when the exchange rates differ
	Case When t.InvoiceExchRate = t.PmtExchRate
	Then
		NULL --no gain/loss 	
	Else
		Case When (((CurrPrepaidFgn/t.PmtExchRate) - (CurrPrepaidFgn/t.InvoiceExchRate)) < 0)
		Then g.RealGainAcct 
		Else g.RealLossAcct 
		End
	End ,
	h.Notes, @PostRun, h.TransId
	FROM #PostTransList s INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
		Inner Join #GainLossAccounts g on h.CurrencyId = g.CurrencyId
		Left Join (Select d.DistCode, D.[Desc], G.CurrencyId from dbo.tblApDistCode D 
Inner Join dbo.tblGlAcctHdr G on G.AcctId = D.PayablesGLAcct) dc on h.DistCode = dc.DistCode
		WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND t.CurrPrepaid <> 0 AND (CurrPmtAmt1 + CurrPmtAmt2 + CurrPmtAmt3) <> 0

	--PmtAmt 1
	INSERT INTO #TransPost1a 
	( VendorID, InvcNum, GLPeriod, FiscalYear, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, 
	  InvoiceDate, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CurrencyId, 
	  ExchRate, Notes, PostRun, TransId, BankId) 
	SELECT h.VendorID, t.InvcNum, t.GLPeriod, t.FiscalYear, @PostAsHeld, t.Ten99InvoiceYN, h.DistCode, h.TermsCode, 
	 t.InvcDate, t.CurrDueDate1, t.DiscDueDate, Sign(h.TransType) * CurrDisc, 
	Sign(h.TransType) * CurrDiscFgn, 
	Sign(h.TransType) * (CurrPmtAmt1 + CurrDisc),
	Sign(h.TransType) * (CurrPmtAmt1 + CurrDisc),
	Sign(h.TransType) * (CurrPmtAmt1Fgn + CurrDiscFgn), 
	h.CurrencyID, t.InvoiceExchRate, h.Notes, @PostRun, h.TransId , v.DefaultPayBankId
	FROM #PostTransList s INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
		INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
	WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND t.CurrPmtAmt1 <> 0 

	--PmtAmt 2
	INSERT INTO #TransPost1a 
	( VendorID, InvcNum, GLPeriod, FiscalYear, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, 
	  InvoiceDate, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CurrencyId, 
	  ExchRate, Notes, PostRun, TransId, BankId) 
	SELECT h.VendorID, t.InvcNum, t.GLPeriod, t.FiscalYear, 
	 CASE WHEN @PostAsHeld = 1 THEN 1 ELSE 0 END, 
	 t.Ten99InvoiceYN, h.DistCode, h.TermsCode, t.InvcDate, t.CurrDueDate2, t.DiscDueDate, 
	0, 0, 
	Sign(h.TransType) * (CurrPmtAmt2),
	Sign(h.TransType) * (CurrPmtAmt2),
	Sign(h.TransType) * CurrPmtAmt2Fgn, 
	h.CurrencyID, t.InvoiceExchRate, h.Notes, @PostRun, h.TransId , v.DefaultPayBankId
	FROM #PostTransList s INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
		INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
	WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND t.CurrPmtAmt2 <> 0 

	--PmtAmt 3
	INSERT INTO #TransPost1a 
	( VendorID, InvcNum, GLPeriod, FiscalYear, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, 
	  InvoiceDate, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, CurrencyId, 
	  ExchRate, Notes, PostRun, TransId, BankId)    
	SELECT h.VendorID, t.InvcNum, t.GLPeriod, t.FiscalYear, 
	 CASE WHEN @PostAsHeld = 1 THEN 1 ELSE 0 END, 
	 t.Ten99InvoiceYN, h.DistCode, h.TermsCode, t.InvcDate, t.CurrDueDate3, t.DiscDueDate, 
	 0, 0,
	Sign(h.TransType) * (CurrPmtAmt3),
	Sign(h.TransType) * (CurrPmtAmt3),
	Sign(h.TransType) * CurrPmtAmt3Fgn, 
	h.CurrencyID, t.InvoiceExchRate, h.Notes, @PostRun, h.TransId , v.DefaultPayBankId   
	FROM #PostTransList s INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
		INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
	WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND t.CurrPmtAmt3 <> 0

	INSERT INTO dbo.tblApOpenInvoice 
		(VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyId, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, PmtCurrencyId, 
		PmtExchRate, CalcGainLoss, GLAccGainLoss, Notes, PostRun, TransId) 
	SELECT VendorID, InvcNum, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyID, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, 
		PmtCurrencyId, PmtExchRate, CalcGainLoss, GLAccGainLoss, Notes, PostRun, TransId
	FROM #TransPost1a 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_OpenInvoice_proc';

