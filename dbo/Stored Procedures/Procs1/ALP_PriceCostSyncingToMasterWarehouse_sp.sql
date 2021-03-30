


CREATE procedure [dbo].[ALP_PriceCostSyncingToMasterWarehouse_sp]
(
	@MasterLocId varchar(10)
)
As

CREATE TABLE #TempTable(ItemId varchar(24),LocId varchar(10),
	Uom varchar(5),CostStd pDec,CostBase pDec,PriceBase pDec,PriceList pDec)
	
CREATE TABLE #ABFTemp (ItemId varchar(24),LocId varchar(10),
	Uom varchar(5),CostStd pDec,CostBase pDec,PriceBase pDec,PriceList pDec)

INSERT INTO #TempTable(ItemId,LocId,Uom,CostStd,CostBase,PriceBase,PriceList)
SELECT ILoc.ItemId, ILoc.LocId, Items.UomDflt, ILoc.CostStd, ILoc.CostBase, IPrice.PriceBase, IPrice.PriceList
FROM [dbo].[tblInItemLoc] AS ILoc
INNER JOIN [dbo].[tblInItemLocUomPrice] IPrice ON ILoc.ItemId = IPrice.ItemId AND ILoc.LocId = IPrice.LocId
INNER JOIN [dbo].[tblInItem] Items ON IPrice.ItemId = Items.ItemId
WHERE ILoc.LocId != @MasterLocId AND Items.UomDflt = IPrice.Uom

INSERT INTO #ABFTemp(ItemId,LocId,Uom,CostStd,CostBase,PriceBase,PriceList)
SELECT ILoc.ItemId, ILoc.LocId, Items.UomDflt, ILoc.CostStd, ILoc.CostBase, IPrice.PriceBase, IPrice.PriceList
FROM [dbo].[tblInItemLoc] AS ILoc
INNER JOIN [dbo].[tblInItemLocUomPrice] IPrice ON ILoc.ItemId = IPrice.ItemId AND ILoc.LocId = IPrice.LocId
INNER JOIN [dbo].[tblInItem] Items ON IPrice.ItemId = Items.ItemId
WHERE ILoc.LocId = @MasterLocId AND Items.UomDflt = IPrice.Uom

Update T
SET T.CostStd = A.CostStd, T.CostBase = A.CostBase, T.PriceBase = A.PriceBase, T.PriceList = A.PriceList
FROM #TempTable T
INNER JOIN #ABFTemp A
ON T.ItemId = A.ItemId AND T.Uom = A.Uom

Update L
SET L.CostStd = T.CostStd, L.CostBase = T.CostBase
FROM [dbo].[tblInItemLoc] L
INNER JOIN #TempTable T
ON L.ItemId = T.ItemId AND L.LocId = T.LocId

Update L
SET L.PriceBase = T.PriceBase, L.PriceList = T.PriceList
FROM [dbo].[tblInItemLocUomPrice] L
INNER JOIN #TempTable T
ON L.ItemId = T.ItemId AND L.LocId = T.LocId AND L.Uom = T.Uom