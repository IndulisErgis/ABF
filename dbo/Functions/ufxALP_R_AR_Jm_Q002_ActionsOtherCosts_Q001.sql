
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q002_ActionsOtherCosts_Q001]   
(  
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
AA.TicketId,   
Round(Sum(isnull(AA.Price,0)* isnull(AA.qty,0)),2) AS OtherPriceExt,   
Round(Sum(isnull(AA.Cost,0)* isnull(AA.qty,0)),0) AS OtherCostExt  
  
FROM ALP_R_JmAllActions_view AS AA  
  
WHERE AA.Type ='Other' AND (AA.ItemType = '3')
  
GROUP BY AA.TicketId  
)