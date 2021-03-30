
Create View dbo.trav_GlJournalHistorySummary_view
AS
	SELECT j.[Year] AS FiscalYear, j.Period AS FiscalPeriod
		, Count(j.EntryNum) AS JournalEntries
		, SUM(j.DebitAmt) AS TotalDebitAmount, Sum(j.CreditAmt) AS TotalCreditAmount
		FROM dbo.tblGlJrnlHist j
		GROUP BY j.[Year], j.Period
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlJournalHistorySummary_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlJournalHistorySummary_view';

