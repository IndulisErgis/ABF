
 
    
CREATE function [dbo].[ufxABFRpt205B_ProjInfo]      
 /* Purpose: Summarizes Price,Cost,Commissions data , by Project    */        
 /*  Used in Alpine Reports by ABF custom report ABF205B   */        
 /* Parameters:           */        
 /*       @BeginOrderDate and @EndOrderDate define the OrderDate filter.  */        
 /*  To select all OrderDates, enter NULL for each date parameter.  */         
 /* History: created 02/13/12 mah       */   
 --mah 03/02/15: added fields        
(        
@BeginOrderDate datetime,        
@EndOrderDate datetime        
)        
Returns table        
AS        
Return        
(        
SELECT TOP 100 PERCENT        
 J.SalesRepID,         
 J.CustID,        
 J.CustName,        
 J.ProjectID,       
 J.ContractID,      
 --J.ContractValue,      
ContractValue = isNull(J.ContractValue,0), -- jvh 2-20-14      
       
 --ContrYYMM = J.OrderDate,        
 ContrYY = CAST(DatePart(year,J.[OrderDate]) as char(4)),        
 ContrMM = CAST(DatePart(month,J.[OrderDate]) as char(2)),        
 OrderDate = MIN(J.OrderDate),        
 J.SiteId,    
 --MAH  06/30/14:  disable separation by Lease/Purchase, by assigning constant value of '-'      
 --'-' AS LseYn,       
 LseYn = CASE WHEN SUM( CAST(J.LseYn as int)) > 0 THEN 'L' ELSE 'P' END,    
 --J.LseYn,       
 CO = SUM(J.CO),       
 EstCost = SUM(      
 isNull(J.EstCostParts,0)        
 + isNull(J.EstCostLabor,0)        
 + isNull(J.EstCostMisc,0)),        
--------------------------------------------------------      
 EstMatCost = ROUND(SUM(isNull(J.EstCostParts,0)),2),  -- 02-10-2014 JVH takes out this line, use old, no NULLs in ProjectID.      
 -- restored to orig, JVH      
      
   -- EstMatCost = CASE        
   --   WHEN J.ProjectID IS NULL THEN 0        
   --   ELSE (SELECT IsNull(EstMatCost,0) FROM tblJmSvcTktProject WHERE ProjectID = J.ProjectID)        
   --   END,        
      
    -- EstMatCost = ROUND(SUM(isNull(J.EstCostParts,0)),2),  -- 02-10-2014 JVH takes out this line, use old, no NULLs in ProjectID.      
    -- NOTE EstMatCost(OLD) different from EstCostParts (NEW), change       
    -- EstMatCost = (SELECT IsNull(EstCostParts,0) FROM ALP_tblJmSvcTktProject WHERE ProjectID = J.ProjectID),      
--------------------------------------------------------      
      
 EstLabCost = ROUND(SUM(isNull(J.EstCostLabor,0)),2), -- 02-10-2014 JVH takes out his line, use old, no NULLs in ProjectID.      
-- restored to orig, JVH      
   -- EstLabCost = CASE        
   --   WHEN J.ProjectID IS NULL THEN 0        
   --   ELSE (SELECT IsNull(EstLabCost,0) FROM tblJmSvcTktProject WHERE ProjectID = J.ProjectID)        
   --   END,        
    --EstLabCost = ROUND(SUM(isNull(J.EstCostLabor,0)),2), -- 02-10-2014 JVH takes out his line, use old, no NULLs in ProjectID.      
    -- NOTE EstLabCost(OLD) different from EstCostLabor), change      
    -- EstLabCost = (SELECT IsNull(EstCostLabor,0) FROM ALP_tblJmSvcTktProject WHERE ProjectID = J.ProjectID),        
 --------------------------------------------------------       
 EstMiscCost = ROUND(SUM(isNull(J.EstCostMisc,0)),2),        
 RMRExpense = ROUND(SUM(IsNull(J.RMRExpense,0)),2),        
 RMRAdded = ROUND(SUM(IsNull(J.RMRAdded,0)),2),        
 DiscRatePct = Max(isNull(J.DiscRatePct,0)),        
 ContractMths = Max(isNull(J.ContractMths,0)),        
 CommAmt = ROUND(SUM(IsNull(J.CommAmt,0)),2),        
 PartsPrice =ROUND(SUM(IsNull(J.PartsPrice,0)),2),        
 LaborPrice = ROUND(SUM(IsNull(J.LaborPrice,0)),2),        
 OtherPrice = ROUND(SUM(IsNull(J.OtherPrice,0)),2),        
 JobPrice = ROUND(SUM(IsNull(J.JobPrice,0)),2),  
 --mah 03/02/15:  
 D.Division  
        
FROM   ufxABFRpt205B_SvcJobsInfo(@BeginOrderDate,@EndOrderDate) AS J   
--mah added:  
    INNER JOIN ALP_tblArAlpDivision AS D       
   ON J.DivId = D.DivisionId        
 --uses same input function as report ABF206        
 --select only commercial projects        
 --WHERE  J.DivID IN (1,2)         
GROUP BY J.SalesRepID,         
  J.CustID,        
  J.CustName,        
  J.ProjectID,     
  J.ContractID,      
  J.ContractValue,       
  CAST(DatePart(year,J.[OrderDate]) as char(4)),        
  CAST(DatePart(month,J.[OrderDate]) as char(2)),        
  J.SiteId  
  --mah added 3/2/15:  
  ,D.Division       
  --J.LseYn      
        
ORDER BY       
 J.SalesRepID,        
 J.CustName,        
 J.ProjectID,       
 J.ContractID,       
 CAST(DatePart(year,J.[OrderDate]) as char(4)),        
 CAST(DatePart(month,J.[OrderDate]) as char(2))        
)