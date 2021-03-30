
CREATE VIEW dbo.pvtApVendHistory
AS

SELECT a.VendorID, a.GlYear AS [Year], a.GlPeriod AS Period, ISNULL(SUM(h.NumOfPurch), 0) AS NumOfPurch, 
	ISNULL(SUM(h.TotPurch), 0) AS TotPurch, ISNULL(SUM(h.PrepaidAmt), 0) AS PrepaidAmt, 
	ISNULL(SUM(c.TotDiscTaken), 0) AS TotDiscTaken, ISNULL(SUM(c.TotDiscLost), 0) AS TotDiscLost, 
    ISNULL(SUM(c.PurchNoDisc), 0) AS PurchNoDisc, ISNULL(SUM(c.PurchDiscTaken), 0) AS PurchDiscTaken, 
	ISNULL(SUM(c.PurchDiscLost), 0) AS PurchDiscLost, ISNULL(SUM(c.TotPmt), 0) AS TotPmt, 
	ISNULL(SUM(h.TotPurch), 0) - ISNULL(SUM(c.TotPmt), 0) - ISNULL(SUM(c.TotDiscTaken), 0) AS GrossDue, 
	v.Name, v.VendorClass, v.DistCode
FROM (SELECT p.GlYear, p.GlPeriod, r.VendorId FROM dbo.tblSmPeriodConversion p, dbo.tblApVendor r) a 
	INNER JOIN dbo.tblApVendor v ON a.VendorID = v.VendorID 
	LEFT JOIN dbo.trav_ApHistHeaderSUMbyVendor_view h ON a.VendorID = h.VendorId AND a.GlYear = h.FiscalYear AND a.GlPeriod = h.GlPeriod 
	LEFT JOIN dbo.trav_ApCheckHistSumbyVendor_view c ON a.VendorID = c.VendorId AND a.GlYear = c.FiscalYear AND a.GlPeriod = c.GlPeriod
GROUP BY a.VendorID, a.GlYear, a.GlPeriod, v.Name, v.VendorClass, v.DistCode
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApVendHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApVendHistory';

