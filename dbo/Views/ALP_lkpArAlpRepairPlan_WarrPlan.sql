CREATE VIEW dbo.ALP_lkpArAlpRepairPlan_WarrPlan  
AS  
SELECT     TOP 100 PERCENT RepPlanId, RepPlan, [Desc], DfltWarrTerm, InactiveYN  
FROM         dbo.ALP_tblArAlpRepairPlan  
WHERE     (InactiveYN = 0)  
ORDER BY RepPlan