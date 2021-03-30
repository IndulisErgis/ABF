
CREATE VIEW dbo.pvtArItemHist
AS
SELECT td.PartId, th.FiscalYear AS [Year], th.SumHistPeriod AS Period
	, MAX(td.UnitsBase) BaseUnit
	, ISNULL(SUM(QtyShipBase * SIGN(TransType)), 0) Qty
	, ISNULL(SUM(PriceExt * SIGN(TransType)), 0) TotSales
	, ISNULL(SUM(CostExt * SIGN(TransType)), 0) TotCogs
	, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc 
	FROM dbo.tblArHistHeader th 
	INNER JOIN dbo.tblArHistDetail td ON th.PostRun = td.PostRun AND th.TransId = td.TransId 
	WHERE th.VoidYn = 0
	GROUP BY td.PartId, td.JobID, th.FiscalYear, th.SumHistPeriod
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArItemHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArItemHist';

