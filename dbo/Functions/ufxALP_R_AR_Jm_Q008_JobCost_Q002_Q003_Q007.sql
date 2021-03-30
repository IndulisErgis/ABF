
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q008_JobCost_Q002_Q003_Q007]    
()     
RETURNS TABLE     
AS    
RETURN     
(    
SELECT     
SVT.TicketId, 
--mah 01/19/2015: corrected the sql below. Null values not handled correctly:   
--Sum(CASE Q003.PartCostExt WHEN Null THEN 0 ELSE Q003.PartCostExt * (1+SVT.PartsOhPct) END )     
--AS PartCost,    
Sum(CASE WHEN  Q003.PartCostExt IS NULL THEN 0 ELSE Q003.PartCostExt * (1+SVT.PartsOhPct) END )     
AS PartCost,   
--mah 08/05/2014 - corrected the sql below.  Null values not handled correctly  
--Sum(CASE Q002.OtherCostExt WHEN Null THEN 0 ELSE Q002.OtherCostExt END) AS OtherCost,    
--Sum(CASE Q007.LaborCostExt WHEN Null THEN 0 ELSE Q007.LaborCostExt END) AS LaborCost,    
--Sum(CASE CommAmt WHEN Null THEN 0 ELSE CommAmt END) AS CommCost,    
--Sum    
--(Round(CASE PartCostExt WHEN Null THEN 0 ELSE PartCostExt * (1+PartsOhPct) END,0)    
-- + (CASE OtherCostExt WHEN Null THEN 0 ELSE OtherCostExt END)    
-- + (CASE LaborCostExt WHEN Null THEN 0 ELSE LaborCostExt END)     
-- + (CASE CommAmt WHEN Null THEN 0 ELSE CommAmt END)     
--) AS JobCost     
Sum(isNull(Q002.OtherCostExt,0)) AS OtherCost,   
Sum(isNull(Q007.LaborCostExt,0)) AS LaborCost,   
Sum(isNull(CommAmt,0)) AS CommCost,  
Sum    
(Round(isNull(PartCostExt,0) * (1+isNull(PartsOhPct,0)),0)    
 + (isNull(OtherCostExt,0))    
 + (isNUll(LaborCostExt,0))     
 + (isNull(CommAmt,0))     
) AS JobCost 
--mah added 1/19/2015: added two fileds that separate PartsCost and OH calculated
,Sum(CASE WHEN Q003.PartCostExt IS NULL THEN 0 ELSE Q003.PartCostExt END ) AS PartsNoOH 
,Sum(CASE WHEN Q003.PartCostExt IS NULL THEN 0 ELSE Q003.PartCostExt * (SVT.PartsOhPct) END ) AS PartsOH       
FROM     
ALP_tblJmSvcTkt AS SVT     
 LEFT JOIN ufxALP_R_AR_Jm_Q002_ActionsOther_Q001() AS Q002    
  ON SVT.TicketId = Q002.TicketId     
 LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionsParts_Q001() AS Q003     
  ON SVT.TicketId = Q003.TicketId     
 LEFT JOIN ufxALP_R_AR_Jm_Q007_TimeCardJobs_Q006() AS Q007    
  ON SVT.TicketId = Q007.TicketId    
    
GROUP BY SVT.TicketId    
    
)