/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2012 (11.0.2100)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

CREATE Procedure [dbo].[ALP_qryJm110r00RecurBills]                   
/* RecordSource for Recurring Bills subform of Control Center */                  
--EFI# 1707 MAH 08/24/06 - added NextBillDate to output             
-- MAH 10/18/14 - procedure rewritten to include FuturePrice change information, and improve portions of the old query                 
-- MAH 11/05/15 - modified to include total Active RMR for the Site, across all services ; InitialTerm and RenewalTerm for each service         
-- MAH 1/7/16 - modified to capture Future Prices for services not yet billed.      
-- Ravi 3/26/2018 - modified query, change the query for in last select statement, Join changed ALP_tblArAlpSiteRecBillServ table instead of ALP_tblArAlpSiteRecBill         
-- Ravi 3/04/2019 - Where condition modified the service status code commentted for to fix the bugix 917  
-- DMM 20190514 - Changes to calculate RMR N.RMR using same logic as Sites screen. Bug 938  
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
 RecBillServPriceId int,                  
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
INSERT INTO #SiteServices ( RecBillServId,RecBillServPriceId, BilledThruDate,LastOfRecBillServPriceId, TotActiveRMR )                  
 (
SELECT billServ.RecBillServId, servPrice.RecBillServPriceId, billServ.BilledThruDate, 
servPriceFP.RecBillServPriceId,
0            

from
	ALP_tblArAlpSiteRecBill recBill         
	inner join ALP_tblArAlpSiteRecBillServ billServ             
		on billServ.RecBillID = recBill.RecBillID   
	inner join ALP_tblArAlpSiteRecBillServPrice servPrice 
		on servPrice.RecBillServId = billServ.RecBillServId
	left outer join ALP_tblArAlpSiteRecBillServPrice servPrice2
		on servPrice.RecBillServId = servPrice2.RecBillServId
		and servPrice.StartBillDate > servPrice2.StartBillDate
	left outer join ALP_tblArAlpSiteRecBillServPrice servPriceFP
		on servPriceFP.RecBillServPriceId =		(
													select
														min(RecBillServPriceId)
													from
														ALP_tblArAlpSiteRecBillServPrice sp
														inner join ALP_tblArAlpSiteRecBillServ bs
															on bs.RecBillServId = sp.RecBillServId
														inner join ALP_tblArAlpSiteRecBill rb
															on bs.RecBillID = rb.RecBillID   
													where
														sp.RecBillServId = billServ.RecBillServId
														and RecBillServPriceId <> servPrice.RecBillServPriceId
														--and (
														--		(bs.BilledThruDate is not null and sp.StartBillDate > bs.BilledThruDate )         
														--		OR bs.BilledThruDate is null
														--	)
														and
														sp.StartBillDate is not NULL
														AND sp.StartBillDate = DATEADD(day, 1, servPrice.EndBillDate)
													)
where
	servPrice2.RecBillServPriceId is null
	and recBill.SiteId=@SiteId
)

--select 'initipull', * from #SiteServices
              
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

--select '#SiteServices', * from #SiteServices
                       
--Capture Future Price change info, if any                
--get ALP_tblArAlpSiteRecBillServPrice.RecBillServPriceId showing future price
INSERT INTO #FuturePrices (RecBillServId, FuturePriceId)         
(
	select
		sp.RecBillServId,
		min(sp.RecBillServPriceId)
	from
		ALP_tblArAlpSiteRecBillServPrice sp
		inner join ALP_tblArAlpSiteRecBillServ bs
			on bs.RecBillServId = sp.RecBillServId
		inner join ALP_tblArAlpSiteRecBill rb
			on bs.RecBillID = rb.RecBillID   
		inner join #SiteServices ss
			on ss.RecBillServId = sp.RecBillServId
	where
		sp.RecBillServId = ss.RecBillServId
		and sp.RecBillServPriceId <> ss.RecBillServPriceId
		and (
				(bs.BilledThruDate is not null and sp.StartBillDate > bs.BilledThruDate )         
				OR bs.BilledThruDate is null
	 		)
  GROUP BY SP.RecBillServId 
)            

--select '#FuturePricesStart', * from #FuturePrices
             
--Capture the future price start dates and amounts             
UPDATE #FuturePrices              
 SET
	FuturePriceStartDate = SPFP.StartBillDate,
	FuturePrice =
				CASE
					when SPFP.StartBillDate is not NULL	AND SPFP.StartBillDate = DATEADD(day, 1, SP.EndBillDate) then SPFP.Price
					else null
				end
from
	#FuturePrices t              
	inner join #SiteServices SS
		on SS.RecBillServId = t.RecBillServId            
	inner join ALP_tblArAlpSiteRecBillServPrice SP            
		ON SP.RecBillServPriceId = ss.RecBillServPriceId                  
	inner join ALP_tblArAlpSiteRecBillServPrice SPFP            
		ON SPFP.RecBillServPriceId = ss.LastOfRecBillServPriceId                    

--select '#FuturePrices', * from #FuturePrices

                   
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
FROM (      
-- Ravi 3/26/2018 -   Join changed ALP_tblArAlpSiteRecBillServ table instead of ALP_tblArAlpSiteRecBill for fetch the service record        
  --(      
  ALP_tblArAlpSiteRecBill                   
  --)                  
 INNER JOIN (            
   (ALP_tblArAlpSiteRecBillServ                   
   LEFT JOIN ALP_tblArAlpRepairPlan                   
   ON ALP_tblArAlpSiteRecBillServ.ExtRepPlanId = ALP_tblArAlpRepairPlan.RepPlanId)                   
   INNER JOIN ALP_tblArAlpCycle                   
   ON ALP_tblArAlpSiteRecBillServ.activecycleid = ALP_tblArAlpCycle.CycleId      
   LEFT JOIN #SiteServices                   
   ON ALP_tblArAlpSiteRecBillServ.RecBillServId = #SiteServices.RecBillServId            
   LEFT JOIN #FuturePrices            
   ON #SiteServices.RecBillServId = #FuturePrices.RecBillServId)                  
   ON ALP_tblArAlpSiteRecBill.RecBillId = ALP_tblArAlpSiteRecBillServ.RecBillId)                     
 LEFT JOIN ALP_tblArAlpSiteSys             
  ON ALP_tblArAlpSiteRecBillServ.SysID=ALP_tblArAlpSiteSys.SysID                  
WHERE                    
 ALP_tblArAlpSiteSys.SiteId = @SiteId     
 --Below Service status logic commented by ravi on 4th march 2019, to fix the bugix 917  
 --AND     ( (ALP_tblArAlpSiteRecBillServ.Status='New')                  
 --   OR (ALP_tblArAlpSiteRecBillServ.Status='Active'))                   
ORDER BY ALP_tblArAlpSiteRecBill.ItemId,ALP_tblArAlpSiteRecBillServ.ServiceStartDate, ALP_tblArAlpSiteRecBillServ.ServiceId             
                 
DROP TABLE #SiteServices              
DROP TABLE #FuturePrices