
CREATE View [dbo].[ALP_lkpJmKitsItems] 
	--EFI# 864 Ravi 11/21/2018 - alter 
	as                           
SELECT DISTINCT ItemId, LocId, Descr, KittedYN, UomDflt,    
  CASE KittedYN WHEN 0  THEN 'Item' ELSE 'Kit' END AS [Type] 
    --Below Item status code added by ravi on 21 nov 2018 to fix the bugid 864 
   ,  ItemStatus
FROM         dbo.ALP_lkpJmKitsAllItemsByLoc    
WHERE     (ItemLocStatus = 1)    
--Below additional condition added by ravi on 14 sep 2016, to fix the bug id 533  
 and AlpVendorKitYN =0  OR   
   (  AlpVendorKitYN <> 0 AND AlpKitUsageRestrictedToPO =0 )     
GROUP BY ItemId, LocId, Descr, KittedYN, UomDflt    ,  ItemStatus