CREATE VIEW dbo.ALP_lkpJmSvcWorkOrderItems          
AS          
--JAL Added PartPulledDate 9/11/03          
--EFI# 1528 MAH 11/17/04 - do not display items that are part of a Vendor Kit.           
SELECT     TOP 100 PERCENT dbo.ALP_tblJmSvcTktItem.TicketItemId, dbo.ALP_tblJmSvcTktItem.TicketId, dbo.ALP_tblJmResolution.[Action], dbo.ALP_tblJmSvcTktItem.ItemId,           
                      dbo.ALP_tblJmSvcTktItem.[Desc], dbo.ALP_tblJmSvcTktItem.QtyAdded, dbo.ALP_tblJmSvcTktItem.KittedYN, dbo.ALP_tblJmSvcTktItem.EquipLoc,           
                      dbo.ALP_tblJmSvcTktItem.Uom, dbo.ALP_tblJmSvcTktItem.PartPulledDate         
                      --Below line added by NSK on 15 Oct 2014        
                      ,dbo.ALP_tblJmSvcTkt.ProjectId,  
                      --added by NSK on 26 May 2015  
--start  
 CASE        
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS Null OR KitRef = '') THEN 'K'        
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS not Null OR KitRef <> '') THEN 'CK'        
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS Null OR KitRef = '') THEN 'V'        
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS not Null OR KitRef <> '') THEN 'CV'        
  WHEN KitRef IS Not Null OR KitRef <> '' THEN 'C'        
  ELSE ''        
 END AS KorC     
 --end     
 ,ALP_tblJmSvcTktItem.BinNumber,ALP_tblJmSvcTktItem.StagedDate,ALP_tblJmSvcTktItem.BODate --Added by NSK on 25 Aug 2016 for bug id 523         
FROM   dbo.ALP_tblJmResolution INNER JOIN          
                      dbo.ALP_tblJmSvcTktItem ON dbo.ALP_tblJmResolution.ResolutionId = dbo.ALP_tblJmSvcTktItem.ResolutionId            
                      --Below line added by NSK on 15 Oct 2014 to add the projectid        
                      inner join dbo.ALP_tblJmSvcTkt on dbo.ALP_tblJmSvcTkt.TicketId=dbo.ALP_tblJmSvcTktItem.TicketId        
-- Below action condition modified by NSK on 18 May 2015 to add replace action records.         
-- Below KittedYN,AlpVendorKitComponentYn checked is null. Modified by NSK on 19 May 2015                       
WHERE  (dbo.ALP_tblJmResolution.[Action] = 'Add' or  dbo.ALP_tblJmResolution.[Action] = 'Replace')           
AND (dbo.ALP_tblJmSvcTktItem.KittedYN = 0 or dbo.ALP_tblJmSvcTktItem.KittedYN is null)          
AND (dbo.ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 or dbo.ALP_tblJmSvcTktItem.AlpVendorKitComponentYn is null)          
ORDER BY dbo.ALP_tblJmSvcTktItem.TicketItemId