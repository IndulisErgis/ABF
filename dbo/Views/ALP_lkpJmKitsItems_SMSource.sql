  CREATE View [dbo].[ALP_lkpJmKitsItems_SMSource] as   
SELECT DISTINCT ItemId, LocId, [Descr]  , KittedYN, UomDflt,  
  CASE KittedYN WHEN 0  THEN 'Item' ELSE 'Kit' END AS [Type]  
FROM         dbo.ALP_lkpJmKitsAllItemsByLoc_SMSource  
WHERE     (ItemLocStatus = 1)  
GROUP BY ItemId, LocId, [Descr], KittedYN, UomDflt