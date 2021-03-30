
CREATE PROCEDURE dbo.trav_BmComponentWhereUsedList_proc 
@SortBy tinyint = 0 -- 0, Item ID; 1, Location ID;
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT CASE WHEN @SortBy = 0 THEN d.ItemId ELSE d.LocId END GrpId1, 
		CASE WHEN @SortBy = 0 THEN d.LocId ELSE d.ItemId END GrpId2, 
		b.BmItemId, b.BmLocId, b.Descr, d.ItemId, d.LocId, d.Quantity, 
		d.Uom, i.Descr AS ItemDesc, l.Descr AS LocDesc
	FROM dbo.tblBmBom b INNER JOIN dbo.tblBmBomDetail d ON b.BmBomId = d.BmBomId 
		INNER JOIN #tmpItemLocationList t ON d.ItemId = t.ItemId AND d.LocId = t.LocId
		INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
		INNER JOIN dbo.tblInLoc l ON d.LocId = l.LocId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmComponentWhereUsedList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmComponentWhereUsedList_proc';

