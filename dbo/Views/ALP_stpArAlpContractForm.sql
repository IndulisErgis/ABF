CREATE VIEW [dbo].[ALP_stpArAlpContractForm]  
AS  
SELECT     TOP 100 PERCENT ContractFormId, ContractForm, Title, DateFirstUsed, DateInactive, RepPlanId, WarrPlanId, WarrTerm, LeasedYN, CycleId,   
                      InitialTerm, RenewalTerm, AutoRenewYN, IncreasePriceYN, LateFeesYN, BalDueYN, LimitLiabYN, LiqDamagesYN, LiqDamAmount,   
                      ThirdPartyIndemYN, AssignYN, RecisionYN, Udf1YN, Udf2YN, Udf3YN, Comments  
FROM         dbo.ALP_tblArAlpContractForm  
ORDER BY ContractForm