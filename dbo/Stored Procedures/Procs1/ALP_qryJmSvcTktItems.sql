CREATE PROCEDURE dbo.ALP_qryJmSvcTktItems                                
-- EFI# 1063 MAH 10/20/04 - added UOM                                 
-- EFI# 1528 MAH 11/17/04 - vendor kits                                
-- EFI# 1529 MAH 12/16/04 - JM-IN Interface                                
-- EFI# 1632 MAH 11/02/05 - Allowing Kit within Kit processing                                
-- EFI# 1613 MAH 12/23/05 - Split out Other Labor ( ex EngLabor ) items from 'Other' category                                
-- EFIX NSK 08.27.2014 - UOMBase Column added                              
--TOA Change RAVI 11/03/17 - Use zone column in TOA development            
--TOA Change RAVI 12/12/17-  columns add (SerNum,CopyToYN,WhseID,PanelYN) Added by Ravi on 12 Dec 2017             
--TOA Change RAVI 12/27/17-  KitRef column added by Ravi            
@ID int                                
As                                
SET NOCOUNT ON                                
SELECT ALP_tblJmSvcTktItem.ResDesc, ALP_tblJmCauseCode.CauseCode, ALP_tblJmSvcTktItem.[Desc],                                 
 ALP_tblJmSvcTktItem.EquipLoc, coalesce(UnitPts, 0) AS Pts, coalesce(UnitHrs, 0) AS Hrs,                                 
 CASE                                
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS Null OR KitRef = '') THEN 'K'                                
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS not Null OR KitRef <> '') THEN 'CK'                                
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS Null OR KitRef = '') THEN 'V'                                
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS not Null OR KitRef <> '') THEN 'CV'                                
  WHEN KitRef > 0 THEN 'C' --added by NSK on 08 Sep 2016.                    
  --WHEN KitRef IS Not Null OR KitRef <> ''  THEN 'C' --  commented by NSK on 08 Sep 2016.                             
  ELSE ''                                
 END AS KorC,                                 
 CASE                                 
  WHEN TreatAsPartYN = 1 THEN 'Yes'                                
  ELSE 'No'                                
 END AS TreatAsPartYn,                                
 CASE                                
--EFI# 1613 MAH 12/23/05 - changed:                                
--  WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 1 THEN 'Part'                                
--  WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 0 THEN 'Other'                                
--  ELSE ''                                
  WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 1 THEN 'Part'                                
  WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 0                                 
   AND ALP_tblInItem_view.ItemType = 3 AND ALP_tblInItem_view.AlpServiceType = 1  THEN 'OtherLabor'                                
  ELSE 'Other'                                
 END AS Type,                                
 CASE                                 
  WHEN Uom is null THEN ''                                
  ELSE Uom                                
 End AS Uom,                                
 CASE                                
  WHEN [Action] = 'Add' THEN QtyAdded                                
  WHEN [Action] = 'Replace' THEN QtyAdded                                
  WHEN [Action] = 'Remove' THEN QtyAdded                                
  WHEN [Action] = 'Service' THEN QtyServiced                                
  ELSE 1                                 
 END AS Qty,                                
 coalesce(ALP_tblJmSvcTktItem.UnitPrice, 0) AS Price,  coalesce(ALP_tblJmSvcTktItem.UnitCost, 0) AS Cost,                                 
  ALP_tblJmSvcTkt.PriceMethod, ALP_tblJmSvcTktItem.TicketItemId, ALP_tblJmSvcTktItem.TicketId,                                
