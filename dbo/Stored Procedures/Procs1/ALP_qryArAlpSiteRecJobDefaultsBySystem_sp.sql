CREATE Procedure ALP_qryArAlpSiteRecJobDefaultsBySystem_sp  
/* 20qryDefaultsBySystem */  
 (  
  @SiteID integer = 0,  
  @SystemID int = 0  
 )  
As  
set nocount on  
SELECT SS.SysId,  
 SS.CustId,  
 CS.Cust,   
 CS.Address,   
 SS.ContractId,  
 SS.RepPlanId,  
 ST.ServPriceId  
FROM Alp_tblArAlpSysType ST  
 INNER JOIN  (Alp_tblArAlpSiteSys SS  
    INNER JOIN Alp_lkpArAlpSiteRecJobCust CS   
   ON SS.CustId = CS.CustId)  
 ON ST.SysTypeId = SS.SysTypeId  
WHERE (SS.SysId= @SystemID)  
 AND  
 (SS.SiteId = @SiteID)  
return