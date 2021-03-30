
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_OpenInvoice_proc
AS
Set NoCount ON
BEGIN TRY

	DECLARE @PostRun pPostRun

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'


	IF @PostRun IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	--append invoices 
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp) 
	SELECT h.BillToID, SIGN(TransType),InvoiceNumber, InvoiceDate, DistCode, TermsCode, CurrencyID, ExchRate, 
		TaxSubtotal + NonTaxSubtotal + SalesTax + TaxAmtAdj, TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn  + TaxAmtAdjFgn, 
		DiscAmt, ISNULL(DiscAmtFgn,0), NetDueDate, DiscDueDate, FiscalPeriod, FiscalYear, @PostRun, h.TransId, 
		0, 	null, h.CustomerPoNumber, 2   
	FROM #PostTransList t INNER JOIN dbo.tblSvInvoiceHeader h on t.TransId = h.TransId 
	WHERE h.VoidYn = 0 AND h.PrintStatus <>3

	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_OpenInvoice_proc';

