      
CREATE   Procedure [dbo].[ALP_qryJmSvcTktItemAddComponentsIN]        
 @CurrentTicketItemId int, @KitLoc pLocId, @KitQty int = 1,        
 @CommercialYn bit,        
 @UseKitPrice bit, @UseKitCost bit, @UseKitPts bit, @UseKitHrs bit,         
 @AlpVendorKitComponentYn bit = 0, @LineNumberPrefix varchar(50) = ''        
AS        
-- EFI# 1268 mah 02/06/04: added Kit quantity as input parameter ( defaults to 1 if not supplied )        
-- EFI# 1063 MAH 11/14/04: inserted each component's Uom        
-- EFI# 1528 MAH 11/17/04: Vendor kit changes        
-- EFI# 1632 MAH 11/07/05: Changes to allow Kit-within-a-Kit.        
-- EFI# 1618 MAH 11/11/05: Allow Kit costs to supercede component costs         
-- EFI# 1806 MAH 04/09/09:  Corrected to use LastCost when BaseCost is zero         
-- EFI# ???? MAH 01/22/13 - added CommercialYN parameter        
--mah 09/09/16 - modified to accept parts with missing price info. Inserts 0 price as default.    
SET NOCOUNT ON        
INSERT INTO ALP_tblJmSvcTktItem (TicketId, ResolutionId, ResDesc, CauseId, CauseDesc, KitRef, [Desc], TreatAsPartYN, WhseID,         
 QtyAdded, CopyToYN, UnitPrice, UnitCost, UnitPts, PanelYN, ItemId, [Zone], EquipLoc, UnitHrs, UOM,         
 AlpVendorKitComponentYn, KittedYn, AlpVendorKitYn, ItemType, LineNumber, KitNestLevel,BinNumber,PhaseId)  
 --BinNumber added by NSK on 13 Jul 2020 for bug id 1067.  
 --Phase Id added by NSK on 21 Jul 2020 for bug id 1064.      
SELECT ALP_stpJmSvcTktItemKit.TicketId, ALP_stpJmSvcTktItemKit.ResolutionId, ALP_stpJmSvcTktItemKit.ResDesc, ALP_stpJmSvcTktItemKit.CauseId,         
 ALP_stpJmSvcTktItemKit.CauseDesc, ALP_stpJmSvcTktItemKit.TicketItemId, ALP_tblInItem_view.Descr,         
 CASE         
  WHEN ALP_tblInItem_view.ItemType = 1 or ALP_tblInItem_view.ItemType = 2 THEN 1        
  ELSE 0        
 END AS TreatAsPart,        
 ALP_stpJmSvcTktItemKit.WhseID,        
--  ALP_stpJmSvcTktItemKit.QtyAdded,        
 ALP_stpJmSvcTktItemKit.QtyAdded * @KitQty,        
  ALP_tblInItem_view.AlpCopyToListYn,         
 CASE        
  WHEN @UseKitPrice = 0 THEN ISNULL(P.PriceBase,0)        
  ELSE 0        
 END AS Price,        
 CASE        
--EFI# 1806 MAH 04/09/09:        
--  WHEN @UseKitCost = 0 THEN tblInItemLoc.CostBase        
  WHEN @UseKitCost = 0 AND tblInItemLoc.CostBase <> 0 THEN tblInItemLoc.CostBase        
  WHEN @UseKitCost = 0 AND tblInItemLoc.CostBase = 0 THEN tblInItemLoc.CostLast        
  ELSE 0        
 END AS CostBase,        
 --mah 01/22/13 - added CommercialYN parameter:        
 CASE        
  WHEN @UseKitPts = 0 THEN CASE         
        WHEN @CommercialYn = 0 THEN ALP_stpJmSvcTktItemKit.AlpDfltPts        
        ELSE ALP_stpJmSvcTktItemKit.AlpDfltCommercialPts        
        END        
  ELSE 0        
  END AS DfltPts,        
 --CASE        
 -- WHEN @UseKitPts = 0 THEN ALP_stpJmSvcTktItemKit.AlpDfltPts        
 -- ELSE 0        
 --END AS DfltPts,        
        
 ALP_tblInItem_view.AlpPanelYN, ALP_stpJmSvcTktItemKit.ItemId, ALP_stpJmSvcTktItemKit.Zone, ALP_stpJmSvcTktItemKit.EquipLoc,         
 --mah 01/22/13 - added CommercialYN parameter:        
 CASE         
  WHEN @UseKitHrs = 0 THEN CASE         
        WHEN @CommercialYn = 0 THEN ALP_stpJmSvcTktItemKit.AlpDfltHours        
        ELSE ALP_stpJmSvcTktItemKit.AlpDfltCommercialHours        
        END        
  ELSE 0        
 END AS DfltHrs,        
 --CASE         
 -- WHEN @UseKitHrs = 0 THEN ALP_stpJmSvcTktItemKit.AlpDfltHours        
 -- ELSE 0        
 --END AS DfltHrs,        
--EFI# 1063 MAH 11/14/04 added:        
 ALP_stpJmSvcTktItemKit.Uom,        
 @AlpVendorKitComponentYn,        
--EFI# 1632 MAH 11/02/05 added:        
 ALP_tblInItem_view.KittedYn,        
 ALP_tblInItem_view.AlpVendorKitYn,        
 CASE         
  WHEN ALP_tblInItem_view.ItemType = 1 or ALP_tblInItem_view.ItemType = 2 THEN 'Part'        
  ELSE 'Other'        
 END AS ItemType,        
 '*NEW*' as LineNumber,        
 KitNestLevel = ALP_stpJmSvcTktItemKit.KitNestLevel + 1      
 ,tblInItemLoc.DfltBinNum--BinNumber added by NSK on 13 Jul 2020 for bug id 1067.  
 ,ALP_stpJmSvcTktItemKit.AlpPhaseCodeId -- AlpPhaseCodeId added by NSK on 21 Jul 2020 for bug id 1064  
FROM (ALP_stpJmSvcTktItemKit INNER JOIN tblInItemLoc ON (ALP_stpJmSvcTktItemKit.ItemId = tblInItemLoc.ItemId)         
 AND (ALP_stpJmSvcTktItemKit.WhseID = tblInItemLoc.LocId))         
 INNER JOIN (ALP_tblInItem_view LEFT OUTER JOIN tblInItemLocUomPrice P ON ALP_tblInItem_view.ItemId = P.ItemId)         
 ON (ALP_tblInItem_view.ItemId = tblInItemLoc.ItemId) AND (tblInItemLoc.LocId = P.LocId)         
 AND (tblInItemLoc.ItemId = P.ItemId) AND (ALP_stpJmSvcTktItemKit.Uom = P.Uom)        
WHERE ALP_stpJmSvcTktItemKit.TicketItemId = @CurrentTicketItemID  AND ALP_stpJmSvcTktItemKit.WhseID = @KitLoc        
        
UPDATE ALP_tblJmSvcTktItem        
SET LineNumber =  @LineNumberPrefix + '.' + STR((TicketItemID - @CurrentTicketItemID),3,0)        
WHERE ALP_tblJmSvcTktItem.KitRef = @CurrentTicketItemID and LineNumber = '*NEW*'