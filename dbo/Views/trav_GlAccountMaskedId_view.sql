
Create view dbo.trav_GlAccountMaskedId_view 
As
--PET:http://webfront:801/view.php?id=232690

SELECT AcctId
	, [1] 
	+ isnull(FillChar + [2], '')
	+ isnull(FillChar + [3], '') 
	+ isnull(FillChar + [4], '')
	+ isnull(FillChar + [5], '') 
	+ isnull(FillChar + [6], '') 
	+ isnull(FillChar + [7], '') 
	+ isnull(FillChar + [8], '') 
	+ isnull(FillChar + [9], '') 
	+ isnull(FillChar + [10], '') 
	+ isnull(FillChar + [11], '') 
	+ isnull(FillChar + [12], '')
	+ isnull(FillChar + [13], '') 
	+ isnull(FillChar + [14], '')
	+ isnull(FillChar + [15], '') 
	+ isnull(FillChar + [16], '') 
	+ isnull(FillChar + [17], '') 
	+ isnull(FillChar + [18], '') 
	+ isnull(FillChar + [19], '') 
	+ isnull(FillChar + [20], '') 
	+ isnull(FillChar + [21], '') 
	+ isnull(FillChar + [22], '')
	+ isnull(FillChar + [23], '') 
	+ isnull(FillChar + [24], '')
	+ isnull(FillChar + [25], '') 
	+ isnull(FillChar + [26], '') 
	+ isnull(FillChar + [27], '') 
	+ isnull(FillChar + [28], '') 
	+ isnull(FillChar + [29], '') 
	+ isnull(FillChar + [30], '') 
	+ isnull(FillChar + [31], '') 
	+ isnull(FillChar + [32], '')
	+ isnull(FillChar + [33], '') 
	+ isnull(FillChar + [34], '')
	+ isnull(FillChar + [35], '') 
	+ isnull(FillChar + [36], '') 
	+ isnull(FillChar + [37], '') 
	+ isnull(FillChar + [38], '') 
	+ isnull(FillChar + [39], '') 
	+ isnull(FillChar + [40], '') AcctIdMasked
	, [1] Segment1
	, [2] Segment2
	, [3] Segment3
	, [4] Segment4
	, [5] Segment5
	, [6] Segment6
	, [7] Segment7
	, [8] Segment8
	, [9] Segment9
	, [10] Segment10
	, [11] Segment11
	, [12] Segment12
	, [13] Segment13
	, [14] Segment14
	, [15] Segment15
	, [16] Segment16
	, [17] Segment17
	, [18] Segment18
	, [19] Segment19
	, [20] Segment20
	, [21] Segment21
	, [22] Segment22
	, [23] Segment23
	, [24] Segment24
	, [25] Segment25
	, [26] Segment26
	, [27] Segment27
	, [28] Segment28
	, [29] Segment29
	, [20] Segment30
	, [31] Segment31
	, [32] Segment32
	, [33] Segment33
	, [34] Segment34
	, [35] Segment35
	, [36] Segment36
	, [37] Segment37
	, [38] Segment38
	, [39] Segment39
	, [40] Segment40
FROM 
(	SELECT AcctId, Number, Segment, (Select Top 1 Case When isnull(FillChar, '') = '1' Then ' ' Else isnull(FillChar, '') End From dbo.tblGlAcctMask) FillChar
	FROM dbo.trav_GlAccountSegment_view
) p
PIVOT
(
	MAX (Segment)
	FOR Number IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10]
		, [11], [12], [13], [14], [15], [16], [17], [18], [19], [20]
		, [21], [22], [23], [24], [25], [26], [27], [28], [29], [30]
		, [31], [32], [33], [34], [35], [36], [37], [38], [39], [40]
	)
) AS pvt
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlAccountMaskedId_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_GlAccountMaskedId_view';

