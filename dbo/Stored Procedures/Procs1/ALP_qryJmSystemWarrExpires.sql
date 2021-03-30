
CREATE Procedure [dbo].[ALP_qryJmSystemWarrExpires]
/* used within JM AlpLib function: GetDfltRepairPlan */
	(
		@SysID int = null
	)
As
	set nocount on
	SELECT RepPlanId, WarrPlanId, WarrExpires
	FROM ALP_tblArAlpSiteSys 
	WHERE SysId = @Sysid
	
return