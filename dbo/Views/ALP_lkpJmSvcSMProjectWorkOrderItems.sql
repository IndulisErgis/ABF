CREATE VIEW dbo.ALP_lkpJmSvcSMProjectWorkOrderItems                      
AS                      
--JAL Added PartPulledDate 9/11/03                      
--EFI# 1528 MAH 11/17/04 - do not display items that are part of a Vendor Kit.                       
SELECT     TOP 100 PERCENT dbo.ALP_tblJmSvcTktItem.TicketItemId, dbo.ALP_tblJmSvcTktItem.TicketId, dbo.ALP_tblJmResolution.[Action], dbo.ALP_tblJmSvcTktItem.ItemId,                       
                      dbo.ALP_tblJmSvcTktItem.[Desc], dbo.ALP_tblJmSvcTktItem.QtyAdded, dbo.ALP_tblJmSvcTktItem.KittedYN, dbo.ALP_tblJmSvcTktItem.EquipLoc,                       
                      dbo.ALP_tblJmSvcTktItem.Uom, dbo.ALP_tblJmSvcTktItem.PartPulledDate                     
                      --Below line added by NSK on 15 Oct 2014                    
                      ,dbo.ALP_tblJmSvcTkt.ProjectId                     
                     , tblInItemLoc.DfltBinNum, ALP_tblArAlpSysType.SysType,                
                       dbo.ALP_tblJmSvcTktItem.ItemType,                
                        ALP_tblJmPhase.Phase,          
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
 --Added by NSK on 31 Aug 2016 for bug id 524.          
  --start          
  ,ALP_tblJmSvcTktItem.BinNumber,ALP_tblJmSvcTktItem.BODate,        
   ALP_tblJmSvcTktItem.StagedDate,ALP_tblJmSvcTktItem.OldTicketId,ALP_tblJmSvcTkt.Status          
  --end     
  --Added by NSK on 17 Dec 2018 for bug id 868  
  --start  
  ,ALP_tblJmSvcTktItem.HoldInvCommitted  
  ,ALP_tblJmSvcTktItem.KitNestLevel
  --end                
FROM           
       --ALP_tblJmPhase INNER JOIN --Commented by NSK on 16 Aug 2016 for bug id 514               
                      --ALP_tblSmItem ON ALP_tblJmPhase.PhaseId = ALP_tblSmItem.AlpPhaseCodeID RIGHT OUTER JOIN --Commented by NSK on 16 Aug 2016 for bug id 514                       
                      --Below from modified by NSK on 16 Aug 2016 for bug id 514.        
                      ALP_tblJmSvcTktItem                
                      INNER JOIN ALP_tblJmSvcTkt ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId                 
                      INNER JOIN ALP_tblArAlpSiteSys ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId                 
                      INNER JOIN ALP_tblArAlpSysType ON ALP_tblArAlpSiteSys.SysTypeId = ALP_tblArAlpSysType.SysTypeId --ON          
                      LEFT OUTER JOIN ALP_tblJmResolution ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId                  
                      LEFT OUTER JOIN ALP_tblJmPhase ON ALP_tblJmSvcTktItem.PhaseId = ALP_tblJmPhase.PhaseId          
                      LEFT OUTER JOIN ALP_tblSmItem ON  ALP_tblJmSvcTktItem.ItemId = ALP_tblSMItem.AlpItemCode                
                      LEFT OUTER JOIN  tblInItemLoc ON ALP_tblJmSvcTktItem.ItemId = tblInItemLoc.ItemId AND ALP_tblJmSvcTktItem.EquipLoc = tblInItemLoc.LocId                
WHERE                
--below action condition modified by NSK on 19 May 2015 to display the replace action data.              
--Below KittedYN,AlpVendorKitComponentYn checked is null. Modified by NSK on 19 May 2015               
(dbo.ALP_tblJmResolution.[Action] = 'Add' OR dbo.ALP_tblJmResolution.[Action] = 'Replace')                       
AND (dbo.ALP_tblJmSvcTktItem.KittedYN = 0 or dbo.ALP_tblJmSvcTktItem.KittedYN is null)                      
AND (dbo.ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 or dbo.ALP_tblJmSvcTktItem.AlpVendorKitComponentYn is null)                      
ORDER BY dbo.ALP_tblJmSvcTktItem.TicketItemId