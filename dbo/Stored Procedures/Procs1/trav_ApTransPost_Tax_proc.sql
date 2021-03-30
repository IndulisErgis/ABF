
CREATE PROCEDURE dbo.trav_ApTransPost_Tax_proc
AS
BEGIN TRY
DECLARE @ErrorMessage NVARCHAR(4000), @PostRun nvarchar(14), @InHsVendor pVendorID, @ApJcYn bit

--Retrieve global values
SELECT @InHsVendor = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'InHsVendor'
SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
SELECT @ApJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApJcYn'

IF @PostRun IS NULL OR @ApJcYn IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

SET @InHsVendor = ISNULL(@InHsVendor,'')

INSERT dbo.tblSmTaxLocTrans
	(TaxLocId, TaxClassCode, PostRun, SourceCode, LinkID, LinkIDSub, LinkIDSubLine, TransDate, 																									
	GLPeriod, FiscalYear, TaxSales, NonTaxSales, TaxCollect, TaxPurch, NonTaxPurch,
	TaxCalcPurch, TaxPaid, TaxRefund)
Select dbo.tblApTransInvoiceTax.TaxLocID, dbo.tblApTransInvoiceTax.TaxClass, @PostRun, 
	'AP', dbo.tblApTransInvoiceTax.TransID,  NULL, NULL, h.InvoiceDate, h.GLPeriod, h.FiscalYear, 0, 0, 0,
 	Sum((convert(decimal(28,10),SIGN(TransType))*
  	convert(decimal(28,10),tblApTransInvoiceTax.Taxable))), 
 	Sum((convert(decimal(28,10),SIGN(TransType))*
  	convert(decimal(28,10),tblApTransInvoiceTax.NonTaxable))), 
	Sum((convert(decimal(28,10),SIGN(TransType))*
  	convert(decimal(28,10),tblApTransInvoiceTax.TaxAmt))), 
 	Sum((convert(decimal(28,10),SIGN(TransType))*
  	convert(decimal(28,10),tblApTransInvoiceTax.TaxAmt))), 
 	Sum((convert(decimal(28,10),SIGN(TransType))*
 	 convert(decimal(28,10), dbo.tblApTransInvoiceTax.Refundable))) 
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId
INNER JOIN dbo.tblApTransInvoiceTax ON h.TransId = dbo.tblApTransInvoiceTax.TransId
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor)
GROUP BY dbo.tblApTransInvoiceTax.TransID, dbo.tblApTransInvoiceTax.TaxLocID, dbo.tblApTransInvoiceTax.TaxClass,
	h.InvoiceDate, h.GLPeriod, h.FiscalYear

--Insert AdjAmount to TaxPaid
INSERT dbo.tblSmTaxLocTrans
	(TaxLocId, TaxClassCode, PostRun, SourceCode, LinkID, LinkIDSub, LinkIDSubLine, TransDate, 																									
	GLPeriod, FiscalYear, TaxSales, NonTaxSales, TaxCollect, TaxPurch, NonTaxPurch,
	TaxCalcPurch, TaxPaid, TaxRefund)
Select h.TaxAdjLocID, h.TaxAdjClass, @PostRun, 
	'AP', h.TransID,  NULL, NULL, h.InvoiceDate, h.GLPeriod, h.FiscalYear, 
	0, 0, 0, 0, 0, 0, 
 	Sum((convert(decimal(28,10),SIGN(h.TransType))*
  	convert(decimal(28,10), h.TaxAdjAmt))), 0
FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId
WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor)  ANd h.TaxAdjAmt <> 0 
GROUP BY h.TransID, h.TaxAdjLocID, h.TaxAdjClass,
	h.InvoiceDate, h.GLPeriod, h.FiscalYear

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_Tax_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_Tax_proc';

