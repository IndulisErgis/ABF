
CREATE PROCEDURE [dbo].[trav_GlTransAllocationList_proc]
AS
SET NOCOUNT ON

BEGIN TRY



		SELECT     AllocationId, Description, d.AllocPct, replace(d.segments,' ','X') as Segments,h.ExpDate,h.Notes
FROM         #tmpTransAllocList AS h INNER JOIN
                      tblGlAllocTransDtl AS d ON h.AllocationId = d.TransAllocId
                      

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlTransAllocationList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlTransAllocationList_proc';

