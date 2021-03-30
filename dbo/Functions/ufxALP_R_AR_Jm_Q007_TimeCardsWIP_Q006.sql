

CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q007_TimeCardsWIP_Q006] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
TC.TicketId, 
Sum(TC.Hours) AS ActHrs, 
Sum(TC.LaborCostExt) AS LaborCostExt

FROM ufxALP_R_AR_Jm_Q006_TimeCards() AS TC

WHERE TC.StartDate <= @EndDate

GROUP BY TC.TicketId
)