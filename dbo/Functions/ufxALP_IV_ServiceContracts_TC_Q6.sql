
CREATE FUNCTION [dbo].[ufxALP_IV_ServiceContracts_TC_Q6]   
(   
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
TicketId as Q6TicketId, 
MAX(StartDate) AS Q6LastVisitDate,  
Sum(isNull(Hours,0)) AS Q6ActHrs,   
Sum(isNUll(BillableHrs,0)) AS Q6BillableHrs,   
Sum(isNull(Points,0)) AS Q6Pts,   
Sum(isNull(LaborCostExt,0)) AS Q6LaborCostExt  
  
FROM ufxALP_R_AR_Jm_Q006_TimeCards()  
WHERE StartDate is not null  
GROUP BY TicketId  

-- or use:ALP_ufxJmLastDate(@ticketID)
)