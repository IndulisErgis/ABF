CREATE View  [dbo].[ALP_lkpJmKitsKitsByLoc_SMSource] as   
SELECT     ItemIdLocId, ItemId, LocId, KittedYN, [Descr] 
FROM         dbo.ALP_lkpJmKitsAllItemsByLoc_SMSource  
GROUP BY ItemIdLocId, ItemId, LocId, KittedYN, AlpVendorKitYn, [Descr]  
HAVING      (KittedYN <> 0) OR  
                      (AlpVendorKitYn <> 0)