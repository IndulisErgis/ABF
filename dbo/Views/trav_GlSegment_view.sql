
Create view dbo.trav_GlSegment_view 
As

SELECT s.Number, s.Id, s.[Description], m.Description SegmentDescription,
	m.Abbreviation
FROM dbo.tblGlSegment s INNER JOIN dbo.tblGlAcctMaskSegment m 
ON s.Number = m.Number
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlSegment_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlSegment_view';

