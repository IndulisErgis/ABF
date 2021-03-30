
CREATE PROCEDURE dbo.trav_ApPeriodicMaint 
@DatePaidInvc datetime = NULL, 
@DateTempVend datetime = NULL
AS
SET NOCOUNT ON
BEGIN TRY

	-- purge paid invoices
	IF (@DatePaidInvc IS NOT NULL)
	BEGIN
		DELETE dbo.tblApOpenInvoice WHERE Status = 4 AND InvoiceDate < @DatePaidInvc
	END

	-- delete temp vendors
	IF (@DateTempVend IS NOT NULL)
	BEGIN
		CREATE TABLE #tmpVendorId (VendorId pVendorId NOT NULL)

		DELETE dbo.tblApOpenInvoice WHERE VendorID IN (SELECT VendorId FROM dbo.tblApVendor WHERE TempYN = 1) AND [Status] = 4 AND InvoiceDate < @DateTempVend

		INSERT INTO #tmpVendorId (VendorId)
		SELECT VendorId 
		FROM dbo.tblApVendor 
		WHERE TempYN = 1 AND VendorID NOT IN 
			(SELECT VendorID FROM dbo.tblApOpenInvoice UNION 
				SELECT VendorID FROM dbo.tblApTransHeader UNION 
				SELECT VendorID FROM dbo.tblPoTransHeader)

		DELETE dbo.tblApVendor 
		WHERE VendorID IN (SELECT VendorId FROM #tmpVendorId)

		DELETE dbo.tblSmDocumentDelivery 
		WHERE ContactID IN (SELECT VendorId FROM #tmpVendorId) AND ContactType = 1

	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPeriodicMaint';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPeriodicMaint';

