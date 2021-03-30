CREATE VIEW dbo.Alp_InqArAlpContractForm  
AS  
SELECT     ContractFormId, ContractForm, Title, RepPlanId, WarrPlanId, WarrTerm, LeasedYN, CycleId, InitialTerm, RenewalTerm, AutoRenewYN  
FROM         dbo.ALP_tblArAlpContractForm  
WHERE     (DateInactive IS NULL)