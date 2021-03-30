
Create view dbo.trav_GlJournal_Account_view 
As

SELECT j.EntryNum, j.CompId, j.EntryDate, j.TransDate, j.PostedYn, j.[Desc], j.SourceCode, j.Reference, j.AcctId, t.AcctClassId,
	j.Period, j.[Year], j.AllocateYn, j.ChkRecon, j.CashFlow, j.LinkID, j.LinkIDSub, j.LinkIDSubLine, j.PostRun, 
	j.CurrencyID, j.URG, h.AcctIdMasked, h.Segment1, h.Segment2, h.Segment3, h.Segment4, h.Segment5, h.Segment6, h.Segment7, h.Segment8,
	h.Segment9, h.Segment10, h.Segment11, h.Segment12, h.Segment13, h.Segment14, h.Segment15, h.Segment16, h.Segment17, h.Segment18,
	h.Segment19, h.Segment20, h.Segment21, h.Segment22, h.Segment23, h.Segment24, h.Segment25, h.Segment26, h.Segment27, h.Segment28,
	h.Segment29, h.Segment30, h.Segment31, h.Segment32, h.Segment33, h.Segment34, h.Segment35, h.Segment36, h.Segment37, h.Segment38,
	h.Segment39, h.Segment40, a.AcctTypeId, a.BalType, a.Status
FROM dbo.tblGlJrnl j INNER JOIN dbo.tblGlAcctHdr a ON j.AcctId = a.AcctId 
	INNER JOIN trav_GlAccountMaskedId_view h ON a.AcctId = h.AcctId
	LEFT JOIN dbo.tblGlAcctType t on a.AcctTypeId = t.AcctTypeId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlJournal_Account_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlJournal_Account_view';

