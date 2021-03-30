
CREATE  VIEW dbo.pvtArSalesAnalysis
AS
SELECT dtl.FiscalYear AS [Year], dtl.GlPeriod AS Period
	, SUM(dtl.Sales) AS TotSales, SUM(dtl.Cogs) AS TotCogs, SUM(dtl.NumInvc) AS NumInvc
	, SUM(dtl.Pmts) AS TotPmts, SUM(dtl.Disc) AS TotDisc, SUM(dtl.NumPmt) AS NumPmt, SUM(dtl.DaysToPay) AS TotDaysToPay
	, CASE WHEN SUM(dtl.NumPmt) > 0 THEN SUM(dtl.DaysToPay)/SUM(dtl.NumPmt) ELSE SUM(dtl.DaysToPay) END AS AvgDaysToPay
FROM 
(
	SELECT FiscalYear, GlPeriod
		, SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal) AS Sales
		, SIGN(TransType) * TotCost AS Cogs
		, CASE WHEN TransType > 0 THEN 1 ELSE 0 END AS NumInvc 
		, 0 AS Pmts, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay
		, 0 AS FinchAmt
		FROM dbo.tblArHistHeader
		WHERE VoidYn = 0
	UNION ALL
	SELECT p.FiscalYear, p.GlPeriod
		, 0 AS Sales, 0 AS Cogs, 0 AS NumInvc
		, p.PmtAmt AS Pmts
		, p.DiffDisc AS Disc
		, CASE WHEN p.PmtAmt > 0 THEN 1 ELSE 0 END AS NumPmt
		, CASE WHEN p.PmtDate > h.InvcDate THEN DATEDIFF(dy, h.InvcDate, p.PmtDate) ELSE 0 END AS DaysToPay
		, 0 AS FinchAmt
		FROM dbo.tblArHistPmt p 
		LEFT JOIN (SELECT CustId, InvcNum, max(InvcDate) InvcDate 
			FROM dbo.tblArHistHeader 
			WHERE TransType = 1 AND VoidYn = 0
			GROUP BY Custid, InvcNum) h ON p.CustId = h.CustId AND p.InvcNum = h.InvcNum
		INNER JOIN dbo.tblArCust c on c.Custid = p.CustID
		WHERE C.CcCompYn = 0 AND p.VoidYn = 0
	UNION ALL
	SELECT FiscalYear, GlPeriod
		, 0 AS Sales, 0 AS Cogs, 0 AS NumInvc
		, 0 AS Pmts, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay
		, FinchAmt
		FROM dbo.tblArHistFinch 
	UNION ALL --ensure that there is at least one record for each period in the period conversion table
		SELECT GlYear AS FiscalYear, GlPeriod
		, 0 AS Sales, 0 AS Cogs, 0 AS NumInvc
		, 0 AS Pmts, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay
		, 0 AS FinchAmt
		FROM dbo.tblSmPeriodConversion
) dtl
GROUP BY dtl.FiscalYear, dtl.GLPeriod
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArSalesAnalysis';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArSalesAnalysis';

