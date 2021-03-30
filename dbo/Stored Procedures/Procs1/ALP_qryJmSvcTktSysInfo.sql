

CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktSysInfo]
@ID int
As
SET NOCOUNT ON
SELECT ALP_tblArAlpSiteSys.SysId, ALP_tblArAlpSiteSys.InstallDate, ALP_tblArAlpSiteSys.LeaseYN,
 ALP_tblArAlpSiteSys.WarrTerm, ALP_tblArAlpRepairPlan.RepPlan, 
	ALP_lkpJmSvcTktSysWarrPlan.WarrPlan
FROM ALP_tblArAlpSiteSys LEFT OUTER JOIN ALP_lkpJmSvcTktSysWarrPlan ON
 ALP_tblArAlpSiteSys.SysId = ALP_lkpJmSvcTktSysWarrPlan.SysId LEFT OUTER JOIN
 ALP_tblArAlpRepairPlan ON ALP_tblArAlpRepairPlan.RepPlanId = ALP_tblArAlpSiteSys.RepPlanId
WHERE ALP_tblArAlpSiteSys.SysId = @ID