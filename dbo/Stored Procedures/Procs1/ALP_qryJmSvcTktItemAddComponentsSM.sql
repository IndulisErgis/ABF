  
CREATE Procedure [dbo].[ALP_qryJmSvcTktItemAddComponentsSM]        
 @ID pitemid, @CurrentTicketItemId int, @KitQty int = 1,         
 @UseKitPrice bit, @UseKitCost bit, @UseKitPts bit, @UseKitHrs bit,         
 @AlpVendorKitComponentYn bit = 0, @LineNumberPrefix varchar(50) = ''        
AS        
-- EFI# 1268 mah 02/06/04: added Kit quantity as input parameter ( defaults to 1 if not supplied )        
-- EFI# 1063 MAH 11/14/04: assigned UOM to item        
-- EFI# 1528 MAH 11/17/04: Vendor Kit changes        
-- EFI# 1632 MAH 11/07/05: Changes to allow Kit-within-a-Kit        
-- EFI# 1618 MAH 11/11/05: Allow Kit costs to supercede component costs          
SET NOCOUNT ON        
INSERT INTO ALP_tblJmSvcTktItem ( TicketId, ResDesc, ResolutionId, CauseId, CauseDesc, ItemId, [Desc], TreatAsPartYN, QtyAdded,         
 CopyToYN, UnitPrice, UnitCost, UnitPts, KittedYN, PanelYN, KitRef, EquipLoc, [Zone], UnitHrs,Uom,         
 AlpVendorKitComponentYn, AlpVendorKitYn, ItemType, LineNumber,KitNestLevel,PhaseId)   
  --Phase Id added by NSK on 21 Jul 2020 for bug id 1064.     
SELECT ALP_tblJmSvcTktItem.TicketId, ALP_tblJmSvcTktItem.ResDesc, ALP_tblJmSvcTktItem.ResolutionId, ALP_tblJmSvcTktItem.CauseId,         
 ALP_tblJmSvcTktItem.CauseDesc, ALP_tblSmItem_view.ItemCode, ALP_tblSmItem_view.[Desc], 1 AS TreatAsPart,         
-- ALP_tblJmKitItemSm.Qty,        
  ALP_tblJmKitItemSm.Qty * @KitQty,        
 ALP_tblSmItem_view.AlpCopyToListYn,         
 CASE         
  WHEN @UseKitPrice = 0 THEN ALP_tblSmItem_view.UnitPrice        
  ELSE 0        
 END AS Price,        
 CASE         
  WHEN @UseKitCost = 0 THEN ALP_tblSmItem_view.UnitCost        
  ELSE 0        
 END AS UnitCost,        
 CASE         
  WHEN @UseKitPts = 0 THEN ALP_tblSmItem_view.AlpDfltPts        
  ELSE 0        
 END AS DfltPts,        
 ALP_tblSmItem_view.AlpKittedYN, ALP_tblSmItem_view.AlpPanelYN, ALP_tblJmSvcTktItem.TicketItemId,         
 ALP_tblJmKitItemSm.EquipLoc, ALP_tblJmKitItemSm.Zone,         
 CASE        
  WHEN @UseKitHrs = 0 THEN AlpDfltHours        
  ELSE 0        
 END AS DfltHrs,        
 ALP_tblJmKitItemSm.Uom,        
 --EFI# 1063 MAH 11/14/04 added:        
 @AlpVendorKitComponentYn,        
 --EFI# 1632 MAH 11/02/05 added:        
 ALP_tblSmItem_view.AlpVendorKitYn,        
 'Part' AS ItemType,        
 '*NEW*' as LineNumber,ALP_tblJmSvcTktItem.KitNestLevel + 1        
 ,ALP_tblSmItem_view.AlpPhaseCodeId -- AlpPhaseCodeId added by NSK on 21 Jul 2020 for bug id 1064        
FROM ALP_tblJmSvcTktItem, ALP_tblJmKitItemSm         
INNER JOIN ALP_tblSmItem_view ON ALP_tblJmKitItemSm.ItemId = ALP_tblSmItem_view.ItemCode        
WHERE ALP_tblJmSvcTktItem.TicketItemId = @CurrentTicketItemID       
AND ALP_tblJmKitItemSm.KitItemId = @ID        
        
UPDATE ALP_tblJmSvcTktItem        
SET LineNumber =  @LineNumberPrefix + '.' + STR((TicketItemID - @CurrentTicketItemID),3,0)        
WHERE ALP_tblJmSvcTktItem.KitRef = @CurrentTicketItemID and LineNumber = '*NEW*'