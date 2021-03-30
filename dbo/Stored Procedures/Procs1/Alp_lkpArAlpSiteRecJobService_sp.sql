CREATE Procedure dbo.Alp_lkpArAlpSiteRecJobService_sp  
/* 20qryServiceSelect */  
 (  
  @SiteID int = null,  
  @SystemID int = null  
 )  
As  
set nocount on  
SELECT   
 RecSvcId = Alp_tblArAlpSiteRecBillServ.RecBillServId,  
 Alp_tblArAlpSiteRecBillServ.ServiceID,   
 Alp_tblArAlpSiteRecBillServ.[Desc],  
 Alp_tblArAlpSiteRecBillServ.Status,   
 Alp_tblArAlpSiteRecBill.SiteId,  
 Alp_tblArAlpSiteRecBill.CustId,  
 Alp_tblArAlpSiteRecBillServ.ContractId,   
 Alp_tblArAlpSiteRecBill.RecBillId  
FROM Alp_tblArAlpSiteRecBill INNER JOIN   
  (Alp_tblArAlpCustContract INNER JOIN Alp_tblArAlpSiteRecBillServ ON Alp_tblArAlpCustContract.ContractId = Alp_tblArAlpSiteRecBillServ.ContractId)  
 ON Alp_tblArAlpSiteRecBill.RecBillId = Alp_tblArAlpSiteRecBillServ.RecBillId  
WHERE ((Alp_tblArAlpSiteRecBill.SiteId = @SiteID)   
 AND (Alp_tblArAlpSiteRecBillServ.SysId = @SystemID)   
 AND ( Alp_tblArAlpSiteRecBillServ.ServiceType =6))  
return