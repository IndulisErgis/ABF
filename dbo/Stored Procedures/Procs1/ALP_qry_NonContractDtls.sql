     
CREATE PROCEDURE [dbo].[ALP_qry_NonContractDtls]      
-- EFI# 1063 MAH 10/20/04 - added UOM       
-- EFI# 1528 MAH 11/17/04 - vendor kits      
-- EFI# 1529 MAH 12/16/04 - JM-IN Interface      
-- EFI# 1632 MAH 11/02/05 - Allowing Kit within Kit processing      
-- EFI# 1613 MAH 12/23/05 - Split out Other Labor ( ex EngLabor ) items from 'Other' category      
  --EFIX NSK 08.27.2014 - UOMBase Column added    
@TicketId int      
As      
SET NOCOUNT ON      
SELECT ALP_tblJmSvcTktItem.ResDesc, ALP_tblJmCauseCode.CauseCode, ALP_tblJmSvcTktItem.[Desc],       
 ALP_tblJmSvcTktItem.EquipLoc, coalesce(UnitPts, 0) AS Pts, coalesce(UnitHrs, 0) AS Hrs,       
 CASE      
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS Null OR KitRef = '') THEN 'K'      
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS not Null OR KitRef <> '') THEN 'CK'      
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS Null OR KitRef = '') THEN 'V'      
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS not Null OR KitRef <> '') THEN 'CV'      
  WHEN KitRef IS Not Null OR KitRef <> '' THEN 'C'      
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
 --Added by NSK on 06 Feb 2015
 ,ALP_tblJmSvcTktItem.TicketId
FROM ALP_tblJmResolution INNER JOIN (ALP_tblJmCauseCode INNER JOIN (ALP_tblJmSvcTktItem       
 INNER JOIN ALP_tblJmSvcTkt ON ALP_tblJmSvcTktItem.TicketId = ALP_tblJmSvcTkt.TicketId) ON ALP_tblJmCauseCode.CauseId = ALP_tblJmSvcTktItem.CauseId)       
 ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId      
 Left JOIN ALP_tblInItem_view ON ALP_tblJmSvcTktItem.ItemID = ALP_tblInItem_view.ItemId      
WHERE ALP_tblJmSvcTktItem.TicketId = @TicketId   
and ALP_tblJmSvcTktItem.NonContractItem=1   
ORDER BY ALP_tblJmSvcTktItem.LineNumber, ALP_tblJmSvcTktItem.TicketItemId