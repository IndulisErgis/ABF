
CREATE VIEW dbo.pvtGlJournal
AS
SELECT dbo.tblGlJrnl.EntryNum, dbo.tblGlJrnl.TransDate, dbo.tblGlJrnl.SourceCode
	, dbo.tblGlJrnl.DebitAmt, dbo.tblGlJrnl.CreditAmt, dbo.tblGlJrnl.Period
	, dbo.tblGlJrnl.[Year], dbo.trav_GlAccountHeader_view.AcctIdMasked, dbo.trav_GlAccountHeader_view.[Desc]
FROM dbo.tblGlJrnl 
INNER JOIN dbo.trav_GlAccountHeader_view ON dbo.tblGlJrnl.AcctId = dbo.trav_GlAccountHeader_view.AcctId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtGlJournal';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtGlJournal';

