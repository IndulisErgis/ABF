CREATE Procedure [dbo].[ALP_qryJm110r00RecurBillsWithAllStatus_sp]             
/* RecordSource for Recurring Bills subform of Control Center */            
--EFI# 1707 MAH 08/24/06 - added NextBillDate to output       
-- MAH 10/18/14 - procedure rewritten to include FuturePrice change information, and improve portions of the old query           
-- MAH 11/05/15 - modified to include total Active RMR for the Site, across all services ; InitialTerm and RenewalTerm for each service   
-- MAH 1/7/16 - modified to capture Future Prices for services not yet billed.     
-- Ravi 3/23/2018 - Recurring service status removed from where condition 
 (            
  @SiteId int = null            
 )            
As            
SET NOCOUNT ON        
DECLARE @TotActiveRMR pDec       
SET @TotActiveRMR = 0         
--Build a temporary table of the latest PriceId for each RecurringBill Service associated with the site        
CREATE TABLE #SiteServices            
(            
 RecBillServId int,            
 BilledThruDate smalldatetime NULL,      
 LastOfRecBillServPriceId int,            
 EndBillDate smalldatetime,      
 TotActiveRMR pDec NULL       
)       
--Build a temporary table of any future price changes for any RecurringBill Service associated with the site        
CREATE TABLE #FuturePrices            
(            
 RecBillServId int,            
 FuturePriceId int NULL,        
 FuturePriceStartDate smalldatetime NULL,        
 FuturePrice pDec NULL         
)      
      
--Capture Site Services info            
INSERT INTO #SiteServices ( RecBillServId,BilledThruDate,LastOfRecBillServPriceId, TotActiveRMR )            
 (SELECT S.RecBillServId, S.BilledThruDate, MAX(SP.RecBillServPriceId), 0      
  FROM ALP_tblArAlpSiteRecBill B      
  INNER JOIN ALP_tblArAlpSiteRecBillServ S       
  ON B.RecBillID = S.RecBillID       
  INNER JOIN ALP_tblArAlpSiteRecBillServPrice SP      
  ON S.RecBillServId = SP.RecBillServId           
  WHERE B.SiteId = @SiteId      
  AND SP.RecBillServId = S.RecBillServId      
  GROUP BY S.RecBillServId , S.BilledThruDate, S.ActivePrice )      
         
--Capture the Expire date for the service      
UPDATE #SiteServices            
  SET #SiteServices.EndBillDate = SP.EndBillDate            
  FROM #SiteServices INNER JOIN ALP_tblArAlpSiteRecBillServPrice SP       
  ON   #SiteServices.LastOfRecBillServPriceId = SP.RecBillServPriceId        
            
--Capture the Total active rmr, across all services      
SET @TotActiveRMR = (SELECT SUM(ISNULL(S.ActivePrice,0))            
  FROM #SiteServices T2 INNER JOIN ALP_tblArAlpSiteRecBillServ S      
  ON T2.RecBillServID = S.RecBillServID        
  WHERE S.Status = 'Active')      
UPDATE #SiteServices            
  SET #SiteServices.TotActiveRMR = @TotActiveRMR        
                  
