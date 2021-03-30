CREATE Procedure [dbo].[Alp_lkpArAlpSiteRecJobContract_sp]  
/* 20qryContractSelect */  
 (  
  @CustID pCustId =null  
 )  
As  
set nocount on  
SELECT Alp_tblArAlpCustContract.ContractNum,  
 Alp_tblArAlpCustContract.ContractId,  
 Alp_tblArAlpContractForm.ContractForm,   
 Alp_tblArAlpContractForm.Title  
FROM Alp_tblArAlpContractForm  
  RIGHT JOIN (Alp_tblArAlpCustContract   
  LEFT JOIN Alp_tblArAlpSiteSys ON Alp_tblArAlpCustContract.ContractId = Alp_tblArAlpSiteSys.ContractId)  
  ON Alp_tblArAlpContractForm.ContractFormId = Alp_tblArAlpCustContract.ContractFormId  
GROUP BY Alp_tblArAlpCustContract.ContractNum,  
 Alp_tblArAlpCustContract.ContractId,  
 Alp_tblArAlpContractForm.ContractForm,  
 Alp_tblArAlpContractForm.Title,  
 Alp_tblArAlpCustContract.CustId  
HAVING (Alp_tblArAlpCustContract.CustId=@CustId)  
return