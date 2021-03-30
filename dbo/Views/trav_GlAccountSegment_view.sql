
Create view dbo.trav_GlAccountSegment_view 
As

Select h.AcctId, p.Number, Substring(h.AcctId, p.Start, p.[Length]) Segment
From dbo.tblGlAcctHdr h (NOLOCK)
CROSS JOIN 
(	Select Number, [Length], [Description]
		, isnull((Select Sum([Length]) 
		From dbo.tblGlAcctMaskSegment s (NOLOCK)
		Where s.Number < t.Number), 0) + 1 Start
	From dbo.tblGlAcctMaskSegment t (NOLOCK)
) p
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlAccountSegment_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlAccountSegment_view';

