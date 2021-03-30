Create View [dbo].[ALP_lkpJmKitsKitsByLoc] as
SELECT     TOP 100 PERCENT ItemIdLocId, ItemId, LocId, KittedYN, Descr
FROM         dbo.Alp_lkpJmKitsAllItemsByLoc
GROUP BY ItemIdLocId, ItemId, LocId, KittedYN, AlpVendorKitYn, Descr
HAVING      (KittedYN <> 0) OR
                      (AlpVendorKitYn <> 0)