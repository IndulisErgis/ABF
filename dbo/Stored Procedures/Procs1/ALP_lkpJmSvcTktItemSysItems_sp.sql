  
CREATE PROCEDURE [dbo].[ALP_lkpJmSvcTktItemSysItems_sp]  
 @SysId int  
As  
SET NOCOUNT ON  
SELECT ALP_tblArAlpSiteSysItem.ItemId, ALP_tblArAlpSiteSysItem.[Desc],
 ALP_tblArAlpSiteSysItem.EquipLoc, ALP_tblArAlpSiteSysItem.SysId,   
 ALP_tblArAlpSiteSysItem.SerNum, ALP_tblArAlpSiteSysItem.WarrExpires,
 ALP_tblArAlpSiteSysItem.Zone, ALP_tblArAlpSiteSysItem.SysItemId, ALP_tblArAlpSiteSysItem.Qty,
  --Added by NSK on 19 Jun 2015
 ALP_tblArAlpSiteSysItem.SysItemId
FROM ALP_tblArAlpSiteSysItem  
WHERE ALP_tblArAlpSiteSysItem.SysId = @SysId And ALP_tblArAlpSiteSysItem.RemoveYn = 0   
ORDER BY ALP_tblArAlpSiteSysItem.ItemId