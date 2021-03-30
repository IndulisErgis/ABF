

CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q006_TimeCards] 
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
TCard.TimeCardID, 
TCard.TechID, 
JT.Tech, 
TCard.StartDate, 


TCard.StartTime/60 AS StartTimeHours,
TCard.StartTime % 60 AS StartTimeMod, 

--Format(TimeSerial([StartTime]/60,[StartTime] Mod 60,0),"Medium Time") AS [Time],
-- Build in SSRS
 
(TCard.EndTime - TCard.StartTime)/60 AS Hours, 

TCode.TimeCode, 
TCard.SvcJobYN, 
TCard.TicketId, 
TCard.BillableHrs, 
TCard.Points, 
CASE TCard.PayBasedOn 
	WHEN 0 THEN (CAST(TCard.EndTime - TCard.StartTime As decimal(18,2)))/60 * TCard.LaborCostRate
	WHEN 1 THEN (TCard.Points * TCard.PworkRate) + 
		(TCard.Points * TCard.PworkRate * PworkLabMarkupPct) 
	--corrected truncation problem - 06/15/16 - MAH & ERR	
	ELSE ((CAST(TCard.EndTime - TCard.StartTime As decimal(18,2)))/60) * TCard.LaborCostRate 
	END AS LaborCostExt,
JT.CosOffset

FROM 
ALP_tblJmTimeCode AS TCode
	RIGHT JOIN ((ALP_tblJmTimeCard AS TCard 
	INNER JOIN ALP_tblJmTech AS JT 
		ON TCard.TechID = JT.TechId) 
	LEFT JOIN ALP_tblJmSvcTkt AS ST 
		ON TCard.TicketId = ST.TicketId) 
		ON TCode.TimeCodeID = TCard.TimeCodeID

)