CREATE View [dbo].[ALP_lkpJmKitsKitsByLoc_WithoutUomPriceInfo] as 
--Below table changed by ravi on 2nd march 2018,to load the Jm Kits screen lkpKit dropdown, 
SELECT     TOP 100 PERCENT ItemIdLocId, ItemId, LocId, KittedYN, Descr
  --Below table changed by ravi on 2nd march 2018,
FROM ALP_lkpJmKitsAllItemsByLoc_WithoutUomPriceInfo
--FROM         dbo.Alp_lkpJmKitsAllItemsByLoc  
GROUP BY ItemIdLocId, ItemId, LocId, KittedYN, AlpVendorKitYn, Descr  
HAVING      (KittedYN <> 0) OR  (AlpVendorKitYn <> 0)