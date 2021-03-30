CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_FinalizeRun_TEST]  
(  
 @RunId INT  
)  
AS  
BEGIN  
 DECLARE @NextBillDate DATETIME  
 SELECT  
  @NextBillDate = [r].[NextBillDate]  
 FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r]  
 WHERE [r].[RunId] = @RunId  
   
 -- replaces dbo.qryArAlpUpdateNewActivePrices in TRAV 10  
 -- Doing this at the end of the run because we don't use the service activefields for anything. here for backwards compat.  
 UPDATE [rbs]  
 SET [ActivePrice] = [rbsp].[Price],  
  [ActiveRMR] = [rbsp].[RMR],  
  [Status] = 'Active',  
  [Processed] = 1  
 FROM [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
  ON [rbsp].[RecBillServId] = [rbs].[RecBillServId]  
  AND [rbsp].[StartBillDate] = [rbs].[ServiceStartDate]  
 INNER JOIN [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
  ON [rr].[RecBillServId] = [rbs].[RecBillServId]  
 WHERE [rr].[RunId] = @RunId  
	--mah 08/07/14 - removed [ActivePrice] = 0 , because no longer set that way in Sites form
	--AND [rbs].[ActivePrice] = 0  
  AND [rbs].[Status] IN ('New', 'Active')  
  AND [rbs].[ServiceStartDate] <= @NextBillDate  
  AND ([rbsp].[EndBillDate] IS NULL OR [rbsp].[EndBillDate] >= @NextBillDate)  
    
 UPDATE [rbsp]  
 SET [ActiveYn] = 1  
 FROM [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
  ON [rbsp].[RecBillServId] = [rbs].[RecBillServId]  
  AND [rbsp].[StartBillDate] = [rbs].[ServiceStartDate] 
	--mah added the join with the RecRunRecords - to avoid changing more items than expected
	INNER JOIN [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]
	ON	[rr].[RecBillServId] = [rbs].[RecBillServId] 
 WHERE 
 	--mah 08/07/14 - removed [ActivePrice] = 0 , because no longer set that way in Sites form
	--[rbs].[ActivePrice] = 0  
	--AND 
  [rbsp].[ActiveYn] <> 1  
  AND [rbs].[ServiceStartDate] <= @NextBillDate  
  AND ([rbsp].[EndBillDate] IS NULL OR [rbsp].[EndBillDate] >= @NextBillDate)  
  
    
 -- replaces dbo.qryArAlpUpdateServiceStatusNew  
 UPDATE [rbs]  
 SET [rbs].[Status] = 'Active',  
  [rbs].[Processed] = 1  
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
  ON [rbs].[RecBillServId] = [rr].[RecBillServId]  
 INNER JOIN  [dbo].[ALP_tblArAlpSiteRecBill] AS [rb] 
  ON [rb].[RecBillId] = [rbs].[RecBillId]  
  AND [rbs].[RecBillServId] = [rr].[RecBillServId]  
 WHERE [rr].[RunId] = @RunId  
  AND [rbs].[Status] IN ('New', 'Active')  
  AND [rbs].[ServiceStartDate] <= [rb].[NextBillDate]  
      
 -- replaces dbo.qryArAlpUpdateNextBillDate  
 ;WITH [LastDates] AS (  
  SELECT  
   [rr].[RecBillId],  
   MAX([rr].[EndCycleDate]) AS [MaxEndCycleDate]  
  FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
  WHERE [rr].[RunId] = @RunId  
  GROUP BY [rr].[RecBillId]  
 )  
 UPDATE [rb]  
 SET [rb].[NextBillDate] = DATEADD(d, 1, [l].[MaxEndCycleDate])  
 FROM [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
 INNER JOIN [LastDates] AS [l]  
  ON [rb].[RecBillId] = [l].[RecBillId]  
   
 -- replaces dbo.qryArAlpUpdateServiceStatusExpire  
 UPDATE [rbs]  
 SET [rbs].[Status] = 'Expired'  
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
  ON [rb].[RecBillId] = [rr].[RecBillId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
  ON [rbs].[RecBillId] = [rb].[RecBillId]  
  AND [rbs].[RecBillServId] = [rr].[RecBillServId]  
 LEFT OUTER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
  ON [rbs].[RecBillServId] = [rbsp].[RecBillServId]  
  AND [rbs].[FinalBillDate] + 1 = [rbsp].[StartBillDate]  
 WHERE [rr].[RunId] = @RunId  
  AND [rbsp].[RecBillServPriceId] IS NULL  
  AND [rbs].[FinalBillDate] <= [rb].[NextBillDate]  
   
 -- replaces dbo.qryArAlpUpdateServiceStatusCancelPrice  
 UPDATE [rbsp]  
 SET [ActiveYn] = 0  
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
  ON [rb].[RecBillId] = [rr].[RecBillId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
  ON [rbs].[RecBillId] = [rb].[RecBillId]  
  AND [rbs].[RecBillServId] = [rr].[RecBillServId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
  ON [rbs].[RecBillServId] = [rbsp].[RecBillServId]  
  AND [rr].[RecBillServPriceId] = [rbsp].[RecBillServPriceId]  
 WHERE [rr].[RunId] = @RunId  
  AND [rbsp].[ActiveYn] = 1  
  AND [rbsp].[EndBillDate] < [rb].[NextBillDate]  
    
 -- replaces dbo.qryArAlpUpdateRecBillServPriceActiveYN  
 UPDATE [rbsp]  
 SET [rbsp].[ActiveYn] = 1  
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
  ON [rb].[RecBillId] = [rr].[RecBillId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
  ON [rbs].[RecBillId] = [rb].[RecBillId]  
  AND [rbs].[RecBillServId] = [rr].[RecBillServId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
  ON [rbs].[RecBillServId] = [rbsp].[RecBillServId]  
 WHERE [rr].[RunId] = @RunId  
  AND [rbsp].[ActiveYN] = 0  
  AND [rbsp].[StartBillDate] <= [rb].[NextBillDate]  
  AND ( [rb].[NextBillDate] <= [rbsp].[EndBillDate]  
   OR [rbsp].[EndBillDate] IS NULL)  
   
 UPDATE [rbsp]  
 SET [rbsp].[ActiveYn] = 0  
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
  ON [rb].[RecBillId] = [rr].[RecBillId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
  ON [rbs].[RecBillId] = [rb].[RecBillId]  
  AND [rbs].[RecBillServId] = [rr].[RecBillServId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
  ON [rbs].[RecBillServId] = [rbsp].[RecBillServId]  
 WHERE [rr].[RunId] = @RunId  
  AND [rbsp].[ActiveYn] = 1  
  AND NOT ( [rbsp].[StartBillDate] <= [rb].[NextBillDate]  
    AND ( [rb].[NextBillDate] <= [rbsp].[EndBillDate]   
     OR [rbsp].[EndBillDate] IS NULL)  
    )  
    
 -- replaces dbo.qryArAlpUpdateServiceStatusPChng  
 UPDATE [rbs]  
 SET [rbs].[ActivePrice] = [rbsp].[Price],  
  [rbs].[ActiveRMR] = [rbsp].[Price],  
  [rbs].[FinalBillDate] = [rbsp].[EndBillDate]  
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
  ON [rb].[RecBillId] = [rr].[RecBillId]  
 INNER JOIN [dbo].[ALP_tblArAlpCycle] AS [c]  
  ON [c].[CycleId] = [rb].[BillCycleId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
  ON [rbs].[RecBillId] = [rb].[RecBillId]  
  AND [rbs].[RecBillServId] = [rr].[RecBillServId]  
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
  ON [rbsp].[RecBillServId] = [rbs].[RecBillServId]  
 WHERE [rr].[RunId] = @RunId  
 -- we're now updating nextbilldate and price activeyn before pchng, so can skip the cycle adding.  
  AND [rbsp].[ActiveYn] = 1  
    
 -- replaces dbo.qryArAlpUpdateRecBillActivePrice  
 ;WITH [Summed] AS  
 (  
  SELECT  
   [rb].[RecBillId],  
   SUM([rbs].[ActivePrice]) AS [Price]  
  FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
  INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
   ON [rb].[RecBillId] = [rr].[RecBillId]  
  INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
   ON [rbs].[RecBillId] = [rb].[RecBillId]  
  WHERE [rr].[RunId] = @RunId  
   AND [rbs].[Status] = 'Active'  
  GROUP BY [rb].[RecBillId]  
 )  
 UPDATE [rb]  
 SET [rb].[ActivePrice] = [s].[Price],  
  [rb].[ActiveRMR] = [s].[Price]  
 FROM [dbo].[ALP_tblArAlpSiteRecBill] AS [rb]  
 INNER JOIN [Summed] AS [s]  
  ON [s].[RecBillId] = [rb].[RecBillId]  
    
 ;WITH [MaxTemp] AS (  
  SELECT  
   rbs.RecBillServId,  
   MAX(rr.BillingPeriodEnd) AS [MaxBillingPeriodEnd]  
  FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
  INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [rbsp]  
   ON [rbsp].[RecBillServPriceId] = [rr].[RecBillServPriceId]  
  INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
   ON [rbsp].[RecBillServId] = [rbs].[RecBillServId]  
  WHERE [rr].[RunId] = @RunId  
  GROUP BY [rbs].[RecBillServId]  
 )  
 UPDATE [rbs]  
 SET [rbs].[BilledThruDate] = [m].[MaxBillingPeriodEnd]  
 FROM [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]  
 INNER JOIN [MaxTemp] AS [m]  
  ON [m].[RecBillServId] = [rbs].[RecBillServId]  
   
   
 -- replaces dbo.qryArAlpRecur_UpdateSiteStatuses_sp  
 DECLARE @TouchedSites IntegerListType  
 INSERT INTO @TouchedSites  
 (Id)  
 SELECT DISTINCT  
  [rr].[SiteId]  
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]  
 WHERE [rr].[RunId] = @RunId  
  
 UPDATE [s]  
 SET [s].[Status] = f.[Status]  
 FROM [dbo].[ALP_tblArAlpSite] AS [s]  
 INNER JOIN [dbo].[ALP_ufxArAlpSiteStatuses](@TouchedSites) AS f  
  ON [f].[SiteId] = [s].[SiteId]  
    
 UPDATE [r]  
 SET [r].[StatusCode] = 'C'  
 FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r]  
 WHERE [r].[RunId] = @RunId  
END