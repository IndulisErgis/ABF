
CREATE VIEW [dbo].[trav_ArCustomerHistoryOffset_view]
AS

	--Offset entries for history where the Sold To and Bill To are not the same
	SELECT h.CustId, h.SoldToId, h.FiscalYear, h.GlPeriod
		, SUM(SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn)) AS Sales
		, SUM(SIGN(h.TransType) * h.TotCostFgn) AS COGS
		, SUM(SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn - h.TotCostFgn)) AS Profit
		, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) AS NumInvc 
	FROM dbo.tblArHistHeader h 
	WHERE h.SoldToId <> h.CustId AND VoidYn = 0
	GROUP BY h.CustId, h.SoldToId, h.FiscalYear, h.GlPeriod
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCustomerHistoryOffset_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArCustomerHistoryOffset_view';

