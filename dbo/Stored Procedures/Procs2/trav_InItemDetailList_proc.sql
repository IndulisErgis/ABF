
CREATE PROCEDURE [dbo].[trav_InItemDetailList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

		--Generat Information
		SELECT i.ItemId, i.Descr, i.SuperId, i.ItemType, i.ItemStatus, ISNULL(i.ProductLine,'') AS ProductLine, 
			  i.SalesCat, i.PriceId, i.TaxClass, i.UomBase, i.UomDflt, i.LottedYN, i.AutoReorderYN, 
			  i.ResaleYN, i.PictId, h.HMCode, i.CostMethodOverride, i.CommodityCode 
		FROM tblInItem i (NOLOCK) INNER JOIN #tmpItemList t ON i.ItemId = t.ItemId  
			LEFT JOIN dbo.tblInHazMat h (NOLOCK) ON i.HMRef = h.HMRef

		--Additional Description
		SELECT a.ItemId, AddlDescr FROM dbo.tblInItemAddlDescr a INNER JOIN #tmpItemList t ON a.ItemId = t.ItemId
 
		--Units of Measure
		SELECT i.ItemId, u.Uom, u.ConvFactor, u.PenaltyType, u.PenaltyAmt, u.UPCcode, u.Weight, u.MinSaleQty 
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId 
			INNER JOIN #tmpItemList t ON i.ItemId = t.ItemId
 
		--Unit Defaults
		SELECT i.ItemId, u.DfltType, u.Uom AS DfltTypeUom 
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemUomDflt u ON i.ItemId = u.ItemId 
			INNER JOIN #tmpItemList t ON i.ItemId = t.ItemId
		
		--Alternate Items
		SELECT i.ItemId, a.AltItemId, a.DateStart, a.DateEnd 
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemAlt a ON i.ItemId = a.ItemId 
			INNER JOIN #tmpItemList t ON i.ItemId = t.ItemId

		--Aliases
		SELECT i.ItemId, a.AliasId, a.AliasType, a.RefId 
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemAlias a ON i.ItemId = a.ItemId 
			INNER JOIN #tmpItemList t ON i.ItemId = t.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemDetailList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemDetailList_proc';

