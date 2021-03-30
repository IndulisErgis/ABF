
CREATE VIEW [dbo].[trav_ArCustomerHistory_view]
AS

SELECT CustId, FiscalYear, GLPeriod
	, SUM(Sales) AS Sales, SUM(Cogs) AS COGS, SUM(Sales - COGS) Profit, SUM(NumInvc) NumInvc
	, SUM(Pmt) AS Pmt, SUM(Disc) AS Disc, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) DaysToPay
	, SUM(Finch) AS Finch
FROM (
	--Billing entity history
	SELECT h.CustID, h.FiscalYear, h.GlPeriod
		, SUM(SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn)) AS Sales
		, SUM(SIGN(h.TransType) * h.TotCostFgn) AS COGS
		, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) AS NumInvc 
		, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay, 0 AS Finch
	FROM dbo.tblArHistHeader h 
	WHERE VoidYn = 0
	GROUP BY h.CustID, h.FiscalYear, h.GlPeriod

	UNION ALL 
	
	--Sold To entity history for alternate billing entity
	SELECT h.SoldToId, h.FiscalYear, h.GlPeriod
		, SUM(SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn)) AS Sales
		, SUM(SIGN(h.TransType) * h.TotCostFgn) AS COGS
		, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) AS NumInvc 
		, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay, 0 AS Finch
	FROM dbo.tblArHistHeader h 
	WHERE h.SoldToId <> h.CustId AND VoidYn = 0
	GROUP BY h.SoldToId, h.FiscalYear, h.GlPeriod

	UNION ALL

	--payments 
	SELECT p.CustId, p.FiscalYear, p.GLPeriod
		, 0 AS Sales, 0 AS Cogs, 0 AS NumInvc
		, SUM(p.PmtAmtFgn) Pmt, SUM(p.DiffDiscFgn) Disc, COUNT(1) NumPmt
		, SUM(CASE WHEN p.PmtDate > h.InvcDate THEN DATEDIFF(dy, h.InvcDate, p.PmtDate) ELSE 0 END) DaysToPay
		, 0 AS Finch
	FROM dbo.tblArHistPmt p 
	LEFT JOIN (SELECT CustId, InvcNum, MAX(InvcDate) InvcDate 
		FROM dbo.tblArHistHeader WHERE TransType = 1 AND VoidYn = 0
		GROUP BY Custid, InvcNum) h ON p.CustId = h.CustId AND p.InvcNum = h.InvcNum
	GROUP BY p.CustID, p.FiscalYear, p.GLPeriod

	UNION ALL

	--finance charges
	SELECT f.CustId, f.FiscalYear, f.GLPeriod
		, 0 AS Sales, 0 AS Cogs, 0 AS NumInvc
		, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay
		, f.FinchAmtFgn AS Finch
	FROM dbo.tblArHistFinch f
) tmp
GROUP BY CustId, FiscalYear, GlPeriod
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCustomerHistory_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCustomerHistory_view';

