CREATE View [dbo].[ALP_lkpJmKitsAllItemsByLoc_WithoutUomPriceInfo]    
  as  
  -- View created by ravi on 02 March 2018,  table tblInItemLocUomPrice not used to load the JM Kits screen lkpKit dropdown, changes asked by JOE on same day call
SELECT   TOP 100 PERCENT   dbo.tblInItem.ItemId + dbo.tblInItemLoc.LocId AS ItemIdLocId, dbo.tblInItem.ItemId, dbo.tblInItem.KittedYN, dbo.tblInItemLoc.LocId,     
           dbo.tblInItemLoc.ItemLocStatus,
           -- dbo.tblInItemLocUomPrice.Uom,
             dbo.tblInItem.Descr, dbo.tblInItem.UomDflt,     
           dbo.Alp_tblINItem.AlpVendorkitYN  ,   
          -- Below column added by ravi on 12 Sep 2016, to fix bug id 533  
           dbo.Alp_tblINItem.AlpKitUsageRestrictedToPO  
FROM       dbo.tblInItem INNER JOIN    
           dbo.tblInItemLoc ON    
          -- dbo.tblInItemLocUomPrice ON dbo.tblInItemLoc.ItemId = dbo.tblInItemLocUomPrice.ItemId AND
          -- dbo.tblInItemLoc.ItemId = dbo.tblInItemLocUomPrice.ItemId ON     
           dbo.tblInItem.ItemId = dbo.tblInItemLoc.ItemId INNER JOIN    
           dbo.Alp_tblINItem ON dbo.tblinitem.ItemId =dbo.ALP_tblINItem.AlpItemId    
 ORDER BY dbo.tblInItem.ItemId + dbo.tblInItemLoc.LocId