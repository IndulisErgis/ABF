
CREATE PROCEDURE dbo.trav_PsLayawayPost_OpenInvoice_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint, @FiscalYear smallint, @FiscalPeriod smallint, @WrkStnDate datetime 

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @PostRun IS NULL OR @CurrBase IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL OR @WrkStnDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	--Assume all customers are base currency customer for now;
	--Discount is taken;
	--No gain/loss;
	--SourceApp, 4 for PS;

	--append invoices 
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp) 
	SELECT h.BillToID, 1, t.InvoiceNum, h.TransDate, t.DistCode, c.TermsCode, @CurrBase, 1, t.InvoiceTotal, t.InvoiceTotal, 
		0, 0, h.DueDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, t.TransID, 0, NULL, NULL, 4   
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId 
	WHERE h.VoidDate IS NULL AND t.InvoiceTotal <> 0

    --append payment of incomplete layaway
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp, PmtMethodId, CheckNum) 
	SELECT h.BillToID, -2, l.InvoiceNum, p.PmtDate, l.DistCode, NULL, @CurrBase, 1, p.AmountBase, p.AmountBase, 0, 0, --Standard: only supports base currency external transactions
		p.PmtDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, t.TransID, 0, NULL, NULL, 4, p.PmtMethodID, p.CheckNum
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblPsTransHeader h ON p.HeaderID = h.ID  
		INNER JOIN #PsIncompleteLayawayList l ON h.ID = l.ID
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0

	--append payment of completed layaway that does not have rounding adjustment
	--or non-cash payment of completed layaway
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp, PmtMethodId, CheckNum) 
	SELECT h.BillToID, -2, l.InvoiceNum, p.PmtDate, l.DistCode, NULL, @CurrBase, 1, p.AmountBase, p.AmountBase, 0, 0, --Standard: only supports base currency external transactions
		p.PmtDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, t.TransID, 0, NULL, NULL, 4, p.PmtMethodID, p.CheckNum
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblPsTransHeader h ON p.HeaderID = h.ID  
		INNER JOIN #PsCompletedLayawayList l ON h.ID = l.ID
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId 
		LEFT JOIN (SELECT t.ID FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransDetail d ON t.ID = d.HeaderID WHERE LineType = -4 AND ExtPrice <> 0 GROUP BY t.ID) r 
			ON l.ID = r.ID
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0 AND (p.PmtType <> 1 OR r.ID IS NULL)  

	--append cash payment of completed layaway that has rounding adjustment
	--adjust open invoice amount for last cash payment using rounding adjustment
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp, PmtMethodId, CheckNum) 
	SELECT h.BillToID, -2, l.InvoiceNum, p.PmtDate, l.DistCode, NULL, @CurrBase, 1, p.AmountBase + CASE WHEN m.ID IS NULL THEN 0 ELSE r.RoudingAdj END, --Standard: only supports base currency external transactions
		p.AmountBase + CASE WHEN m.ID IS NULL THEN 0 ELSE r.RoudingAdj END, 0, 0, p.PmtDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, t.TransID, 
		0, NULL, NULL, 4, p.PmtMethodID, p.CheckNum
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblPsTransHeader h ON p.HeaderID = h.ID  
		INNER JOIN #PsCompletedLayawayList l ON h.ID = l.ID
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId 
		INNER JOIN (SELECT t.ID, SUM(ExtPrice) AS RoudingAdj FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransDetail d ON t.ID = d.HeaderID WHERE LineType = -4 AND ExtPrice <> 0 GROUP BY t.ID) r 
			ON l.ID = r.ID 
		LEFT JOIN (SELECT l.ID, MAX(p.EntryDate) LastPmtDate FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID --Last cash payment
			INNER JOIN #PsCompletedLayawayList l ON p.HeaderID = l.ID 
			WHERE p.PmtType = 1
			GROUP BY l.ID) m ON l.ID = m.ID AND p.EntryDate = m.LastPmtDate
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0 AND p.PmtType = 1

	--Append CC Company Invoices
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn, 
		DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum, 
		CustPONum, SourceApp, PmtMethodId, CheckNum) 
	SELECT m.CustId, 1, 'CC' + CONVERT(nvarchar(8), @WrkStnDate, 112), @WrkStnDate, c.DistCode, c.TermsCode, @CurrBase, --Standard: only supports base currency external transactions
		1, SUM(p.AmountBase), SUM(p.AmountBase), 
		0, 0, @WrkStnDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, NULL, 0, NULL, NULL, 4, p.PmtMethodID, NULL
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID
		INNER JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodId
		INNER JOIN dbo.tblArCust c ON m.CustId = c.CustId 
	WHERE p.VoidDate IS NULL AND (m.PmtType = 3 OR m.PmtType = 7)
	GROUP BY m.CustId, c.DistCode, c.TermsCode, c.CurrencyId, p.PmtMethodID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_OpenInvoice_proc';