-- EFI# 1529 MAH 12/16/04 - added:                                
 ALP_tblJmSvcTktItem.ItemId,                             
 ALP_tblJmSvcTktItem.WhseId,                                
     ALP_tblJmSvcTktItem.PartPulledDate,                                 
     ALP_tblJmSvcTktItem.AlpVendorKitYn,               
     ALP_tblJmSvcTktItem.AlpVendorKitComponentYn,                                 
     ALP_tblJmSvcTktItem.QtySeqNum_Cmtd,                                 
     ALP_tblJmSvcTktItem.QtySeqNum_InUse,                                
 [Action],ALP_tblJmSvcTktItem.LineNumber,ALP_tblJmSvcTktItem.KitNestLevel,ALP_tblJmSvcTktItem.KittedYn                              
 --Added by NSK on 26 aug 2014                              
 ,ALP_tblInItem_view.UomBase                                 
 --Added by NSK on 05 Jan 2015               
 ,CASE                                 
  WHEN NonContractItem = 1 THEN 'True'                                
  ELSE 'False'                                
 END AS NonContractItem                          
 ,ALP_tblJmSvcTktItem.PhaseId,ALP_tblJmSvcTktItem.BinNumber,ALP_tblJmSvcTktItem.StagedDate,ALP_tblJmSvcTktItem.BODate, ALP_tblJmPhase.Phase --added by NSK on 16 Aug 2016 for 514 and 522                            
  --Added by NSK on 14 Sep 2016 for bug id 502                  
  --start                   
 ,ALP_tblJmSvcTktItem.CauseId,ALP_tblJmSvcTktItem.CauseDesc,ALP_tblJmSvcTktItem.Comments,                  
 CASE                                 
  WHEN [Action] = 'Other' THEN Zone                              
  ELSE ''                                
 END AS ActionTech                  
 ,CASE                                 
  WHEN [Action] = 'Other' THEN PartPulledDate                              
  ELSE null                               
 END AS ActionDate                   
 --end              
 ,ALP_tblJmSvcTktItem.UnitPriceIsFinalSalePrice --Added by NSK on 25 Oct 2016 for bug id 556              
 ,ALP_tblJmSvcTktItem.Zone -- Zone column Added by Ravi on 2 Nov 2017             
 -- Below columns (SerNum,CopyToYN,WhseID,PanelYN) Added by Ravi on 12 Dec 2017             
 ,ALP_tblJmSvcTktItem.SerNum,ALP_tblJmSvcTktItem.CopyToYN,ALP_tblJmSvcTktItem.PanelYN          
 --KitRef column added by Ravi on 27 dec 2017          
 ,ALP_tblJmSvcTktItem.KitRef          
  --ALP_tblJmResolution.ResolutionCode added by NSK on 15 Mar 2019 for bug id 914        
 ,ALP_tblJmResolution.ResolutionCode        
 --ALP_tblJmSvcTktItem.ExtSalePrice added by NSK on 24 Mar 2019 for bug id 902       
 --start    
 ,ALP_tblJmSvcTktItem.ExtSalePrice as ExistingSalePrice     
 ,ALP_tblJmSvcTktItem.ExtSalePriceFlg      
 --end    
  ,ALP_tblJmSvcTktItem.HoldInvCommitted --Added by NSK on 25 Oct 2018 for bug id 868     
FROM ALP_tblJmResolution INNER JOIN (ALP_tblJmCauseCode INNER JOIN (ALP_tblJmSvcTktItem                                 
 INNER JOIN ALP_tblJmSvcTkt ON ALP_tblJmSvcTktItem.TicketId = ALP_tblJmSvcTkt.TicketId) ON ALP_tblJmCauseCode.CauseId = ALP_tblJmSvcTktItem.CauseId)                                 
 ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId                          
 Left Outer JOIN ALP_tblJmPhase ON ALP_tblJmSvcTktItem.PhaseId = ALP_tblJmPhase.PhaseId --added by NSK on 16 Aug 2016 for 514 and 522                             
 Left JOIN ALP_tblInItem_view ON ALP_tblJmSvcTktItem.ItemID = ALP_tblInItem_view.ItemId                                
WHERE ALP_tblJmSvcTktItem.TicketId = @ID                                
ORDER BY ALP_tblJmSvcTktItem.LineNumber, ALP_tblJmSvcTktItem.TicketItemId