--Capture Future Price change info, if any          
 INSERT INTO #FuturePrices (RecBillServId, FuturePriceId)   
 --mah 1/7/16:     
 --(SELECT SP.RecBillServId, MAX(SP.RecBillServPriceId) ,MIN(SP.RecBillServPriceId)    
 (SELECT SP.RecBillServId, MIN(SP.RecBillServPriceId)        
  FROM ALP_tblArAlpSiteRecBill B      
  INNER JOIN ALP_tblArAlpSiteRecBillServ S       
  ON B.RecBillID = S.RecBillID       
  INNER JOIN ALP_tblArAlpSiteRecBillServPrice SP      
  ON S.RecBillServId = SP.RecBillServId           
  WHERE B.SiteId = @SiteId      
  AND SP.RecBillServId = S.RecBillServId      
  --AND SP.StartBillDate > S.BilledThruDate   
  AND ((S.BilledThruDate is not null and SP.StartBillDate > S.BilledThruDate )   
 OR  S.BilledThruDate is null )       
  GROUP BY SP.RecBillServId  )      
        
--Capture the future price start dates and amounts       
UPDATE #FuturePrices        
 SET    FuturePriceStartDate  =  CASE WHEN SP.StartBillDate IS NULL THEN NULL   
       WHEN S.BilledThruDate IS NULL THEN NULL ELSE SP.StartBillDate END ,   
  FuturePrice = CASE WHEN SP.StartBillDate IS NULL THEN NULL   
       WHEN S.BilledThruDate IS NULL THEN NULL ELSE SP.RMR  END       
 FROM ALP_tblArAlpSiteRecBillServPrice   SP      
  INNER JOIN #FuturePrices t        
  ON  t.FuturePriceId = SP.RecBillServPriceId            
   AND t.RecBillServId = SP.RecBillServId    
   INNER JOIN #SiteServices S ON t.RecBillServID = S.RecBillServID    
 --WHERE t.FuturePriceId IS NOT NULL AND FuturePriceId <> ActivePriceId    
 WHERE t.FuturePriceId IS NOT NULL          
             
--Create the recordset to populate the Recur Bills tab on the Control Center form            
SELECT  [Group] = ALP_tblArAlpSiteRecBill.ItemId,             
   [Bill To] = ALP_tblArAlpSiteRecBill.CustId,             
   [Svc ID] = ALP_tblArAlpSiteRecBillServ.ServiceID,             
   ALP_tblArAlpSiteRecBillServ.Status,            
   Freq = ALP_tblArAlpCycle.Cycle,             
   RMR = ALP_tblArAlpSiteRecBillServ.ActivePrice,            
   Starts = CAST(ALP_tblArAlpSiteRecBillServ.ServiceStartDate AS DATE),             
   Expires = CAST(#SiteServices.EndBillDate AS DATE),             
   [Ext Repair Plan] = ALP_tblArAlpRepairPlan.RepPlan,            
   ALP_tblArAlpSiteRecBillServ.SysId,            
   NextBillDate = CAST(ALP_tblArAlpSiteRecBill.NextBillDate AS DATE),            
   ALP_tblArAlpSiteSys.SysDesc,            
   ALP_tblArAlpSiteSys.AlarmID,            
   ALP_tblArAlpSiteRecBillServ.RecBillServId,        
   #FuturePrices.FuturePrice,        
   FutureStartDate = CAST(#FuturePrices.FuturePriceStartDate AS DATE),      
   ALP_tblArAlpSiteRecBillServ.InitialTerm as ContractTerm,      
   ContractEnds = CAST(DATEADD(m,ALP_tblArAlpSiteRecBillServ.InitialTerm,ALP_tblArAlpSiteRecBillServ.ServiceStartDate)  AS DATE),      
   ALP_tblArAlpSiteRecBillServ.RenTerm AS RenewalTerm,      
   ISNULL(#SiteServices.TotActiveRMR, 0) as TotActiveRMR,    
   ALP_tblArAlpSiteRecBillServ.[Desc] -- added by NSK on 18 Nov 2015    
FROM ((ALP_tblArAlpSiteRecBill             
 INNER JOIN ALP_tblArAlpCycle             
  ON ALP_tblArAlpSiteRecBill.BillCycleId = ALP_tblArAlpCycle.CycleId)            
 INNER JOIN (      
   (ALP_tblArAlpSiteRecBillServ             
    LEFT JOIN ALP_tblArAlpRepairPlan             
    ON ALP_tblArAlpSiteRecBillServ.ExtRepPlanId = ALP_tblArAlpRepairPlan.RepPlanId)             
   LEFT JOIN #SiteServices             
   ON ALP_tblArAlpSiteRecBillServ.RecBillServId = #SiteServices.RecBillServId      
   LEFT JOIN #FuturePrices      
   ON #SiteServices.RecBillServId = #FuturePrices.RecBillServId)            
   ON ALP_tblArAlpSiteRecBill.RecBillId = ALP_tblArAlpSiteRecBillServ.RecBillId)               
 LEFT JOIN ALP_tblArAlpSiteSys       
  ON ALP_tblArAlpSiteRecBillServ.SysID=ALP_tblArAlpSiteSys.SysID            
WHERE              
 ALP_tblArAlpSiteSys.SiteId = @SiteId
 --Below code commentted by ravi on 23 march 2018, to fix the bugid 708,
 -- AND             
   -- ( (ALP_tblArAlpSiteRecBillServ.Status='New')            
    --OR (ALP_tblArAlpSiteRecBillServ.Status='Active'))             
ORDER BY ALP_tblArAlpSiteRecBill.ItemId,ALP_tblArAlpSiteRecBillServ.ServiceStartDate, ALP_tblArAlpSiteRecBillServ.ServiceId       
           
DROP TABLE #SiteServices        
DROP TABLE #FuturePrices