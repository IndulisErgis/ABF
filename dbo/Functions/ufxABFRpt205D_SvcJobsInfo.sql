  
CREATE function [dbo].[ufxABFRpt205D_SvcJobsInfo]  
--060315 mah
(  
@BeginOrderDate DateTime,  
@EndOrderDate DateTime  
)  
Returns table  
AS  
Return  
(  
SELECT ST.TicketId,  
 ST.SalesRepID,   
 ST.CustID,  
 CustName = (  
  SELECT CustName   
  FROM ALP_tblArCust_view   
  WHERE CustID = ST.CustID),  
 ST.ProjectID,  
 ST.DivID, 
 --060315 mah:
 ST.CancelDate, 
 ST.OrderDate,  
 ST.SiteId,  
 ST.LseYn,  
 CO = CASE WHEN ST.CsConnectYn = 0 THEN 0 ELSE 1 END,  
 RMRExpense = isNull(ST.RMRExpense,0),  
 RMRAdded = isNull(ST.RMRAdded,0),  
 ST.DiscRatePct,  
 ST.ContractID,  
 ContractMths = (  
  SELECT DfltBillTerm   
  FROM ALP_tblArAlpCustContract   
  WHERE ContractID = ST.ContractID),  
 ContractValue = (  
  SELECT ContractValue   
  FROM ALP_tblArAlpCustContract   
  WHERE (ContractID = ST.ContractID)  
  --AND (ContractValue IS NOT NULL) -- undo this change 2-10-2014, ContractValue contains no nulls    
  --AND (ContractValue<>0) -- mod 02/03/14 JVH - correct sort issue in rpt R205B? - undo this change 2-10-2014  
  ),  
 CommAmt = isNull(ST.CommAmt,0),  
 PartsPrice = isnull(ST.PartsPrice,0),  
 LaborPrice = isNull(ST.LabPriceTotal,0),  
 OtherPrice = CASE   
  WHEN OPC.OtherPrice Is Null   
  THEN 0 ELSE OPC.OtherPrice   
  END,  
 JobPrice =  isNull(ST.PartsPrice,0) + isNull(ST.LabPriceTotal,0)  
  + (CASE   
   WHEN OPC.OtherPrice Is Null   
   THEN 0 ELSE OPC.OtherPrice   
   END),  
 EstCostParts = isNUll(ST.EstCostParts,0),  
 EstCostMisc = isNull(ST.EstCostMisc,0), -- JVH 2-10-14 added  
 EstCostLabor = isNull(ST.EstCostLabor,0)-- JVH 2-10-14 added  
   
FROM ALP_tblJmSvcTkt ST  
 LEFT OUTER JOIN dbo.ufxAlpSvcJobPriceCost_PartsOther(NULL,NULL,@BeginOrderDate,@EndOrderDate) AS OPC  
  ON ST.TicketId = OPC.TicketId   
    
--select only jobs related to projects  
WHERE (ST.ProjectID IS NOT NULL)   
 AND (RTRIM(ProjectID) <> '') -- update 2-3-14 MAH/JVH correct blanks in rpt R205B 
 -- mah 060315 
 --AND (ST.Status <> 'canceled') 
 AND (ST.Status = 'canceled')   
 --AND (ST.OrderDate BETWEEN isNull(@BeginOrderDate,'01/01/1900') AND isNull(@EndOrderDate,'12/12/2100') )
 AND (ST.CancelDate BETWEEN isNull(@BeginOrderDate,'01/01/1900') AND isNull(@EndOrderDate,'12/12/2100') )   
)