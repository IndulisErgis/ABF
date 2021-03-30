--Converted from access qryJm-Q016-PointsByJob - 3/31/16 - ER
CREATE Function  [dbo].[ufxALP_R_AR_Jm_Q016_PointsByJob]
(    
)   
RETURNS TABLE   
AS  
RETURN   
(  
  
SELECT 
SvcTkt.TicketId, 
Sum(SvcTkt.TotalPts) AS JobPts

FROM ALP_tblJmSvcTkt AS SvcTkt

GROUP BY SvcTkt.TicketId
  
)