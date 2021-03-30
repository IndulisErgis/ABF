
CREATE PROCEDURE dbo.trav_ApPaymentPost_Invoice_proc
AS
BEGIN TRY

	/* change invoice status to paid */
	UPDATE dbo.tblApOpenInvoice 
		SET dbo.tblApOpenInvoice.Status = 4 
	FROM dbo.tblApOpenInvoice 
		INNER JOIN dbo.tblApPrepChkInvc ON dbo.tblApOpenInvoice.Counter = dbo.tblApPrepChkInvc.Counter 
	INNER JOIN #PostTransList b ON  dbo.tblApPrepChkInvc.BatchId = b.TransId

	UPDATE dbo.tblApPrepChkInvc 
		SET dbo.tblApPrepChkInvc.TermsCode = dbo.tblApOpenInvoice.TermsCode 
	FROM dbo.tblApOpenInvoice 
		INNER JOIN dbo.tblApPrepChkInvc ON dbo.tblApOpenInvoice.Counter = dbo.tblApPrepChkInvc.Counter
	INNER JOIN #PostTransList b ON dbo.tblApPrepChkInvc.BatchId = b.TransId

	UPDATE dbo.tblApOpenInvoice 
		SET CheckNum = dbo.tblApPrepChkCheck.CheckNum, CheckDate = c.CheckDate
			, CheckYear = c.FiscalYear, CheckPeriod = c.GLPeriod
	FROM (dbo.tblApOpenInvoice INNER JOIN dbo.tblApPrepChkCheck ON dbo.tblApOpenInvoice.VendorID = dbo.tblApPrepChkCheck.VendorID) 
		INNER JOIN dbo.tblApPrepChkInvc ON dbo.tblApOpenInvoice.Counter = dbo.tblApPrepChkInvc.Counter 
			AND dbo.tblApPrepChkInvc.GrpID = dbo.tblApPrepChkCheck.GrpID AND dbo.tblApPrepChkInvc.BatchID = dbo.tblApPrepChkCheck.BatchID
	INNER JOIN #PostTransList b ON dbo.tblApPrepChkInvc.BatchId = b.TransId
	INNER JOIN dbo.tblApPrepChkCntl c ON dbo.tblApPrepChkInvc.BatchId = c.BatchID 
	WHERE  dbo.tblApPrepChkInvc.Status <> 3

	/* release temp hold invoices in tblApOpenInvoice for the selected currency only */
	UPDATE dbo.tblApOpenInvoice SET Status = 0 
	FROM dbo.tblApOpenInvoice INNER JOIN dbo.tblApPrepChkCntl c ON dbo.tblApOpenInvoice.CurrencyId = c.Currency 
		INNER JOIN #PostTransList b ON c.BatchId = b.TransId
	WHERE dbo.tblApOpenInvoice.Status = 2

	/* populate tblApPrepChkInvc with fiscal year and period */
	UPDATE dbo.tblApPrepChkInvc 
		SET FiscalYear = c.FiscalYear, GlPeriod = c.GLPeriod 
	FROM dbo.tblApPrepChkInvc 
	INNER JOIN #PostTransList b ON dbo.tblApPrepChkInvc.BatchId = b.TransId
	INNER JOIN dbo.tblApPrepChkCntl c ON dbo.tblApPrepChkInvc.BatchId = c.BatchID 
	WHERE Status = 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Invoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Invoice_proc';

