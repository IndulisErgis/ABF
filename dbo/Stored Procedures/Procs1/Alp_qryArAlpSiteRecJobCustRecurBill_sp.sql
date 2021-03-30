CREATE Procedure  Alp_qryArAlpSiteRecJobCustRecurBill_sp  
/* 20qrySelectCustRecurBill */  
 (  
  @RecBillEntryID int = null  
 )  
As  
set nocount on  
SELECT ALP_tblArAlpSiteRecBill.CustId,   
 CS.Cust,   
 CS.Address  
FROM Alp_lkpArAlpSiteRecJobCust CS  
  INNER JOIN ALP_tblArAlpSiteRecBill   
  ON CS.CustId = ALP_tblArAlpSiteRecBill.CustId  
WHERE ALP_tblArAlpSiteRecBill.RecBillId = @RecBillEntryID  
return