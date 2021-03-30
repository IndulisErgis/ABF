CREATE  VIEW dbo.ALP_stpJmSvcTktItems AS           
SELECT ALP_tblJmResolution.Action, ALP_tblJmSvcTktItem.TicketItemId, ALP_tblJmSvcTktItem.TicketId,          
 ALP_tblJmSvcTktItem.ResolutionId, ALP_tblJmSvcTktItem.ResDesc, ALP_tblJmSvcTktItem.CauseId, ALP_tblJmSvcTktItem.CauseDesc,          
 ALP_tblJmSvcTktItem.SelectFromInvYn, ALP_tblJmSvcTktItem.ItemNotInListYn, ALP_tblJmSvcTktItem.ItemId, ALP_tblJmSvcTktItem.KitRef,          
 ALP_tblJmSvcTktItem.[Desc], ALP_tblJmSvcTktItem.TreatAsPartYN, ALP_tblJmSvcTktItem.WhseID, ALP_tblJmSvcTktItem.QtyAdded,          
 ALP_tblJmSvcTktItem.QtyRemoved, ALP_tblJmSvcTktItem.QtyServiced,           
ALP_tblJmSvcTktItem.SerNum, ALP_tblJmSvcTktItem.EquipLoc, ALP_tblJmSvcTktItem.WarrExpDate, ALP_tblJmSvcTktItem.CopyToYN,          
 ALP_tblJmSvcTktItem.UnitPrice, ALP_tblJmSvcTktItem.UnitCost, ALP_tblJmSvcTktItem.UnitPts, ALP_tblJmSvcTktItem.Comments,          
 ALP_tblJmSvcTktItem.Zone, ALP_tblJmSvcTktItem.ItemType          
, ALP_tblJmSvcTktItem.KittedYN, ALP_tblJmSvcTktItem.SysItemId, ALP_tblJmSvcTktItem.PanelYN, ALP_tblJmSvcTktItem.Uom,          
 ALP_tblJmSvcTktItem.PartPulledDate, ALP_tblJmSvcTktItem.CosOffset, ALP_tblJmSvcTktItem.UnitHrs,          
 ALP_tblJmSvcTktItem.AlpVendorKitYn, ALP_tblJmSvcTktItem.AlpVendorKitComponentYn          
, ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, ALP_tblJmSvcTktItem.QtySeqNum_InUse, ALP_tblJmSvcTktItem.LineNumber,          
 ALP_tblJmSvcTktItem.KitNestLevel, ALP_tblJmSvcTktItem.PrintOnInvoice ,ALP_tblJmSvcTktItem.ts      ,  
 ALP_tblJmSvcTktItem.PhaseId,ALP_tblJmSvcTktItem.BinNumber,ALP_tblJmSvcTktItem.StagedDate,ALP_tblJmSvcTktItem.BODate --Added by NSK on 22 Aug 2016 for bug id 522.    
 ,ALP_tblJmSvcTktItem.UnitPriceIsFinalSalePrice -- Added by NSK on 03 Nov 2016 for bug id 556.        
 ,ALP_tblJmResolution.ResolutionCode -- Added by NSK on 08 Nov 2017 for TOA  
FROM dbo.ALP_tblJmResolution RIGHT OUTER JOIN dbo.ALP_tblJmSvcTktItem ON dbo.ALP_tblJmResolution.ResolutionId           
= dbo.ALP_tblJmSvcTktItem.ResolutionId