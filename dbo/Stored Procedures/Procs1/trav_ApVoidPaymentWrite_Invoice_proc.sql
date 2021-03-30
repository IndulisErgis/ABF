--PET:http://problemtrackingsystem.osas.com/view.php?id=261264
--PET:http://problemtrackingsystem.osas.com/view.php?id=266208
CREATE PROCEDURE dbo.trav_ApVoidPaymentWrite_Invoice_proc
AS
BEGIN TRY

	/* update tblApCheckHist with void flag & void date */
	UPDATE dbo.tblApCheckHist SET VoidYn = 1, VoidDate = t.VoidDate, PmtType = 9, SelectedYn = 0 
	FROM #PostTransList t INNER JOIN dbo.tblApCheckHist ON dbo.tblApCheckHist.Counter = t.TransId AND t.[Status] = 0

	/* append invoice records into tblApOpenInvoice */
	INSERT INTO dbo.tblApOpenInvoice (VendorID, InvoiceNum, [Status], Ten99InvoiceYN, DistCode, InvoiceDate, DiscDueDate, NetDueDate
		, GrossAmtDue, BaseGrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn, CurrencyId, ExchRate, TermsCode
		, FiscalYear, GlPeriod , VoidCreatedDate, PmtCurrencyID, PmtExchRate) 
	SELECT c.VendorID, InvoiceNum, t.ReinstateStatus, Ten99InvoiceYN, DistCode, InvoiceDate, DiscDueDate, NetDueDate
		, BaseGrossAmtDue, BaseGrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn, CurrencyID, ExchRate, TermsCode
		, t.VoidFiscalYear, t.VoidFiscalPeriod, t.VoidDate, NULL, 1 
	FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
	WHERE t.[Status] = 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Invoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Invoice_proc';

