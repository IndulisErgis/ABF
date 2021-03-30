
  
CREATE PROCEDURE [dbo].[ALP_rptJmSvcOrderEquipFlag_sp]  
(  
@sysID int = null  
)  
AS  
SELECT   
--ALP_tblArAlpSiteSysItem.SysItemId,  
--ALP_tblArAlpSiteSys.SysId  
ALP_tblArAlpSiteSysItem.Qty,  
ZoneNo=ALP_tblArAlpSiteSysItem.Zone,  
ALP_tblArAlpSiteSysItem.[Desc],  
ALP_tblArAlpSiteSysItem.Equiploc,  
Flag=  
 CASE WHEN   
 (CASE  
 WHEN ALP_tblArAlpSiteSysItem.WarrPlanId<>ALP_tblArAlpSiteSys.WarrPlanId  
 THEN '1'  
 ELSE '0'  
 END) +  
    
 (CASE   
 WHEN ALP_tblArAlpSiteSysItem.WarrExpires<>ALP_tblArAlpSiteSys.WarrExpires  
 THEN '1'  
 ELSE '0'  
 END) +  
 (CASE   
 WHEN ALP_tblArAlpSiteSysItem.RepPlanId<>ALP_tblArAlpSiteSys.RepPlanId  
 THEN '1'  
 ELSE '0'  
 END) +  
 (CASE  
 WHEN ALP_tblArAlpSiteSysItem.LeaseYn<>ALP_tblArAlpSiteSys.LeaseYn  
 THEN '1'  
 ELSE '0'   
 END) >0  
 THEN '*'  
 ELSE ' '  
 END  
FROM ALP_tblArAlpSiteSys JOIN ALP_tblArAlpSiteSysItem  
ON ALP_tblArAlpSiteSys.sysID=ALP_tblArAlpSiteSysItem.sysID  
WHERE (@sysID is not null ) AND (ALP_tblArAlpSiteSysItem.sysID=@sysID)  
--condition added by NSK on 28 Apr 2015
and ALP_tblArAlpSiteSysItem.RemoveYN<>1