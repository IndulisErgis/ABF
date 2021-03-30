CREATE  VIEW dbo.ALP_stpJmSvcTktReplaceItems AS                         
SELECT ALP_tblJmResolution.Action, ALP_tblJmSvcTktItem.TicketItemId, ALP_tblJmSvcTktItem.TicketId,                        
 ALP_tblJmSvcTktItem.ResolutionId, ALP_tblJmSvcTktItem.ResDesc, ALP_tblJmSvcTktItem.CauseId, ALP_tblJmSvcTktItem.CauseDesc,                        
 ALP_tblJmSvcTktItem.SelectFromInvYn, ALP_tblJmSvcTktItem.ItemNotInListYn,             
 ALP_tblJmSvcTktItem.ItemId as 'NewItemId', ALP_tblJmSvcTktItem.KitRef,                        
 ALP_tblJmSvcTktItem.[Desc]  as 'NewItemDesc', ALP_tblJmSvcTktItem.TreatAsPartYN, ALP_tblJmSvcTktItem.WhseID,             
 ALP_tblJmSvcTktItem.QtyAdded as 'NewQty',             
 ALP_tblJmSvcTktItem.ItemId as 'ExistingNewItemId',          
 ALP_tblJmSvcTktItem.ItemId as 'DBNewItemId',          
 ALP_tblJmSvcTktItem.QtyAdded as 'ExistingNewQty',         
       
CASE       
  --WHEN ALP_tblJmSvcTktReplaceItem.OriginalSysItemId ='' THEN ALP_tblJmSvcTktItem.SysItemId       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalSysItemId IS NULL then ALP_tblJmSvcTktItem.SysItemId      
  ELSE ALP_tblJmSvcTktReplaceItem.OriginalSysItemId      
END as ExistingOrgSysItemId ,         
 --ALP_tblJmSvcTktReplaceItem.OriginalSysItemId  as 'ExistingOrgSysItemId',            
 --ALP_tblJmSvcTktReplaceItem.OriginalSysItemId as 'OrgSysItemId',        
        
CASE       
  --WHEN ALP_tblJmSvcTktReplaceItem.OriginalSysItemId = '' THEN ALP_tblJmSvcTktItem.SysItemId       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalSysItemId  IS Null then ALP_tblJmSvcTktItem.SysItemId      
  ELSE ALP_tblJmSvcTktReplaceItem.OriginalSysItemId      
END as OrgSysItemId ,       
       
               
 ALP_tblJmSvcTktItem.SysItemId as 'NewSysItemId',          
 ALP_tblJmSvcTktItem.SysItemId as 'ExistingNewSysItemId',         
 ALP_tblJmSvcTktItem.QtyRemoved, ALP_tblJmSvcTktItem.QtyServiced,                         
ALP_tblJmSvcTktItem.SerNum, ALP_tblJmSvcTktItem.EquipLoc as NewEquipLoc, ALP_tblJmSvcTktItem.WarrExpDate, ALP_tblJmSvcTktItem.CopyToYN,                        
 ALP_tblJmSvcTktItem.UnitPrice, ALP_tblJmSvcTktItem.UnitCost, ALP_tblJmSvcTktItem.UnitPts, ALP_tblJmSvcTktItem.Comments,                        
 ALP_tblJmSvcTktItem.Zone as NewZone, ALP_tblJmSvcTktItem.ItemType                        
, ALP_tblJmSvcTktItem.KittedYN, ALP_tblJmSvcTktItem.SysItemId, ALP_tblJmSvcTktItem.PanelYN, ALP_tblJmSvcTktItem.Uom as NewUom,                        
 ALP_tblJmSvcTktItem.PartPulledDate, ALP_tblJmSvcTktItem.CosOffset, ALP_tblJmSvcTktItem.UnitHrs,                        
 ALP_tblJmSvcTktItem.AlpVendorKitYn, ALP_tblJmSvcTktItem.AlpVendorKitComponentYn                        
, ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, ALP_tblJmSvcTktItem.QtySeqNum_InUse, ALP_tblJmSvcTktItem.LineNumber,                        
 ALP_tblJmSvcTktItem.KitNestLevel, ALP_tblJmSvcTktItem.PrintOnInvoice ,ALP_tblJmSvcTktItem.ts      ,                
 ALP_tblJmSvcTktItem.PhaseId,ALP_tblJmSvcTktItem.BinNumber,ALP_tblJmSvcTktItem.StagedDate,ALP_tblJmSvcTktItem.BODate --Added by NSK on 22 Aug 2016 for bug id 522.                  
 ,ALP_tblJmSvcTktItem.UnitPriceIsFinalSalePrice -- Added by NSK on 03 Nov 2016 for bug id 556.                      
 ,ALP_tblJmResolution.ResolutionCode -- Added by NSK on 08 Nov 2017 for TOA             
 --Added by NSK for bug id 678 on 19 Jan 2018            
 --start             
 --,ALP_tblArAlpSiteSysItem.ItemId            
,CASE       
  WHEN ALP_tblArAlpSiteSysItem.ItemId ='' THEN ALP_tblJmSvcTktItem.ItemId       
  WHEN ALP_tblArAlpSiteSysItem.ItemId IS NULL then ALP_tblJmSvcTktItem.ItemId      
  ELSE ALP_tblArAlpSiteSysItem.ItemId      
END as ItemId       
 --,ALP_tblArAlpSiteSysItem.[Desc]       
 ,CASE       
  WHEN ALP_tblArAlpSiteSysItem.[Desc] ='' THEN ALP_tblJmSvcTktItem.[Desc]       
  WHEN ALP_tblArAlpSiteSysItem.[Desc] IS NULL then ALP_tblJmSvcTktItem.[Desc]      
  ELSE ALP_tblArAlpSiteSysItem.[Desc]      
END as [Desc]            
 --,ALP_tblJmSvcTktReplaceItem.OriginalItemQty as 'QtyAdded'   
 ,CASE       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalItemQty ='' THEN ALP_tblJmSvcTktItem.QtyAdded       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalItemQty IS NULL then ALP_tblJmSvcTktItem.QtyAdded      
  ELSE ALP_tblJmSvcTktReplaceItem.OriginalItemQty      
END as 'QtyAdded'        
 --,ALP_tblArAlpSiteSysItem.RemoveYN        
 ,CASE       
  --WHEN ALP_tblArAlpSiteSysItem.RemoveYN ='' THEN 1       
  WHEN ALP_tblArAlpSiteSysItem.RemoveYN IS NULL then 1      
  ELSE ALP_tblArAlpSiteSysItem.RemoveYN      
END as RemoveYN      
 ,ALP_tblJmSvcTktReplaceItem.OriginalEquipLoc as EquipLoc--ALP_tblArAlpSiteSysItem.EquipLoc        
 ,ALP_tblJmSvcTktReplaceItem.OriginalZone as Zone--ALP_tblArAlpSiteSysItem.Zone        
 ,CASE       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalSysItemId ='' THEN 'Yes'       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalSysItemId IS NULL then 'Yes'      
  ELSE 'No'      
END as LegacyRecord       
,CASE       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalUom ='' THEN ALP_tblJmSvcTktItem.Uom       
  WHEN ALP_tblJmSvcTktReplaceItem.OriginalUom IS NULL then ALP_tblJmSvcTktItem.Uom      
  ELSE ALP_tblJmSvcTktReplaceItem.OriginalUom      
END as 'Uom'        
 --end    
 --Added by NSK on 10 Apr 2019 for bug id 902  
 --start  
 ,ALP_tblJmSvcTktItem.ExtSalePrice as ExistingSalePrice   
 ,ALP_tblJmSvcTktItem.ExtSalePriceFlg 
 --end          
FROM         
--dbo.ALP_tblJmResolution RIGHT OUTER JOIN dbo.ALP_tblJmSvcTktItem            
-- ON dbo.ALP_tblJmResolution.ResolutionId= dbo.ALP_tblJmSvcTktItem.ResolutionId             
--inner join ALP_tblArAlpSiteSysItem             
--on ALP_tblJmSvcTktItem.SysItemId = ALP_tblArAlpSiteSysItem.SysItemId        
ALP_tblJmSvcTktReplaceItem LEFT OUTER JOIN        
                      ALP_tblArAlpSiteSysItem ON ALP_tblJmSvcTktReplaceItem.OriginalSysItemId = ALP_tblArAlpSiteSysItem.SysItemId RIGHT OUTER JOIN        
                      ALP_tblJmSvcTktItem ON ALP_tblJmSvcTktReplaceItem.TicketItemId = ALP_tblJmSvcTktItem.TicketItemId LEFT OUTER JOIN        
                      ALP_tblJmResolution ON ALP_tblJmSvcTktItem.ResolutionId = ALP_tblJmResolution.ResolutionId