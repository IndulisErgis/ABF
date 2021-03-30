CREATE VIEW dbo.ALP_lkpJmSvcProjectWorkOrderItems      
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
                        ALP_tblJmPhase.Phase
FROM   ALP_tblJmPhase INNER JOIN
                      ALP_tblInItem ON ALP_tblJmPhase.PhaseId = ALP_tblInItem.AlpPhaseCodeID RIGHT OUTER JOIN
                      ALP_tblJmResolution INNER JOIN
                      ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId INNER JOIN
                      ALP_tblJmSvcTkt ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId INNER JOIN
                      ALP_tblArAlpSiteSys ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId INNER JOIN
                      ALP_tblArAlpSysType ON ALP_tblArAlpSiteSys.SysTypeId = ALP_tblArAlpSysType.SysTypeId ON 
                      ALP_tblInItem.AlpItemId = ALP_tblJmSvcTktItem.ItemId LEFT OUTER JOIN
                      tblInItemLoc ON ALP_tblJmSvcTktItem.ItemId = tblInItemLoc.ItemId AND ALP_tblJmSvcTktItem.EquipLoc = tblInItemLoc.LocId


                       
WHERE  (dbo.ALP_tblJmResolution.[Action] = 'Add')       
AND (dbo.ALP_tblJmSvcTktItem.KittedYN = 0)      
AND (dbo.ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0)      
ORDER BY dbo.ALP_tblJmSvcTktItem.TicketItemId