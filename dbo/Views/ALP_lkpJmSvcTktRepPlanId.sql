
CREATE VIEW dbo.ALP_lkpJmSvcTktRepPlanId AS 
 SELECT TOP 100 PERCENT RepPlanId, RepPlan, PartsPricingMethod, MarkupPct, SuppCostPct, [Desc],
 CASE WHEN DfltPlanID = 1 THEN 'Normal' ELSE 'Warranty' END AS PlanType FROM dbo.ALP_tblArAlpRepairPlan
 ORDER BY RepPlan