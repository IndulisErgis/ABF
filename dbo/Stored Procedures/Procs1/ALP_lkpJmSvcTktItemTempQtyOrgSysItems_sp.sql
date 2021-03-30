Create PROCEDURE [dbo].[ALP_lkpJmSvcTktItemTempQtyOrgSysItems_sp]              
 @SysId int,  
 @TicketId int             
As              
SET NOCOUNT ON              
SELECT ALP_tblArAlpReplaceQtySiteSysItem.ItemId, ALP_tblArAlpReplaceQtySiteSysItem.[Desc],            
 ALP_tblArAlpReplaceQtySiteSysItem.EquipLoc, ALP_tblArAlpReplaceQtySiteSysItem.SysId,               
 ALP_tblArAlpReplaceQtySiteSysItem.SerNum, ALP_tblArAlpReplaceQtySiteSysItem.WarrExpires,            
 ALP_tblArAlpReplaceQtySiteSysItem.Zone, cast(ALP_tblArAlpReplaceQtySiteSysItem.SysItemId as int) as OrgSysItemId,   
 ALP_tblArAlpReplaceQtySiteSysItem.Qty        
 ,ALP_tblArAlpReplaceQtySiteSysItem.RemoveYn     
 --,            
  --Added by NSK on 19 Jun 2015            
,cast(ALP_tblArAlpReplaceQtySiteSysItem.SysItemId as int) as SysItemId          
FROM ALP_tblArAlpReplaceQtySiteSysItem              
WHERE ALP_tblArAlpReplaceQtySiteSysItem.SysId = @SysId    
--and  ALP_tblArAlpReplaceQtySiteSysItem.TicketId = @TicketId   
--And ALP_tblArAlpReplaceQtySiteSysItem.RemoveYn = 0               
ORDER BY ALP_tblArAlpReplaceQtySiteSysItem.ItemId