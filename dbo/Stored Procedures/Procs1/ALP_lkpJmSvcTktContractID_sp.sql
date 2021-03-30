CREATE PROCEDURE dbo.ALP_lkpJmSvcTktContractID_sp  
@ID pCustId  
As  
SET NOCOUNT ON  
SELECT [ALP_tblArAlpCustContract].[ContractId], 
	[ALP_tblArAlpCustContract].[CustId], [ALP_tblArAlpCustContract].[ContractNum], 
	[ALP_tblArAlpContractForm].[ContractForm],   
 [ALP_tblArAlpCustContract].[DfltBillTerm], [ALP_tblArAlpCustContract].[ContractValue], 
 [ALP_tblArAlpContractForm].[Title] , [ALP_tblArAlpCustContract].[Ref]  
 FROM ALP_tblArAlpContractForm 
	right outer JOIN ALP_tblArAlpCustContract 
	ON [ALP_tblArAlpContractForm].[ContractFormId]=[ALP_tblArAlpCustContract].[ContractFormId]   
 WHERE ALP_tblArAlpCustContract.CustId= @ID