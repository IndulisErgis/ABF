CREATE VIEW [dbo].[ALP_lkpArAlpContractId_CustID]  
AS  
SELECT       
 [cc].[ContractId],   
 [cc].[ContractNum],  
 --MAH 10/05/13:added Ref, ContractValue, and Contract Date fields, to correct Site Systems form  
 [cc].[Ref],  
 --[cc].[ContractValue],  
 CONVERT (MONEY , [cc].[ContractValue]) as ContractValue,  
 [cc].[ContractDate],   
 [cf].[ContractForm],   
 [cf].[Title],   
 [cc].[DfltBillTerm],   
 [cc].[DfltBillRenTerm],   
 [cc].[DfltBillAutoRen],   
 [cc].[CustId], 
 -- Below columns added by ravi and MAH on 12/10/13 
 --Start
 [cc].DfltRepPlanId ,
 [cc].DfltWarrPlanId, 
 [cc].DfltWarrTerm ,
 [cc].LeaseYN 
 --End
FROM         dbo.[ALP_tblArAlpCustContract] AS [cc]  
INNER JOIN dbo.[ALP_tblArAlpContractForm] AS [cf]  
 ON [cc].[ContractFormId] = [cf].[ContractFormId]