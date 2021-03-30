
CREATE VIEW dbo.pvtApSumHistItem
AS

SELECT h.VendorId, d.PartId, h.FiscalYear AS [Year], h.GLPeriod AS Period, CAST(COUNT(h.TransType) AS int) AS NumOfPurch, 
	MIN(d.UnitsBase) AS BaseUnit, SUM(SIGN(h.TransType) * d.QtyBase) AS Qty, SUM(SIGN(h.TransType) * d.ExtCost) AS CostOfGoods
FROM dbo.tblApHistHeader h INNER JOIN dbo.tblApHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum
WHERE d.PartId IS NOT NULL AND d.PartId <> ''
GROUP BY h.VendorId, d.PartId, h.FiscalYear, h.GLPeriod
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApSumHistItem';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApSumHistItem';

