CREATE function [dbo].[ufx_IV_R205c_SalesSummary_PV]            
           
(              
@BeginOrderDate dateTime,              
@EndOrderDate dateTime              
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
 ContrYY = CAST(DatePart(year,J.[OrderDate]) as char(4)),              
 ContrMM = CAST(DatePart(month,J.[OrderDate]) as char(2)),              
 --OrderDate = MIN(J.OrderDate),              
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
       
 EstLabCost = ROUND(SUM(isNull(J.EstCostLabor,0)),2), -- 02-10-2014 JVH takes out his line, use old, no NULLs in ProjectID.            
           
 EstMiscCost = ROUND(SUM(isNull(J.EstCostMisc,0)),2),              
 RMRExpense = ROUND(SUM(IsNull(J.RMRExpense,0)),2),              
 RMRAdded = ROUND(SUM(IsNull(J.RMRAdded,0)),2),              
 DiscRatePct = Max(isNull(J.DiscRatePct,0)),              
 --ContractMths = Max(isNull(J.ContractMths,0)),              
 CommAmt = ROUND(SUM(IsNull(J.CommAmt,0)),2),              
 PartsPrice =ROUND(SUM(IsNull(J.PartsPrice,0)),2),              
 LaborPrice = ROUND(SUM(IsNull(J.LaborPrice,0)),2),              
 OtherPrice = ROUND(SUM(IsNull(J.OtherPrice,0)),2),              
 JobPrice = ROUND(SUM(IsNull(J.JobPrice,0)),2),        
 --mah 03/02/15:        
 D.Division  ,  
 GrossPV  = (ROUND((SUM(IsNull(J.JobPrice,0)))-(SUM( isNull(J.EstCostParts,0)              
 + isNull(J.EstCostLabor,0)              
 + isNull(J.EstCostMisc,0)))   
  + SUM(dbo.ufxPresentValue(ISNULL(J.RMRAdded,0)-ISNULL(J.RMRExpense,0), .10, ISNULL(J.ContractMths,0))),2))  ,
  MIN(OrderDate) as InitialOrderDate,
  MIN(TicketId) as FirstTicket
 --,  
 --NetPV = CAST(ROUND(J.JobPrice-ISNULL(EstCost , 0) - ISNULL(CommAmt,0)   
 -- + dbo.ufxPresentValue(ISNULL(J.RMRAdded,0)-ISNULL(J.RMRExpense,0), .10, ISNULL(J.ContractMths,0)),2) AS Decimal(10,2))  
             
              
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