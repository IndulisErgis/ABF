
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q003_ActionPartsWIP_Q001] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
AA.TicketId, 
Round(Sum([Cost]*[QTy]),0) AS PartCostExt

FROM ALP_R_JmAllActions_view AS AA

WHERE (((AA.PartPulledDate)<=@EndDate) AND (AA.Type='Part'))

GROUP BY AA.TicketId
)