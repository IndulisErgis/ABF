CREATE VIEW dbo.ALP_stpJmSvcTktItemKit    
--EFI# 1590 MAH 03/15/05 - Pull DfltHrs and DfltPts from Item Loc    
AS    
SELECT  dbo.ALP_tblJmSvcTktItem.TicketId, dbo.ALP_tblJmSvcTktItem.ResolutionId, dbo.ALP_tblJmSvcTktItem.ResDesc,     
 dbo.ALP_tblJmSvcTktItem.CauseId,     
        dbo.ALP_tblJmSvcTktItem.CauseDesc,     
 dbo.ALP_tblJmSvcTktItem.TicketItemId,     
 dbo.ALP_tblJmSvcTktItem.WhseID,     
 dbo.ALP_tblJmKitItemIn.Qty AS QtyAdded,     
        dbo.ALP_tblJmKitItemIn.KitItemId,     
 dbo.ALP_tblJmKitItemIn.Uom,     
 dbo.ALP_tblJmKitItemIn.EquipLoc, dbo.ALP_tblJmKitItemIn.[Zone],     
 dbo.ALP_tblInItemLocation_view.AlpDfltHours,     
        dbo.ALP_tblInItemLocation_view.AlpDfltPts,   
 --mah 01/22/13 - inserted Commercial hrs and pts Defaults:  
 dbo.ALP_tblInItemLocation_view.AlpDfltCommercialHours,     
        dbo.ALP_tblInItemLocation_view.AlpDfltCommercialPts,       
 dbo.ALP_tblJmKitItemIn.KitsItemId,     
 dbo.ALP_tblJmKitItemIn.ItemId,     
 dbo.ALP_tblJmSvcTktItem.KitNestLevel  
,dbo.ALP_tblInItem.AlpPhaseCodeId  -- Added by NSK on 21 Jul 2020 for bug id 1064
FROM         dbo.ALP_tblJmSvcTktItem     
  INNER JOIN    
                      dbo.ALP_tblJmKitItemIn ON dbo.ALP_tblJmSvcTktItem.ItemId = dbo.ALP_tblJmKitItemIn.KitItemId AND     
                      dbo.ALP_tblJmSvcTktItem.WhseID = dbo.ALP_tblJmKitItemIn.KitLocId     
  INNER JOIN    
                      dbo.ALP_tblInItemLocation_view ON dbo.ALP_tblInItemLocation_view.ItemId = dbo.ALP_tblJmKitItemIn.ItemId and     
        dbo.ALP_tblInItemLocation_view.LocId = dbo.ALP_tblJmKitItemIn.KitLocId 
  INNER JOIN dbo.ALP_tblInItem  ON dbo.ALP_tblJmSvcTktItem.ItemId =ALP_tblInItem.AlpItemId --Added by NSK on 21 Jul 2020 for bug id 1064  
--FROM         dbo.ALP_tblJmSvcTktItem INNER JOIN    
--                      dbo.ALP_tblJmKitItemIn ON dbo.ALP_tblJmSvcTktItem.ItemId = dbo.ALP_tblJmKitItemIn.KitItemId AND     
--                      dbo.ALP_tblJmSvcTktItem.WhseID = dbo.ALP_tblJmKitItemIn.KitLocId RIGHT OUTER JOIN    
--                      dbo.tblInItem ON dbo.tblInItem.ItemId = dbo.ALP_tblJmSvcTktItem.ItemId    