
CREATE PROCEDURE dbo.trav_GlRecurringEntriesList_proc
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT h.GroupId, h.[Desc] AS HeaderDesc, LineNum, d.[Desc] AS DetailDesc, Reference, AcctNum
		, SourceCode, Alloc, DebitAmt, CreditAmt 
	FROM #tmpRecurList t INNER JOIN dbo.tblGlRecurHdr h ON t.GroupId = h.GroupId 
		INNER JOIN dbo.tblGlRecurDtl d ON h.GroupId = d.GroupId 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlRecurringEntriesList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlRecurringEntriesList_proc';

