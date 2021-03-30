
CREATE VIEW dbo.pvtArCustSalesHist
AS
SELECT dtl.CustId, dtl.FiscalYear AS [Year], dtl.GlPeriod AS Period, dtl.CurrencyID
	, SUM(dtl.Sales) AS TotSales, SUM(dtl.SalesFgn) AS TotSalesFgn
	, SUM(dtl.Cogs) AS TotCogs, SUM(dtl.CogsFgn) AS TotCogsFgn
	, SUM(dtl.NumInvc) AS NumInvc
	, SUM(dtl.Pmts) AS TotPmts, SUM(dtl.PmtsFgn) AS TotPmtsFgn
	, SUM(dtl.Disc) AS TotDisc, SUM(dtl.DiscFgn) AS TotDiscFgn
	, SUM(dtl.NumPmt) AS NumPmt
	, SUM(dtl.DaysToPay) AS TotDaysToPay
	, SUM(dtl.FinchAmt) AS UnpaidFinch, SUM(dtl.FinchAmtFgn) AS UnpaidFinchFgn
	, SUM(dtl.Sales - dtl.Pmts) AS CurAmtDue, SUM(dtl.SalesFgn - dtl.PmtsFgn) AS CurAmtDueFgn
FROM 
(
	SELECT CustId, FiscalYear, GlPeriod, CurrencyId
		, SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal) AS Sales
		, SIGN(TransType) * TotCost AS Cogs
		, SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn) AS SalesFgn
		, SIGN(TransType) * TotCostFgn AS CogsFgn
		, CASE WHEN TransType > 0 THEN 1 ELSE 0 END AS NumInvc 
		, 0 AS Pmts, 0 AS Disc, 0 AS PmtsFgn, 0 AS DiscFgn, 0 AS NumPmt, 0 AS DaysToPay
		, 0 AS FinchAmt, 0 AS FinchAmtFgn
		FROM dbo.tblArHistHeader
		WHERE VoidYn = 0
	UNION ALL
	SELECT p.CustId, p.FiscalYear, p.GlPeriod, p.CurrencyId
		, 0 AS Sales, 0 AS SalesFgn, 0 AS Cogs, 0 AS CogsFgn, 0 AS NumInvc
		, p.PmtAmt AS Pmts
		, p.DiffDisc AS Disc
		, p.PmtAmtFgn AS PmtsFgn
		, p.DiffDiscFgn AS DiscFgn
		, CASE WHEN p.PmtAmt > 0 THEN 1 ELSE 0 END AS NumPmt
		, CASE WHEN p.PmtDate > h.InvcDate THEN DATEDIFF(dy, h.InvcDate, p.PmtDate) ELSE 0 END AS DaysToPay
		, 0 AS FinchAmt, 0 AS FinchAmtFgn
		FROM dbo.tblArHistPmt p 
		LEFT JOIN (SELECT CustId, InvcNum, max(InvcDate) InvcDate 
			FROM dbo.tblArHistHeader 
			WHERE TransType = 1 AND VoidYn = 0
			GROUP BY Custid, InvcNum) h ON p.CustId = h.CustId AND p.InvcNum = h.InvcNum
		INNER JOIN dbo.tblArCust c on c.Custid = p.CustID
		WHERE C.CcCompYn = 0 AND p.VoidYn = 0
	UNION ALL
	SELECT CustID, FiscalYear, GlPeriod, CurrencyID
		, 0 AS Sales, 0 AS SalesFgn, 0 AS Cogs, 0 AS CogsFgn, 0 AS NumInvc
		, 0 AS Pmts, 0 AS Disc, 0 AS PmtsFgn, 0 AS DiscFgn, 0 AS NumPmt, 0 AS DaysToPay
		, FinchAmt, FinchAmtFgn
		FROM dbo.tblArHistFinch 
	UNION ALL --ensure that there is at least one record for each period in the period conversion table
		SELECT c.CustId, p.GlYear AS FiscalYear, p.GlPeriod, c.CurrencyId
		, 0 AS Sales, 0 AS SalesFgn, 0 AS Cogs, 0 AS CogsFgn, 0 AS NumInvc
		, 0 AS Pmts, 0 AS Disc, 0 AS PmtsFgn, 0 AS DiscFgn, 0 AS NumPmt, 0 AS DaysToPay
		, 0 AS FinchAmt, 0 AS FinchAmtFgn
		FROM dbo.tblArCust c CROSS JOIN dbo.tblSmPeriodConversion p
) dtl
GROUP BY dtl.CustId, dtl.FiscalYear, dtl.GLPeriod, dtl.CurrencyID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArCustSalesHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArCustSalesHist';

