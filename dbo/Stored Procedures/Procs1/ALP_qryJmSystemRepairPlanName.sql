
CREATE Procedure [dbo].[ALP_qryJmSystemRepairPlanName]
/* used in JM AlpLib function: GetDfltRepairPlan  */
	(
		@RepPlanId int = null
	)
As
	set nocount on
	SELECT RepPlan 
	FROM ALP_tblArAlpRepairPlan 
	WHERE RepPlanId = @RepPlanId
	return