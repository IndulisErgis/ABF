

--Created to split 'Other' into parts and non-parts columns - ERR - 9/10/15
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q003_ActionsOtherPartsWIP_Q001] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
AA.TicketId, 
Round(Sum([Cost]*[QTy]),0) AS OtherCostExt

FROM ALP_R_JmAllActions_view AS AA

WHERE (((AA.PartPulledDate)<=@EndDate) AND (AA.Type='Other') AND (AA.ItemType = '1' OR AA.ItemType = '2')) 

GROUP BY AA.TicketId
)