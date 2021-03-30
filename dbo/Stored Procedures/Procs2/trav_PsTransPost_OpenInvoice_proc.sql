
CREATE PROCEDURE dbo.trav_PsTransPost_OpenInvoice_proc
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint, @FiscalYear smallint, @FiscalPeriod smallint,
		@OnAccountInvcNum nvarchar(15), @WrkStnDate datetime 

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @OnAccountInvcNum = Cast([Value] AS nvarchar(15)) FROM #GlobalValues WHERE [Key] = 'OnAccountInvcNum'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @PostRun IS NULL OR @CurrBase IS NULL OR @OnAccountInvcNum IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL OR @WrkStnDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	--Skip foreign customer for now;
	--Discount is taken;
	--No gain/loss;
	--SourceApp, 4 for PS;
	--No open invoice is created if transaction net due is zero;

	--append invoices and return 
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp) 
	SELECT h.BillToID, SIGN(h.TransType), t.InvoiceNum, h.TransDate, t.DistCode, c.TermsCode, @CurrBase, 1, t.InvoiceTotal, t.InvoiceTotal, t.DiscAmt, t.DiscAmt, 
		t.NetDueDate, t.DiscDueDate, @FiscalPeriod, @FiscalYear, @PostRun, t.TransID, 0, (CASE WHEN h.TransType < 0 THEN t.InvoiceNum ELSE NULL END), NULL, 4   
	FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId 
	WHERE h.VoidDate IS NULL AND t.InvoiceTotal <> 0 AND t.NetDue <> 0

    --append payment
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp, PmtMethodId, CheckNum) 
	--Misc payment
	SELECT p.CustID, -2, @OnAccountInvcNum, p.PmtDate, t.DistCode, NULL, @CurrBase, 1, p.AmountBase, p.AmountBase, 0, 0, --Standard: only supports base currency external transactions
		p.PmtDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, t.TransID, 0, NULL, NULL, 4, p.PmtMethodID, p.CheckNum
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblArCust c ON p.CustID = c.CustId
	WHERE p.HeaderID IS NULL AND p.VoidDate IS NULL AND p.AmountBase <> 0
	UNION ALL
	--Transaction payment
	SELECT h.BillToID, -2, i.InvoiceNum, p.PmtDate, i.DistCode, NULL, @CurrBase, 1, p.AmountBase, p.AmountBase, 0, 0, --Standard: only supports base currency external transactions
		p.PmtDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, t.TransID, 0, NULL, NULL, 4, p.PmtMethodID, p.CheckNum
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblPsTransHeader h ON p.HeaderID = h.ID 
		INNER JOIN #PsTransList i ON h.ID = i.ID 
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId
		INNER JOIN (SELECT HeaderID, SUM(SIGN(LineType) * ExtPrice) AS NetDue
			FROM dbo.tblPsTransDetail GROUP BY HeaderID) d ON h.ID = d.HeaderID 
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0 AND d.NetDue <> 0

	--Append CC Company Invoices
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn, 
		DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum, 
		CustPONum, SourceApp, PmtMethodId, CheckNum) 
	SELECT m.CustId, 1, 'CC' + CONVERT(nvarchar(8), @WrkStnDate, 112), @WrkStnDate, c.DistCode, c.TermsCode, @CurrBase, --Standard: only supports base currency external transactions
		1, SUM(p.AmountBase), SUM(p.AmountBase), 
		0, 0, @WrkStnDate, NULL, @FiscalPeriod, @FiscalYear, @PostRun, NULL, 0, NULL, NULL, 4, p.PmtMethodID, NULL
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID
		INNER JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodId
		INNER JOIN dbo.tblArCust c ON m.CustId = c.CustId 
	WHERE p.VoidDate IS NULL AND (m.PmtType = 3 OR m.PmtType = 7)
	GROUP BY m.CustId, c.DistCode, c.TermsCode, c.CurrencyId, p.PmtMethodID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_OpenInvoice_proc';

