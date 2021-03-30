
CREATE FUNCTION [dbo].[ufxALP_IV_ServiceContracts_RMR_Q8]   
(
@pAsOfDate date = GetDate
)  
RETURNS TABLE   
AS  
RETURN   
(  
  --DECLARE @SelectionEndDate
  --SET @SelectionEndDate = CASE WHEN @pAsOfDate IS NULL THEN GetDate() ELSE @pAsOfDate END 

  SELECT RB.SiteId as Q8SiteId, rbs.SysId as Q8SysId, rbs.RecBillServId,  rbs.ServiceID, rbs.[Desc] as ServiceDescription,
  RBS.ServiceStartDate, P.StartBillDate, P.EndBillDate, RBS.BilledThruDate, RBS.FinalBillDate,  [rbs].[CanServEndDate],
  AsOfDate = @pAsOfDate,  
  P.Price, 
  MonthsAtThisPrice = CASE WHEN ([rbs].[CanServEndDate] IS NOT NULL AND  [rbs].[CanServEndDate] < @pAsOfDate ) THEN 
    CASE WHEN (P.EndBillDate IS NULL OR P.EndBillDate > [rbs].[CanServEndDate] )
		THEN DATEDIFF(MM,p.StartBillDate , [rbs].[CanServEndDate])
		ELSE DATEDIFF(MM,p.StartBillDate, p.EndBillDate) END 
   	ELSE
	 CASE WHEN (P.EndBillDate IS NULL OR P.EndBillDate > @pAsOfDate )
		THEN DATEDIFF(MM,p.StartBillDate , @pAsOfDate)
		ELSE DATEDIFF(MM,p.StartBillDate, p.EndBillDate) END   	
	END,
 	rb.ItemId as Q8ItemId
  FROM [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]      
  INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS rb      
   ON [rb].[RecBillId] = [rbs].[RecBillId]      
   INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS P    
   ON rbs.RecBillServID = p.RecBillServID     
  WHERE
   ([rbs].ServiceType = 5 OR [rbs].ServiceType = 6 )     
   AND  [rbs].[ServiceStartDate] IS NOT NULL      
   AND ([rbs].[ServiceStartDate] <= @pAsOfDate ) -- @AsOfDate )     
   AND P.StartBillDate <= @pAsOfDate --@AsOfDate   
   AND ((p.EndBillDate is NULL) OR (p.EndBillDate >= @pAsOfDate))  --@AsOfDate ))
  -- AND (([rbs].[CanServEndDate] is NULL) OR ( [rbs].[CanServEndDate] >=  '07/07/2017'))  -- @AsOfDate ))

   )

--SELECT RB.SiteId,   
--  RB.ItemId AS RecGroup,       
--  RBS.ServiceID,        
--  RBS.ServiceStartDate AS ServiceStart, RBS.Status,  RB.CustId,      
--  SS.SysId, ST.SysType,       
--  SS.AlarmId,RB.NextBillDate AS NextBill, CY.Cycle,       
--  CAST(ROUND(RBS.ActivePrice,2) AS Decimal(10,2)) as UnitPrice,       
--  --ExtPrice not correct - check CycleID usage for MTH      
--  --RBS.ActivePrice * ActiveCycleId AS ExtPrice,      
--  AI.AlpMFG AS SvcVendor       
--  --mah 07/06/15:      
--  ,CAST(ROUND(Isnull(RBS.ActiveRMR,0),2) AS Decimal(10,2)) as RMR      
--  ,CAST(ROUND(ISNULL(RBS.ActiveCost,0),2) AS Decimal(10,2)) as RMRCost      
--  ,CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2)) as RMRCostStd      
--  ,CAST(ROUND(ISNULL(IL.CostAvg,0),2) AS Decimal(10,2)) as RMRCostAvg      
--  ,CAST(ROUND(ISNULL(RBS.ActivePrice,0),2)AS Decimal(10,2))  - CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2)) as RMRNet  
      
--FROM ((dbo.ALP_tblArAlpSite S       
-- INNER JOIN (dbo.ALP_tblArAlpSiteRecBill RB                  
-- INNER JOIN dbo.ALP_tblArAlpCycle CY ON RB.BillCycleId = CY.CycleId)       
-- ON S.SiteId = RB.SiteId)      
-- INNER JOIN (dbo.ALP_tblArAlpSysType ST       
-- INNER JOIN (dbo.ALP_tblArAlpSiteRecBillServ RBS       
-- INNER JOIN dbo.ALP_tblArAlpSiteSys SS ON RBS.SysId = SS.SysId)       
--  ON ST.SysTypeId = SS.SysTypeId)       
--  ON RB.RecBillId = RBS.RecBillId)     
-- LEFT OUTER JOIN dbo.ALP_tblInItem AI ON  AI.AlpItemId = RBS.ServiceID      
-- --mah 07/06/15:      
-- LEFT OUTER JOIN dbo.tblInItemLoc IL ON IL.ItemId = RBS.ServiceID AND IL.LocID = RBS.LocId  
-- WHERE (RBS.ServiceType = 5 OR RBS.ServiceType = 6)