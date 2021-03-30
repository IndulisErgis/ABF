
/* from qryJm-Q033B-ProjJobCostDetail */
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q033B_ProjJobCostDetail] 
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
SVCTKT.TicketId, 
Sum(CASE WHEN PartCostExt Is Null THEN 0 ELSE PartCostExt END ) AS PartCost, 
Sum(CASE WHEN PartCostExt Is Null THEN 0 ELSE PartCostExt * PartsOhPct END ) AS PartOh,
--Added fields for split 'other' costs - ERR - 9/9/15
--Sum(CASE WHEN OtherCostExt Is Null THEN 0 ELSE OtherCostExt END) AS OtherCost, 
Sum(CASE WHEN Q21P.OtherCostExt Is Null THEN 0 ELSE Q21P.OtherCostExt END) AS OtherPartCost, 
Sum(CASE WHEN Q21C.OtherCostExt Is Null THEN 0 ELSE Q21C.OtherCostExt END) AS OtherCost, 
Sum(CASE WHEN LaborCostExt Is Null THEN 0 ELSE LaborCostExt END) AS LaborCost, 
Sum(CASE WHEN CommAmt Is Null THEN 0 ELSE CommAmt END) AS CommCost,
Sum(
	( CASE WHEN PartCostExt Is Null THEN 0 ELSE (PartCostExt * (1+PartsOhPct)) END)
	--modified totaling of jobcost to include both 'other' sources - ERR - 9/9/15
	--+ CASE WHEN OtherCostExt Is Null THEN 0 ELSE OtherCostExt END
	+ CASE WHEN Q21P.OtherCostExt Is Null THEN 0 ELSE Q21P.OtherCostExt END
	+ CASE WHEN Q21C.OtherCostExt Is Null THEN 0 ELSE Q21C.OtherCostExt END
	+ CASE WHEN LaborCostExt Is Null THEN 0 ELSE LaborCostExt END
	+ CASE WHEN CommAmt Is Null THEN 0 ELSE CommAmt END )
	
	AS JobCost, 
--modified OtherPrice calculation to include both 'other' sources - ERR - 9/9/15	
--Sum(CASE WHEN OtherPriceExt Is Null THEN 0 ELSE OtherPriceExt END ) AS OtherPrice
(Sum(CASE WHEN Q21P.OtherPriceExt Is Null THEN 0 ELSE Q21P.OtherPriceExt END )
+Sum(CASE WHEN Q21C.OtherPriceExt Is Null THEN 0 ELSE Q21C.OtherPriceExt END )) AS OtherPrice

FROM ALP_tblJmSvcTkt AS SVCTKT
	--Join two action other functions instead of original sigular source - ERR - 9/9/15
	--LEFT JOIN ufxALP_R_AR_Jm_Q002_ActionsOther_Q001() AS Q21 
	--	ON SVCTKT.TicketId = Q21.TicketId 
	LEFT JOIN ufxALP_R_AR_Jm_Q002_ActionsOtherParts_Q001() AS Q21P 
		ON SVCTKT.TicketId = Q21P.TicketId 
	LEFT JOIN ufxALP_R_AR_Jm_Q002_ActionsOtherCosts_Q001() AS Q21C 
		ON SVCTKT.TicketId = Q21C.TicketId 	
	LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionsParts_Q001() AS Q31 
		ON SVCTKT.TicketId = Q31.TicketId 
	LEFT JOIN ufxALP_R_AR_Jm_Q007_TimeCardJobs_Q006() AS Q76 
		ON SVCTKT.TicketId = Q76.TicketId

WHERE SVCTKT.ProjectId Is Not Null

GROUP BY SVCTKT.TicketId

)