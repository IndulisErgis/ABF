
CREATE VIEW dbo.trav_ApCheckHistSumbyVendor_view
AS
	SELECT VendorId,FiscalYear,GlPeriod,CurrencyID,SUM(DiscTaken) TotDiscTaken, 
		SUM(DiscTakenfgn) TotDiscTakenfgn, SUM(DiscLost) TotDiscLost, SUM(DiscLostfgn) TotDiscLostfgn, 
		SUM(CASE WHEN DiscAmt = 0 THEN GrossAmtDue ELSE 0 END) PurchNoDisc, 
		SUM(CASE WHEN DiscAmtfgn = 0 THEN GrossAmtDuefgn ELSE 0 END) PurchNoDiscfgn, 
		SUM(CASE WHEN DiscTaken <> 0 THEN GrossAmtDue ELSE 0 END) PurchDiscTaken, 
		SUM(CASE WHEN DiscTakenfgn <> 0 THEN GrossAmtDuefgn ELSE 0 END) PurchDiscTakenfgn, 
		SUM(CASE WHEN DiscLost <> 0 THEN GrossAmtDue ELSE 0 END) PurchDiscLost, 
		SUM(CASE WHEN DiscLostfgn <> 0 THEN GrossAmtDuefgn ELSE 0 END) PurchDiscLostfgn, 
		SUM(GrossAmtDuefgn - DiscAmtfgn) TotPmtfgn,	SUM(GrossAmtDue - DiscTaken) TotPmt
	FROM dbo.tblApCheckHist
	WHERE VoidYn = 0
	GROUP BY VendorId,FiscalYear,GlPeriod, CurrencyID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApCheckHistSumbyVendor_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApCheckHistSumbyVendor_view';

