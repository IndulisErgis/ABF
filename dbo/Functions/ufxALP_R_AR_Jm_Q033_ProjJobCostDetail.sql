

--converted from access qryJm-Q033-ProjJobCostDetail - 02/19/15 - ER
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q033_ProjJobCostDetail] 
(
	@EndDate dateTime	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
--added OtherPartCost and changed what function OtherCost comes from - ER - 8/9/15
SVCTKT.TicketId, 
Q10b.ProjCompleteDate AS CompleteDate,
Sum(CASE WHEN PartCostExt Is Null THEN 0 ELSE PartCostExt END ) AS PartCost, 
Sum(CASE WHEN PartCostExt Is Null THEN 0 ELSE PartCostExt * PartsOhPct END ) AS PartOh, 
Sum(CASE WHEN Q21P.OtherCostExt Is Null THEN 0 ELSE Q21P.OtherCostExt END) AS OtherPartCost, 
Sum(CASE WHEN Q21C.OtherCostExt Is Null THEN 0 ELSE Q21C.OtherCostExt END) AS OtherCost, 
Sum(CASE WHEN LaborCostExt Is Null THEN 0 ELSE LaborCostExt END) AS LaborCost, 
Sum(CASE WHEN CommAmt Is Null THEN 0 ELSE CommAmt END) AS CommCost,
Sum(
	( CASE WHEN PartCostExt Is Null THEN 0 ELSE (PartCostExt * (1+PartsOhPct)) END)
	+ CASE WHEN Q21P.OtherCostExt Is Null THEN 0 ELSE Q21P.OtherCostExt END
	+ CASE WHEN Q21C.OtherCostExt Is Null THEN 0 ELSE Q21C.OtherCostExt END
	+ CASE WHEN LaborCostExt Is Null THEN 0 ELSE LaborCostExt END
	+ CASE WHEN CommAmt Is Null THEN 0 ELSE CommAmt END )
	
	AS JobCost
--Sum(CASE WHEN OtherPriceExt Is Null THEN 0 ELSE OtherPriceExt END ) AS OtherPrice

--Added join for ActionOtherParts function and modified ActionOther join to ActionOtherCosts - ER - 9/8/15
FROM 
ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c(@EndDate) AS Q10b
	INNER JOIN ((((ALP_tblJmSvcTkt AS SVCTKT
	LEFT JOIN ufxALP_R_AR_Jm_Q002_ActionsOtherParts_Q001() AS Q21P 
		ON SVCTKT.TicketId = Q21P.TicketId) 
	LEFT JOIN ufxALP_R_AR_Jm_Q002_ActionsOtherCosts_Q001() AS Q21C 
		ON SVCTKT.TicketId = Q21C.TicketId) 
	LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionsParts_Q001() AS Q31 
		ON SVCTKT.TicketId = Q31.TicketId) 
	LEFT JOIN ufxALP_R_AR_Jm_Q007_TimeCardJobs_Q006() AS Q76 
		ON SVCTKT.TicketId = Q76.TicketId)
		ON SVCTKT.ProjectId = Q10b.ProjectId

GROUP BY SVCTKT.TicketId,Q10b.ProjCompleteDate

)