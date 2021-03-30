
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_PurgeInvoice_proc
AS
BEGIN TRY
	DELETE dbo.tblSvInvoiceHeader
		FROM dbo.tblSvInvoiceHeader
		INNER JOIN #PostTransList l ON dbo.tblSvInvoiceHeader.TransId = l.TransId

	DELETE dbo.tblSvInvoiceDetail
		FROM dbo.tblSvInvoiceDetail
		INNER JOIN #PostTransList l ON dbo.tblSvInvoiceDetail.TransId = l.TransId

	
	DELETE dbo.tblSvInvoiceDispatch
		FROM dbo.tblSvInvoiceDispatch
		INNER JOIN #PostTransList l ON dbo.tblSvInvoiceDispatch.TransId = l.TransId

	DELETE dbo.tblSvInvoiceTax
		FROM dbo.tblSvInvoiceTax
		INNER JOIN #PostTransList l ON dbo.tblSvInvoiceTax.TransId = l.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_PurgeInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_PurgeInvoice_proc';

