
CREATE PROCEDURE dbo.trav_InItemSummaryList_proc
@SortBy tinyint = 0 -- 0, Item ID; 1, Product Line;
--todo, user defined fields
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT CASE @SortBy 
			WHEN 0 THEN i.ItemId 
			WHEN 1 THEN ISNULL(i.ProductLine, '') END AS SortBy,
		i.ItemId, i.Descr, i.ItemType, i.ItemStatus, ISNULL(i.ProductLine, '') AS ProductLine, i.SalesCat,
		i.PriceId, i.TaxClass, i.UomBase, i.UomDflt, i.LottedYN, i.AutoReorderYN, h.HMCode 
	FROM #tmpItemList t INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId
		LEFT JOIN dbo.tblInHazMat h ON i.HMRef = h.HMRef 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemSummaryList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemSummaryList_proc';

