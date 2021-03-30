
CREATE PROCEDURE dbo.trav_PcBillingPost_RemoveInvoice_proc
AS
BEGIN TRY
	DELETE dbo.tblPcInvoiceHeader
		FROM dbo.tblPcInvoiceHeader
		INNER JOIN #PostTransList l ON dbo.tblPcInvoiceHeader.TransId = l.TransId

	DELETE dbo.tblPcInvoiceDetail
		FROM dbo.tblPcInvoiceDetail
		INNER JOIN #PostTransList l ON dbo.tblPcInvoiceDetail.TransId = l.TransId

	DELETE dbo.tblPcInvoiceDeposit
		FROM dbo.tblPcInvoiceDeposit
		INNER JOIN #PostTransList l ON dbo.tblPcInvoiceDeposit.TransId = l.TransId

	DELETE dbo.tblPcInvoiceTax
		FROM dbo.tblPcInvoiceTax
		INNER JOIN #PostTransList l ON dbo.tblPcInvoiceTax.TransId = l.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_RemoveInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_RemoveInvoice_proc';

