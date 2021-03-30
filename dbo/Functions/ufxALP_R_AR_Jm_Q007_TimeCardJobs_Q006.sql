CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q007_TimeCardJobs_Q006]   
(   
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
TC.TicketId,   
Sum(isNull(Hours,0)) AS ActHrs,   
Sum(isNUll(BillableHrs,0)) AS BillHrs,   
Sum(isNull(TC.Points,0)) AS Pts,   
Sum(isNull(TC.LaborCostExt,0)) AS LaborCostExt  
  
FROM ufxALP_R_AR_Jm_Q006_TimeCards() AS TC  
  
GROUP BY TC.TicketId  
)