CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBill_GetContractDefaults]  
--Query modified by ravi on 01/12/2016, Added DfltRepPlanId column
(  
 @CustID VARCHAR(10)  
)  
AS  
BEGIN  
 SELECT   
  [cc].[CustId],  
  [cc].[ContractId],  
  [cc].[DfltBillTerm],  
  [cc].[DfltBillRenTerm],
  [cc].[DfltRepPlanId] --Query modified by ravi on 01/12/2016 
 FROM [dbo].[ALP_tblArAlpCustContract] AS [cc]  
 INNER JOIN [dbo].[ALP_tblArAlpContractForm] AS [cf]  
  ON [cc].[ContractFormId] = [cf].[ContractFormId]  
 WHERE [cc].[CustId] = @CustID  
END