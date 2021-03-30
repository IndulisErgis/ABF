
CREATE PROCEDURE dbo.trav_PoTransPost_Vendor_proc
AS
BEGIN TRY
DECLARE @InHsVendor pVendorID, @PoJcYn bit

--Retrieve global values
SELECT @InHsVendor = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'InHsVendor'
SELECT @PoJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PoJcYn'

IF @PoJcYn IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

SET @InHsVendor = ISNULL(@InHsVendor,'')

CREATE TABLE #VendorLastInfo 
(VendorId pVendorId NOT NULL,
 InvoiceNum pInvoiceNum NOT NULL,
 InvoiceDate datetime NOT NULL)

CREATE TABLE #TransInfo
(
 VendorId pVendorId NOT NULL,
 InvoiceNum pInvoiceNum NOT NULL,
 InvoiceDate datetime NOT NULL,
 PurchAmt pDecimal,
 PurchAmtFgn pDecimal)

--vendor history detail
SELECT h.VendorID, t.FiscalYear, t.GlPeriod INTO #tempVendHistDetail 
FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransID 
		INNER JOIN dbo.tblApVendor v  ON h.VendorID = v.VendorId 
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
WHERE (@PoJcYn = 0 OR h.VendorID <> @InHsVendor)
GROUP BY h.VendorID, t.FiscalYear, t.GlPeriod

INSERT INTO dbo.tblApVendorHistDetail (VendorID, FiscalYear, GLPeriod) 
SELECT t.VendorID, t.FiscalYear, t.GLPeriod FROM #tempVendHistDetail t 
	LEFT JOIN dbo.tblApVendorHistDetail h ON t.VendorID = h.VendorID AND t.FiscalYear = h.FiscalYear AND t.GLPeriod = h.GLPeriod 
WHERE h.VendorID IS NULL

SELECT VendorID, FiscalYear, GlPeriod, SUM(SIGN(TransType) * (CurrTaxable + CurrNonTaxable + CurrSalesTax + CurrFreight + CurrMisc + CurrTaxAdjAmt)) Purch
	, SUM(SIGN(TransType) * (CurrTaxablefgn + CurrNonTaxablefgn + CurrSalesTaxfgn + CurrFreightfgn + CurrMiscfgn + CurrTaxAdjAmtfgn)) Purchfgn 
INTO #tmpVendorHistDet 
FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransID 
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
WHERE (@PoJcYn = 0 OR h.VendorID <> @InHsVendor) 
GROUP BY VendorID, FiscalYear, GlPeriod

UPDATE dbo.tblApVendorHistDetail SET dbo.tblApVendorHistDetail.Purch = dbo.tblApVendorHistDetail.Purch + t.Purch
	, dbo.tblApVendorHistDetail.Purchfgn = dbo.tblApVendorHistDetail.Purchfgn + t.Purchfgn 
FROM #tmpVendorHistDet t INNER JOIN dbo.tblApVendorHistDetail ON t.GLPeriod = dbo.tblApVendorHistDetail.GLPeriod 
	AND t.FiscalYear = dbo.tblApVendorHistDetail.FiscalYear AND t.VendorId = dbo.tblApVendorHistDetail.VendorID

-- update vendor
UPDATE dbo.tblApVendor SET GrossDue = SumOfGrossAmtDue, GrossDuefgn = SumOfGrossAmtDuefgn,
	Prepaid = t.Prepaid, Prepaidfgn = t.Prepaidfgn 
FROM dbo.tblApVendor INNER JOIN 
(SELECT v.VendorID, SUM(CASE WHEN i.Status < 3 THEN GrossAmtDue ELSE 0 END) SumOfGrossAmtDue, 
SUM(CASE WHEN i.Status < 3 THEN GrossAmtDuefgn ELSE 0 END) SumOfGrossAmtDuefgn,
SUM(CASE WHEN i.Status = 3 THEN GrossAmtDue ELSE 0 END) Prepaid, 
SUM(CASE WHEN i.Status = 3 THEN GrossAmtDuefgn ELSE 0 END) Prepaidfgn
FROM dbo.tblApOpenInvoice i INNER JOIN 
	(SELECT h.VendorId FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId WHERE (@PoJcYn = 0 OR h.VendorID <> @InHsVendor) GROUP BY h.VendorId) v 
		ON i.VendorId = v.VendorId
WHERE i.Status < 4 
GROUP BY v.VendorID) t
ON dbo.tblApVendor.VendorID = t.VendorID

INSERT INTO #TransInfo (VendorId,InvoiceNum,InvoiceDate,PurchAmt,PurchAmtFgn)
SELECT h.VendorId,t.InvcNum,t.InvcDate,
	t.CurrTaxable + t.CurrNonTaxable + t.CurrSalesTax + t.CurrFreight + t.CurrMisc + t.CurrTaxAdjAmt,
	t.CurrTaxablefgn + t.CurrNonTaxablefgn + t.CurrSalesTaxfgn + t.CurrFreightfgn + t.CurrMiscfgn + t.CurrTaxAdjAmtfgn
FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransID 
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId
WHERE (@PoJcYn = 0 OR h.VendorID <> @InHsVendor) AND h.TransType > 0 AND (t.CurrTaxablefgn != 0 OR t.CurrNonTaxablefgn != 0 OR t.CurrSalesTaxfgn != 0 OR  t.CurrFreightfgn != 0 OR  t.CurrMiscfgn != 0 OR  t.CurrTaxAdjAmtfgn != 0 OR t.CurrPrepaidFgn <> 0)

INSERT INTO #VendorLastInfo (VendorId,InvoiceNum,InvoiceDate) 
SELECT h.VendorId,MAX(h.InvoiceNum),h.InvoiceDate
FROM #TransInfo h INNER JOIN (SELECT VendorId,MAX(InvoiceDate) InvoiceDate
	FROM #TransInfo GROUP BY VendorId) t 
	ON h.VendorId = t.VendorId and h.InvoiceDate = t.InvoiceDate 
GROUP BY h.VendorId,h.InvoiceDate

UPDATE dbo.tblApVendor 
	SET LastPurchDate = v.InvoiceDate, LastPurchNum = v.InvoiceNum,
		LastPurchAmt = h.PurchAmt,
		LastPurchAmtFgn = h.PurchAmtFgn
FROM dbo.tblApVendor INNER JOIN #VendorLastInfo v ON dbo.tblApVendor.VendorId = v.VendorId 
	INNER JOIN #TransInfo h ON v.VendorId = h.VendorId AND v.InvoiceNum = h.InvoiceNum AND v.InvoiceDate = h.InvoiceDate 
WHERE (LastPurchDate IS NULL OR LastPurchDate < v.InvoiceDate) 


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_Vendor_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_Vendor_proc';

