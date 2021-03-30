
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q003_ActionsParts_Q001]     
(     
)    
RETURNS TABLE     
AS    
RETURN     
(    
SELECT     
AA.TicketId,     
Round(Sum(isNull(AA.Price,0)*isNull(AA.Qty,0)),2) AS PartPriceExt,     
Round(Sum(isNUll(AA.Cost,0)* isNull(AA.Qty,0)),2) AS PartCostExt    
    
FROM ALP_R_JmAllActions_view AS AA    
    
WHERE AA.Type='Part'    
    
GROUP BY AA.TicketId    
    
)