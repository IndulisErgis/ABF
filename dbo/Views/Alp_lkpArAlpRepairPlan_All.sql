CREATE VIEW dbo.Alp_lkpArAlpRepairPlan_All
AS
SELECT     TOP (100) PERCENT RepPlanId, RepPlan, [Desc]
FROM         dbo.ALP_tblArAlpRepairPlan
ORDER BY RepPlan