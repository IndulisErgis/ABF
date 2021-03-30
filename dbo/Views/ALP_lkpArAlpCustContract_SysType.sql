CREATE VIEW dbo.ALP_lkpArAlpCustContract_SysType
AS
SELECT     
	[cc].[ContractId], 
	[cc].[CustId],
	[cc].[ContractNum], 
	--MAH 10/05/13:added Ref, ContractValue, ContractDate fields, to correct Site Systems form
	[cc].[Ref],
	CAST ([cc].[ContractValue] AS MONEY) AS ContractValue,
	[cc].[ContractDate],
	[cf].[ContractForm], 
    [cf].[Title], 
    [cc].[DfltWarrPlanId], 
    [cc].[DfltWarrTerm], 
    [cc].[DfltRepPlanId], 
    [cc].[LeaseYN], 
    [cf].[DateInactive]
FROM	[dbo].[ALP_tblArAlpContractForm] AS [cf]
INNER JOIN [dbo].[ALP_tblArAlpCustContract] AS [cc]
	ON [cf].[ContractFormId] = [cc].[ContractFormId]
WHERE     [cf].[DateInactive] IS NULL