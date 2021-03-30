CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q005_JobPrice_Q002] 
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
SVT.TicketId, 
Sum(SVT.PartsPrice) AS PartPrice, 
Sum(SVT.LabPriceTotal) AS LaborPrice, 
Sum(CASE WHEN OtherPriceExt IS NULL  THEN 0 ELSE OtherPriceExt END) AS OtherPrice, 
Sum(
PartsPrice+
LabPriceTotal+
CASE  WHEN OtherPriceExt IS NULL THEN 0 ELSE OtherPriceExt END ) AS JobPrice

FROM ALP_tblJmSvcTkt AS SVT
	LEFT JOIN ufxALP_R_AR_Jm_Q002_ActionsOther_Q001() 
		ON SVT.TicketId = ufxALP_R_AR_Jm_Q002_ActionsOther_Q001.TicketId
		
GROUP BY SVT.TicketId
)