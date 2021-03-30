

CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q007c_TimeCards_WIPOffsets_Q006] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
--Converted from Access 11/25 - ER
SELECT 
 qry6.TicketId, 
 qry6.CosOffset, 
 Sum(qry6.Hours) AS ActHrs, 
 Sum(qry6.LaborCostExt) AS LaborCostExt

FROM ufxALP_R_AR_Jm_Q006_TimeCards() AS qry6

WHERE qry6.StartDate <= @EndDate

GROUP BY qry6.TicketId, qry6.CosOffset
)