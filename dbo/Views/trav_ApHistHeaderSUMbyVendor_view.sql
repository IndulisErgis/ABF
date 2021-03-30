
CREATE VIEW dbo.trav_ApHistHeaderSUMbyVendor_view
AS
	SELECT VendorId,FiscalYear, GlPeriod, CurrencyID, COUNT(TransType) NumOfPurch,
		SUM(SIGN(TransType)*(Subtotal+SalesTax+Freight+Misc+TaxAdjAmt)) TotPurch,
		SUM(SIGN(TransType)*(Subtotalfgn+SalesTaxfgn+Freightfgn+Miscfgn+TaxAdjAmtfgn))  TotPurchfgn,
		SUM(PrepaidAmt) PrepaidAmt, SUM(PrepaidAmtfgn)  PrepaidAmtfgn
	FROM dbo.tblApHistHeader
	GROUP BY VendorId, FiscalYear, GlPeriod, CurrencyID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApHistHeaderSUMbyVendor_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApHistHeaderSUMbyVendor_view';

