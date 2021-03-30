
CREATE VIEW [dbo].[ALP_lkpArAlpContractForm]  
AS  
SELECT     TOP 100 PERCENT ContractFormId,ContractForm, Title  
FROM         dbo.ALP_tblArAlpContractForm  
ORDER BY ContractForm