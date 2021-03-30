
CREATE PROCEDURE [trav_GlAccountAllocationList_proc]
AS
BEGIN TRY

	SELECT h.AcctId, h.[Desc] AS AllocDesc, a.[Desc] AS AcctDesc, d.AllocToAcctId, d.AllocPct 
	FROM (dbo.tblGlAcctHdr a INNER JOIN dbo.tblGlAllocHdr h ON a.AcctId = h.AcctId) 
		INNER JOIN dbo.tblGlAllocDtl d ON h.AcctId = d.AcctId 
		INNER JOIN #tmpGlAcctAlloc t ON h.AcctId = t.AcctId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAccountAllocationList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAccountAllocationList_proc';

