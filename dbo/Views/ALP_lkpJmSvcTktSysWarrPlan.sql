
CREATE VIEW dbo.ALP_lkpJmSvcTktSysWarrPlan
AS
SELECT     dbo.ALP_tblArAlpSiteSys.SysId, dbo.ALP_tblArAlpRepairPlan.RepPlan AS WarrPlan
FROM         dbo.ALP_tblArAlpRepairPlan INNER JOIN
                      dbo.ALP_tblArAlpSiteSys ON dbo.ALP_tblArAlpRepairPlan.RepPlanId = dbo.ALP_tblArAlpSiteSys.WarrPlanId