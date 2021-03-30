
Create view dbo.trav_GlAccountHeader_view 
As

SELECT h.AcctId, h.[Desc], h.AcctTypeId, t.AcctClassId, h.BalType, h.ClearToAcct, h.ClearToStep, h.ConsolToAcct, h.ConsolToStep, 
	h.[Status], h.CurrencyID, m.AcctIdMasked, m.Segment1, m.Segment2, m.Segment3, m.Segment4, m.Segment5, m.Segment6, m.Segment7, m.Segment8,
	m.Segment9, m.Segment10, m.Segment11, m.Segment12, m.Segment13, m.Segment14, m.Segment15, m.Segment16, m.Segment17, m.Segment18,
	m.Segment19, m.Segment20, m.Segment21, m.Segment22, m.Segment23, m.Segment24, m.Segment25, m.Segment26, m.Segment27, m.Segment28,
	m.Segment29, m.Segment30, m.Segment31, m.Segment32, m.Segment33, m.Segment34, m.Segment35, m.Segment36, m.Segment37, m.Segment38,
	m.Segment39, m.Segment40
FROM dbo.tblGlAcctHdr h INNER JOIN dbo.trav_GlAccountMaskedId_view m ON h.AcctId = m.AcctId
LEFT JOIN dbo.tblGlAcctType t on h.AcctTypeId = t.AcctTypeId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlAccountHeader_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlAccountHeader_view';

