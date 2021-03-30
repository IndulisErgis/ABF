
Create View dbo.trav_GlJournalSummary_view
AS
	SELECT j.[Year] AS FiscalYear, j.Period AS FiscalPeriod
		, SUM(Case When j.PostedYn = 0 Then 0 Else Case When j.AllocateYn = 0 OR a.AcctId IS NULL THEN 0 ELSE 1 END END) AS PostedAllocationEntries
		, SUM(Case When j.PostedYn <> 0 Then 0 Else Case When j.AllocateYn = 0 OR a.AcctId IS NULL THEN 0 ELSE 1 END END) AS UnpostedAllocationEntries
		, Sum(Case When j.PostedYn <> 0 Then 1 Else 0 End) AS PostedEntries
		, Sum(Case When j.PostedYn = 0 Then 1 Else 0 End) AS UnPostedEntries
		, SUM(Case When h.BalType <> 0 AND j.PostedYn <> 0 Then j.DebitAmt Else 0 End ) AS PostedDebitAmount
		, SUM(Case When h.BalType <> 0 AND j.PostedYn = 0 Then j.DebitAmt Else 0 End ) AS UnPostedDebitAmount
		, SUM(Case When h.BalType <> 0 AND j.PostedYn <> 0 Then j.CreditAmt Else 0 End ) AS PostedCreditAmount
		, SUM(Case When h.BalType <> 0 AND j.PostedYn = 0 Then j.CreditAmt Else 0 End ) AS UnPostedCreditAmount
		, SUM(Case When h.BalType = 0 AND j.PostedYn <> 0 Then j.CreditAmt Else 0 End ) AS PostedMemoAmount
		, SUM(Case When h.BalType = 0 AND j.PostedYn = 0 Then j.CreditAmt Else 0 End ) AS UnPostedMemoAmount
		FROM dbo.tblGlJrnl j 
		INNER JOIN dbo.tblGlAcctHdr h ON j.AcctId = h.AcctId
		LEFT JOIN dbo.tblGlAllocHdr a ON j.AcctId = a.AcctId
		GROUP BY j.[Year], j.Period
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlJournalSummary_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlJournalSummary_view';

