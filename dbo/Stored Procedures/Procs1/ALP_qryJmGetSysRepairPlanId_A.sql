
CREATE Procedure [dbo].[ALP_qryJmGetSysRepairPlanId_A]
/* used in Jm AlpLib function: GetSysRepairPlanId   */
	(
		@SysId int = null
	)
As
	set nocount on
	SELECT RepPlanId, WarrPlanId, WarrExpires 
	FROM ALP_tblArAlpSiteSys 
	WHERE SysId = @Sysid
	return