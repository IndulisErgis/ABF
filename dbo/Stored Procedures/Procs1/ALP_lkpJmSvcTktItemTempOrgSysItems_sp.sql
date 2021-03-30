Create PROCEDURE [dbo].[ALP_lkpJmSvcTktItemTempOrgSysItems_sp]    
                
 @SysId int,  
 @TicketId int                
As                
SET NOCOUNT ON                
SELECT ALP_tblArAlpReplaceSiteSysItem.ItemId, ALP_tblArAlpReplaceSiteSysItem.[Desc],              
 ALP_tblArAlpReplaceSiteSysItem.EquipLoc, ALP_tblArAlpReplaceSiteSysItem.SysId,                 
 ALP_tblArAlpReplaceSiteSysItem.SerNum, ALP_tblArAlpReplaceSiteSysItem.WarrExpires,              
 ALP_tblArAlpReplaceSiteSysItem.Zone, cast(ALP_tblArAlpReplaceSiteSysItem.SysItemId as int) as OrgSysItemId,     
 ALP_tblArAlpReplaceSiteSysItem.Qty          
 ,ALP_tblArAlpReplaceSiteSysItem.RemoveYn       
 --,              
  --Added by NSK on 19 Jun 2015              
,cast(ALP_tblArAlpReplaceSiteSysItem.SysItemId as int)  as SysItemId           
FROM ALP_tblArAlpReplaceSiteSysItem                
WHERE ALP_tblArAlpReplaceSiteSysItem.SysId = @SysId    
--and  ALP_tblArAlpReplaceSiteSysItem.TicketId = @TicketId   
--And ALP_tblArAlpReplaceSiteSysItem.RemoveYn = 0                 
ORDER BY ALP_tblArAlpReplaceSiteSysItem.ItemId