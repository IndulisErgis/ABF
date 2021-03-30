        CREATE Procedure [dbo].[ALP_qryJm110q00EquipList_sp]  
/* RecordSource for Equipment List subform of Control Center */  
 (  
  @SiteId int  = null  
 )  
As  
 set nocount on  
 SELECT     ALP_tblArAlpSiteSysItem.Qty, ALP_tblArAlpSiteSysItem.ItemId, ALP_tblArAlpSiteSysItem.[Desc] AS Description, ALP_tblArAlpSiteSysItem.EquipLoc AS Location,   
                      ALP_tblArAlpSiteSysItem.[Zone], ALP_tblArAlpSiteSysItem.SysId, ALP_tblArAlpSiteSys.SysDesc, ALP_tblArAlpSiteSys.AlarmId, ALP_tblArAlpSiteSys.SiteId  
                      --Below columns added by NSK on 27 Apr 2015
                      --start
                      ,ALP_tblArAlpSiteSysItem.RemoveYN,ALP_tblArAlpSiteSysItem.LocId,ALP_tblArAlpSiteSysItem.PanelYN,ALP_tblArAlpSiteSysItem.SerNum,
                      ALP_tblArAlpSiteSysItem.UnitCost,ALP_tblArAlpSiteSysItem.WarrPlanId,ALP_tblArAlpSiteSysItem.WarrTerm,
                      ALP_tblArAlpSiteSysItem.WarrStarts,ALP_tblArAlpSiteSysItem.WarrExpires,ALP_tblArAlpSiteSysItem.Comments,
                      ALP_tblArAlpSiteSysItem.TicketId,	ALP_tblArAlpSiteSysItem.WorkOrderId,ALP_tblArAlpSiteSysItem.RepPlanId,
                      ALP_tblArAlpSiteSysItem.LeaseYN,ALP_tblArAlpSiteSysItem.ModifiedBy,ALP_tblArAlpSiteSysItem.ModifiedDate
                      --end

,ALP_tblArAlpSiteSysItem.SysitemId --added to give uniqueid for each record in ALP_tblArAlpSiteSysItem table #DMM


 FROM         ALP_tblArAlpSiteSys INNER JOIN  
                      ALP_tblArAlpSiteSysItem ON ALP_tblArAlpSiteSys.SysId = ALP_tblArAlpSiteSysItem.SysId  
 WHERE     (ALP_tblArAlpSiteSys.SiteId = @SiteId)  
 --Below condition added by NSK on 27 Apr 2015
 and ALP_tblArAlpSiteSysItem.RemoveYN<>1
 ORDER BY ALP_tblArAlpSiteSysItem.PanelYN DESC