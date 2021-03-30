CREATE procedure dbo.ALP_lkpJmSvcTktSysPanel_sp
@SysId int    
AS    
SELECT    ALP_tblArAlpSiteSysItem.SysId, ALP_tblArAlpSiteSysItem.ItemId,
 ALP_tblArAlpSiteSysItem.[Desc] AS Descr,  
ALP_tblArAlpSiteSysItem.PanelYN,ALP_tblArAlpSiteSysItem.WarrStarts
FROM         dbo.ALP_tblArAlpSiteSysItem   
WHERE     (PanelYN = 1)   
--below condition added by NSK on 28 Apr 2015   
and ALP_tblArAlpSiteSysItem.RemoveYN=0 and ALP_tblArAlpSiteSysItem.SysId=@SysId
order by ALP_tblArAlpSiteSysItem.WarrStarts desc,ALP_tblArAlpSiteSysItem.SysItemId desc