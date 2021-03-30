CREATE PROCEDURE dbo.ALP_stpJmSvcTktItems_AddActions_sp              
--EFI# 1645 MAH 02/17/06 - created               
 (              
 @TicketID int = 0              
 )              
AS              
SELECT STI.TicketItemId, STI.TicketId,               
    STI.ResolutionId, STI.ResDesc,               
    STI.CauseId, STI.CauseDesc,               
    STI.SelectFromInvYn,               
    STI.ItemNotInListYn, STI.ItemId,               
    STI.KitRef, STI.[Desc],               
    STI.TreatAsPartYN, STI.WhseID,               
    STI.QtyAdded, STI.QtyRemoved,               
    STI.QtyServiced, STI.SerNum,               
    STI.EquipLoc, STI.WarrExpDate,               
    STI.CopyToYN, STI.UnitPrice,               
    STI.UnitCost, STI.UnitPts,               
    STI.Comments, STI.Zone,               
    STI.ItemType, STI.KittedYN,               
    STI.SysItemId, STI.PanelYN,               
    STI.Uom, STI.PartPulledDate,               
    STI.CosOffset, STI.UnitHrs,               
    STI.AlpVendorKitYn,               
    STI.AlpVendorKitComponentYn,               
    STI.QtySeqNum_Cmtd,               
    STI.QtySeqNum_InUse,               
    STI.LineNumber, STI.KitNestLevel,               
    STI.PrintOnInvoice,              
    STI.Ts,STI.NonContractItem            
    ,STI.PhaseId,STI.BinNumber,STI.StagedDate,STI.BODate --Added by NSK on 12 Aug 2016 for bug id 514,522              
    ,STI.UnitPriceIsFinalSalePrice --Added by NSK on 25 Oct 2016 for bug id 556         
    ,STI.ExtSalePrice as ExistingSalePrice --Added by NSK on 21 Mar 2019 for bug id 902      
    ,STI.ExtSalePriceFlg as ExtSalePriceFlg --Added by NSK on 25 Mar 2019 for bug id 902   
    ,STI.HoldInvCommitted --Added by NSK on 25 Oct 2018 for bug id 819      
FROM dbo.ALP_tblJmSvcTktItem STI              
WHERE STI.TicketID = @TicketID               
 AND              
      STI.ResolutionId IN               
 (SELECT ResolutionId FROM dbo.ALP_tblJmResolution              
 WHERE dbo.ALP_tblJmResolution.Action = 'Add')              
ORDER BY STI.LineNumber, STI.TicketItemId