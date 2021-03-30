
CREATE PROCEDURE dbo.trav_MbMediaGroup_Proc 

AS
SET NOCOUNT ON

BEGIN TRY

	-- Media Group
	SELECT g.MGID, g.Descr, g.PrimaryLink
	FROM dbo.tblMbMediaGroups g 
		INNER JOIN #tmpMediaGroup tmp ON tmp.MGID = g.MGID	
		
	-- Media
	SELECT MGID, MID, Notes, Link FROM dbo.tblMbMedia WHERE MGID IN (SELECT MGID FROM #tmpMediaGroup)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbMediaGroup_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbMediaGroup_Proc';

