
CREATE FUNCTION [dbo].[ufxALP_IV_ServiceContracts_TC_MAH070117]   
(   
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
TC.TicketId, 
MAX(TC.StartDate) AS LastVisitDate,  
Sum(isNull(Hours,0)) AS ActHrs,   
Sum(isNUll(BillableHrs,0)) AS BillHrs,   
Sum(isNull(TC.Points,0)) AS Pts,   
Sum(isNull(TC.LaborCostExt,0)) AS LaborCostExt  
  
FROM ufxALP_R_AR_Jm_Q006_TimeCards() AS TC  
  
GROUP BY TC.TicketId  
)