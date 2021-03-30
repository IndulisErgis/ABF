
CREATE PROCEDURE dbo.trav_BmBomExplorer_proc
AS
SET NOCOUNT ON
BEGIN TRY

SELECT h.BmBomId, h.BmItemId, h.BmLocId, h.Descr, h.Uom, i.Descr ItemDescr, 
	ISNULL(i.KittedYN,0) KittedYN, l.Descr LocDescr
FROM #tmpBOMList t INNER JOIN dbo.tblBmBom h ON t.BmBomId = h.BmBomId 
	LEFT JOIN dbo.tblInItem i ON h.BmItemId = i.ItemId
	LEFT JOIN dbo.tblInLoc l ON h.BmLocId = l.LocId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmBomExplorer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmBomExplorer_proc';

