
CREATE procedure [dbo].[ALP_PriceCostSyncing_sp]
(
	@ItemId varchar(24),
	@LocId varchar(10)
)
As

DECLARE @StdCostToSet [pDec],
		@BaseCostToSet [pDec],
		@ListPriceToSet [pDec],
		@BasePriceToSet [pDec]

SELECT @StdCostToSet = CostStd, @BaseCostToSet = CostBase
	FROM [dbo].[tblInItemLoc]
	WHERE LocId = 'ABF' and ItemId = @ItemId

UPDATE [dbo].[tblInItemLoc]
SET CostStd = @StdCostToSet, CostBase = @BaseCostToSet
WHERE LocId = @LocId AND ItemId = @ItemId

SELECT @ListPriceToSet = PriceList, @BasePriceToSet = PriceBase
	FROM [dbo].[tblInItemLocUomPrice] P
	INNER JOIN [dbo].[tblInItem] I ON P.ItemId = I.ItemId
	WHERE P.LocId = 'ABF' and P.ItemId = @ItemId and I.UomDflt = P.Uom
  
UPDATE [dbo].[tblInItemLocUomPrice]
SET PriceBase = @BasePriceToSet, PriceList = @ListPriceToSet
FROM [dbo].[tblInItemLocUomPrice] P
INNER JOIN [dbo].[tblInItem] I ON P.ItemId = I.ItemId
WHERE P.LocId = @LocId AND P.ItemId = @ItemId and I.UomDflt = P.Uom