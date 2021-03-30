
CREATE PROCEDURE dbo.trav_ApCheckDuplicateInvoiceNumber_proc 
@VendorId pVendorId = NULL,
@InvoiceNum pInvoiceNum = NULL
AS 
DECLARE @Ret tinyint 
SET @Ret = 0
IF EXISTS (SELECT * FROM dbo.tblApTransHeader WHERE VendorId = @VendorId AND InvoiceNum = @InvoiceNum) 
	SET @Ret = 1 
ELSE IF EXISTS (SELECT * FROM dbo.tblPoTransInvoiceTot t INNER JOIN dbo.tblPoTransHeader h ON t.TransId = h.TransId WHERE h.VendorId = @VendorId AND t.InvcNum = @InvoiceNum) 
	SET @Ret = 1 
ELSE IF EXISTS (SELECT * FROM dbo.tblApHistHeader WHERE VendorId = @VendorId AND InvoiceNum = @InvoiceNum) 
	SET @Ret = 1 
ELSE IF EXISTS (SELECT * FROM dbo.tblApOpenInvoice WHERE VendorId = @VendorId AND InvoiceNum = @InvoiceNum) 
	SET @Ret = 1 
SELECT @Ret AS ReturnValue
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApCheckDuplicateInvoiceNumber_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApCheckDuplicateInvoiceNumber_proc';

