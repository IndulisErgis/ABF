
CREATE VIEW dbo.pvtGlJournalHist
AS
SELECT dbo.tblGlJrnlHist.EntryNum, dbo.tblGlJrnlHist.TransDate, dbo.tblGlJrnlHist.SourceCode
	, dbo.tblGlJrnlHist.DebitAmt, dbo.tblGlJrnlHist.CreditAmt
	, dbo.tblGlJrnlHist.Period, dbo.tblGlJrnlHist.[Year], dbo.trav_GlAccountHeader_view.AcctIdMasked, dbo.trav_GlAccountHeader_view.[Desc]
FROM dbo.tblGlJrnlHist 
INNER JOIN dbo.trav_GlAccountHeader_view ON dbo.tblGlJrnlHist.AcctId = dbo.trav_GlAccountHeader_view.AcctId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtGlJournalHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtGlJournalHist';

