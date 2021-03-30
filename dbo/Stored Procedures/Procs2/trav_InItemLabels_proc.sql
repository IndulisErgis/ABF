
CREATE PROCEDURE dbo.trav_InItemLabels_proc
@SortBy tinyint = 0, -- 0=Item ID;1=Product Line;2=Location ID
@RecordCount int = NULL
AS
SET NOCOUNT ON
BEGIN TRY

	--use the option setting to set the number of rows to return
	IF ISNULL(@RecordCount, 0) > 0 Set RowCount @RecordCount

	SELECT i.ItemId, i.Descr AS [Description], l.LocId, o.Descr AS [LocationDescription]
		, i.ProductLine, i.SalesCat, l.DfltBinNum, i.UomBase, i.UomDflt
		, h.HMCode, h.Descr AS [HazMatDescription]
		, i.UsrFld1, i.UsrFld2
		, CASE @SortBy WHEN 1 THEN i.ProductLine WHEN 2 THEN l.LocId ELSE i.ItemId END AS [OrderBy]
		, base.UPCcode AS UPCCodeBase, dflt.UPCcode AS UPCCodeDflt, i.CommodityCode 
		FROM dbo.tblInItem i
		INNER JOIN dbo.tblInItemLoc l on i.ItemId = l.ItemId
		INNER JOIN #tmpItemLocationList t on l.ItemId = t.ItemId and l.LocId = t.LocId
		LEFT JOIN dbo.tblInLoc o on l.LocId = o.LocId
		LEFT JOIN dbo.tblInHazMat h on i.HMRef = h.HMRef 
		LEFT JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND i.UomBase = base.Uom 
		LEFT JOIN dbo.tblInItemUom dflt ON i.ItemId = dflt.ItemId AND i.UomDflt = dflt.Uom 
	ORDER BY CASE @SortBy WHEN 1 THEN i.ProductLine WHEN 2 THEN l.LocId ELSE i.ItemId END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemLabels_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemLabels_proc';

