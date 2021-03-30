
CREATE PROCEDURE dbo.[trav_GlAccountSegmentList_proc]
AS
BEGIN TRY

SELECT s.Number, s.Id, s.Description, m.Description AS MaskDescription 
FROM  dbo.tblGlSegment s INNER JOIN tblGlAcctMaskSegment m ON s.number = m.number 
      INNER JOIN #tmpGlAcctSegment t ON t.Number = s.Number AND t.Id = s.Id

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAccountSegmentList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAccountSegmentList_proc';

