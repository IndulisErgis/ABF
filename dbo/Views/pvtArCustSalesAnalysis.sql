
CREATE VIEW dbo.pvtArCustSalesAnalysis
AS
SELECT dtl.FiscalYear AS [Year], dtl.GLPeriod AS Period
	, dtl.CustId, dbo.tblArCust.CustName
	, dbo.tblArCust.SalesRepId1, dbo.tblArCust.SalesRepId2
	, SUM(dtl.NumInvc) AS NumInvc 
	, SUM(dtl.Sales) AS TotSales
	, SUM(dtl.Cogs) AS TotCogs
FROM (
	SELECT dbo.tblArHistHeader.FiscalYear, dbo.tblArHistHeader.GLPeriod
		, dbo.tblArHistHeader.CustId
		, CASE WHEN TransType > 0 THEN 1 ELSE 0 END AS NumInvc 
		, SIGN(TransType) * (TaxSubtotal+NonTaxSubtotal) AS Sales
		, SIGN(TransType) * TotCost AS Cogs
		FROM dbo.tblArHistHeader
		WHERE VoidYn = 0
	UNION ALL --ensure there is a record for each period, year and customer
	SELECT p.GlYear AS FiscalYear, p.GlPeriod, c.CustId
		, 0 AS NumInvc, 0 AS Sales, 0 AS Cogs
	FROM dbo.tblArCust c CROSS JOIN dbo.tblSmPeriodConversion p
) dtl
INNER JOIN dbo.tblArCust on dtl.CustId = dbo.tblArCust.CustId
GROUP BY dtl.CustId, dtl.FiscalYear, dtl.GlPeriod
	, dbo.tblArCust.CustName, dbo.tblArCust.SalesRepId1, dbo.tblArCust.SalesRepId2
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArCustSalesAnalysis';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArCustSalesAnalysis';

