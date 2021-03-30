CREATE Procedure dbo.Alp_lkpArAlpSiteRecJobSystem_sp    
 (    
  @SiteID int = null    
 )    
As    
set nocount on     
SELECT  Alp_tblArAlpSiteSys.SysId,     
     Alp_tblArAlpSysType.SysType,     
 Alp_tblArAlpSiteSys.SysDesc,     
     Alp_tblArAlpSiteSys.LeaseYN,     
 Alp_tblArAlpSiteSys.SiteId,     
    ISNULL( Alp_tblArAlpSiteSys.ContractId,0)  as ContractId  , 
 Alp_tblArAlpSiteSys.CustId,     
     Alp_tblArAlpSiteSys.RepPlanId,     
 Alp_tblArAlpSysType.ServPriceId,     
    ISNULL( Alp_tblArAlpCustContract.ContractNum ,'')  as ContractNum
FROM Alp_tblArAlpSysType INNER JOIN    
     (Alp_tblArAlpSiteSys LEFT OUTER JOIN    
      Alp_tblArAlpCustContract ON     
      Alp_tblArAlpSiteSys.ContractId = Alp_tblArAlpCustContract.ContractId) ON     
     Alp_tblArAlpSysType.SysTypeId = Alp_tblArAlpSiteSys.SysTypeId    
WHERE  Alp_tblArAlpSiteSys.SiteId = @SiteID    
ORDER BY Alp_tblArAlpSiteSys.SysId    
RETURN