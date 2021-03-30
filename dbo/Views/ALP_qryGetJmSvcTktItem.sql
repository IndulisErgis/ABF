
CREATE VIEW [dbo].[ALP_qryGetJmSvcTktItem]
AS
Select TicketItemId,TicketId,QtyAdded,ResolutionId,ResDesc,CauseId,CauseDesc,SelectFromInvYn,ItemNotInListYn,ItemId,
KitRef,[Desc],TreatAsPartYN,PrintOnInvoice,WhseID,QtyRemoved,QtyServiced,SerNum,EquipLoc,WarrExpDate,
CopyToYN,UnitPrice,UnitCost,UnitPts,Comments,Zone,ItemType,KittedYN,SysItemId,PanelYN,Uom,PartPulledDate,
CosOffset,UnitHrs,AlpVendorKitYn,AlpVendorKitComponentYn,ts,QtySeqNum_Cmtd,QtySeqNum_InUse,
LineNumber,KitNestLevel,ModifiedBy,ModifiedDate,NonContractItem
 From ALP_tblJmSvcTktItem