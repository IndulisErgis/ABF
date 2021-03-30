
CREATE PROCEDURE dbo.trav_ApVendorInfo_proc
@VendorId pVendorId = NULL, --Vendor ID
@Year smallint = 2010, --Calendar year of workstation date
@VendorCurrencyPrecision tinyint = 2, --Vendor currency precision
@BaseCurrencyPrecision tinyint = 2 --Base currency precision 
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @YTDPurchase decimal(28,10), @LastYearPurchase decimal(28,10), @PendingPurchase decimal(28,10), @GrossDue decimal(28,10),
		@YTDPurchaseFgn decimal(28,10), @LastYearPurchaseFgn decimal(28,10), @PendingPurchaseFgn decimal(28,10), @GrossDueFgn decimal(28,10)
	
	SELECT @YTDPurchase = SUM(SIGN(TransType) * CASE WHEN YEAR(InvoiceDate) = @Year THEN 
			 Subtotal + SalesTax + Freight + Misc + TaxAdjAmt ELSE 0 END),
		   @YTDPurchaseFgn = SUM(SIGN(TransType) * CASE WHEN YEAR(InvoiceDate) = @Year THEN 
			 Subtotalfgn + SalesTaxfgn + Freightfgn + Miscfgn + TaxAdjAmtfgn ELSE 0 END),
		   @LastYearPurchase = SUM(SIGN(TransType) * CASE WHEN YEAR(InvoiceDate) = @Year - 1 THEN 
			 Subtotal + SalesTax + Freight + Misc + TaxAdjAmt ELSE 0 END),
		   @LastYearPurchaseFgn = SUM(SIGN(TransType) * CASE WHEN YEAR(InvoiceDate) = @Year - 1 THEN 
			 Subtotalfgn + SalesTaxfgn + Freightfgn+ Miscfgn + TaxAdjAmtfgn ELSE 0 END)			
	FROM dbo.tblApHistheader 
	WHERE VendorId = @VendorId

	SELECT @PendingPurchase = SUM(ROUND(CASE WHEN d.QtyOrd > ISNULL(r.QtyFilled,0) THEN SIGN(h.TransType) * (d.QtyOrd - ISNULL(r.QtyFilled,0)) * 
			 d.UnitCost ELSE 0 END,@BaseCurrencyPrecision)),
		   @PendingPurchaseFgn = SUM(ROUND(CASE WHEN d.QtyOrd > ISNULL(r.QtyFilled,0) THEN SIGN(h.TransType) * (d.QtyOrd - ISNULL(r.QtyFilled,0)) * 
			 d.UnitCostFgn ELSE 0 END,@VendorCurrencyPrecision))
	FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId 
		LEFT JOIN (SELECT TransId,EntryNum, SUM(QtyFilled) QtyFilled FROM dbo.tblPoTransLotRcpt GROUP BY TransId,EntryNum) r 
			ON h.TransId = r.TransId AND d.EntryNum = r.EntryNum
	WHERE h.VendorId = @VendorId AND d.LineStatus = 0
	
	SELECT @GrossDue = SUM(GrossAmtDue), @GrossDueFgn = SUM(GrossAmtDueFgn)  
	FROM dbo.tblApOpenInvoice
	WHERE VendorID = @VendorId AND Status < 3
	
	SELECT ISNULL(@YTDPurchase,0) AS YTDPurchase, ISNULL(@LastYearPurchase,0) AS LastYearPurchase, 
		ISNULL(@PendingPurchase,0) AS PendingPurchase, ISNULL(@GrossDue,0) AS GrossDue,
		ISNULL(@YTDPurchaseFgn,0) AS YTDPurchaseFgn, ISNULL(@LastYearPurchaseFgn,0) AS LastYearPurchaseFgn, 
		ISNULL(@PendingPurchaseFgn,0) AS PendingPurchaseFgn, ISNULL(@GrossDueFgn,0) AS GrossDueFgn

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorInfo_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorInfo_proc';

