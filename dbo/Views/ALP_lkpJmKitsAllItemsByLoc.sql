
  
CREATE View [dbo].[ALP_lkpJmKitsAllItemsByLoc]   
--EFI# 863 Ravi 11/21/2018 - alter 
  as     
SELECT   TOP 100 PERCENT   dbo.tblInItem.ItemId + dbo.tblInItemLoc.LocId AS ItemIdLocId, dbo.tblInItem.ItemId, dbo.tblInItem.KittedYN, dbo.tblInItemLoc.LocId,     
           dbo.tblInItemLoc.ItemLocStatus, dbo.tblInItemLocUomPrice.Uom, dbo.tblInItem.Descr, dbo.tblInItem.UomDflt,     
           dbo.Alp_tblINItem.AlpVendorkitYN  ,   
          -- Below column added by ravi on 12 Sep 2016, to fix bug id 533  
           dbo.Alp_tblINItem.AlpKitUsageRestrictedToPO  ,
           --Below Item status code added by ravi on 21 nov 2018 to fix the bugid 864
          ItemStatus =        Case	WHEN dbo.tblInItem.ItemStatus =1 THEN 'Active'        
											WHEN dbo.tblInItem.ItemStatus =2 THEN 'Discontinued'        
											WHEN dbo.tblInItem.ItemStatus =3 THEN 'Superseded'   WHEN ItemStatus=4 THEN 'Obsolete'     
									END
FROM       dbo.tblInItem INNER JOIN   
--Below join condition changed by ravi on 21 nov 2018 to fix the bugid 863 
           dbo.tblInItemLoc LEFT Outer JOIN    
           dbo.tblInItemLocUomPrice ON dbo.tblInItemLoc.ItemId = dbo.tblInItemLocUomPrice.ItemId AND dbo.tblInItemLoc.ItemId = dbo.tblInItemLocUomPrice.ItemId ON     
           dbo.tblInItem.ItemId = dbo.tblInItemLoc.ItemId INNER JOIN    
           dbo.Alp_tblINItem ON dbo.tblinitem.ItemId =dbo.ALP_tblINItem.AlpItemId    
 ORDER BY dbo.tblInItem.ItemId + dbo.tblInItemLoc.LocId