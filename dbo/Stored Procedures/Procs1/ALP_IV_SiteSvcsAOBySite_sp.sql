
  
CREATE PROCEDURE [dbo].[ALP_IV_SiteSvcsAOBySite_sp]       
--Created 12/29/16 by MAH      
(      
  @Where nvarchar(1000)= NULL        
  )      
AS          
SET NOCOUNT ON;        
DECLARE @str nvarchar(2000) = NULL          
BEGIN TRY        
CREATE TABLE tmpSites
(SiteID int NULL, RMR Decimal(10,2) NULL, RMRCost Decimal(10,2) NULL, RMRNet Decimal (10,2) NULL,
SiteName varchar(120) NULL, SiteAddr1 varchar(40) NULL, SiteAddr2 varchar(60) NULL,SiteCity varchar(30) NULL, 
SiteRegion varchar(50) NULL, SitePostalCode varchar(10) NULL, SitePhone varchar(15) NULL,       
Branch varchar(100) NULL,DistCode varchar(6) NULL, Market varchar(10) NULL, Type varchar(4) NULL)    
SELECT RB.SiteId,       
  SiteName = CASE WHEN S.AlpFirstName IS NULL THEN S.SiteName       
    ELSE S.SiteName + (', '+S.AlpFirstName) END 
  ,C.CustId, RB.ItemId AS RecGroup, RBS.ServiceID  
  ,CAST(ROUND(RBSP.Price,2) AS Decimal(10,2)) as RMR
  ,RBSP.StartBillDate AS StartDate
  --,RBSP.EndBillDate AS EndDate   ISNULL(RBS.CanServEndDate,RBS.FinalBillDate)AS ServiceEnd
  ,--CASE WHEN RBSP.EndBillDate IS NULL THEN CAST('12/31/2099' AS DATE) 
	--	ELSE 
	CASE WHEN (ISNULL(RBS.CanServEndDate,RBS.FinalBillDate) IS  NULL)
		THEN CASE WHEN RBSP.EndBillDate IS NULL THEN CAST('12/31/2099' AS DATE) ELSE RBSP.EndBillDate END
		ELSE CASE WHEN RBSP.EndBillDate IS NULL THEN ISNULL(RBS.CanServEndDate,RBS.FinalBillDate) 
			ELSE CASE WHEN (ISNULL(RBS.CanServEndDate,RBS.FinalBillDate) > RBSP.EndBillDate) 
				THEN RBSP.EndBillDate 
				ELSE ISNULL(RBS.CanServEndDate,RBS.FinalBillDate) END
	END END AS EndDate
 -- ,CAST(ROUND(ISNULL(RBS.ActiveCost,0),2) AS Decimal(10,2)) as RMRCost
 ,CASE WHEN ISNULL(RBS.ActiveCost,0) = 0 THEN CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2))
		ELSE  CAST(ROUND(ISNULL(RBS.ActiveCost,0),2) AS Decimal(10,2)) END as RMRCost    
  ,CAST(ROUND(ISNULL(RBSP.Price,0),2)AS Decimal(10,2))  
    - CASE WHEN ISNULL(RBS.ActiveCost,0) = 0 THEN CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2))
		ELSE  CAST(ROUND(ISNULL(RBS.ActiveCost,0),2) AS Decimal(10,2))
    END as RMRNet  
  ,RBS.ServiceStartDate AS ServiceStart, ISNULL(RBS.CanServEndDate,RBS.FinalBillDate)AS ServiceEnd, RBS.Status as CurrentStatus
  ,CASE WHEN (RBS.Status = 'Active' OR RBS.Status = 'New') THEN  CAST(ROUND(Isnull(RBS.ActiveRMR,0),2) AS Decimal(10,2)) 
	ELSE 0.00 END as CurrentRMR   
  ,CAST(ROUND(Isnull(RBS.ActiveRMR,0),2) AS Decimal(10,2)) as LatestRMR     
  --,CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2)) as RMRCostStd      
  --,CAST(ROUND(ISNULL(IL.CostAvg,0),2) AS Decimal(10,2)) as RMRCostAvg      
  --,CAST(ROUND(ISNULL(RBS.ActivePrice,0),2)AS Decimal(10,2))  - CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2)) as RMRNet  
  ,CustName = CASE WHEN  AC.AlpFirstName IS NULL THEN C.CustName      
    ELSE C.CustName + (',' + AC.AlpFirstName)  END,      
  C.Addr1, C.Addr2, C.City,       
  C.Region, C.PostalCode, C.Phone,       
  S.Addr1 AS SiteAddr1, S.Addr2 AS SiteAddr2,       
  S.City AS SiteCity, S.Region AS SiteRegion,       
  S.PostalCode AS SitePostalCode, S.Phone AS SitePhone,       
  RB.AcctCode AS AcctCode, RBS.AcctCode AS SvcAcct, ST.SysType,       
  SS.AlarmId,RB.NextBillDate AS NextBill, CY.Cycle,       
  CAST(ROUND(RBS.ActivePrice,2) AS Decimal(10,2)) as ServUnitPrice,       
  --ExtPrice not correct - check CycleID usage for MTH      
  --RBS.ActivePrice * ActiveCycleId AS ExtPrice,      
  AI.AlpMFG AS SvcVendor, B.Branch, S.DistCode,      
  ALP_tblArAlpMarket.Market AS Market, CASE WHEN AC.AlpCommYn <> 0 THEN 'Comm' ELSE 'Res' END AS Type,  C.Email    
  INTO #temp      
FROM ((dbo.ALP_tblArAlpSite S       
 INNER JOIN ((dbo.ALP_tblArAlpSiteRecBill RB       
			INNER JOIN dbo.tblArCust C ON RB.CustId = C.CustId      
			INNER JOIN dbo.ALP_tblArCust AC ON RB.CustId = AC.AlpCustId)      
			INNER JOIN dbo.ALP_tblArAlpCycle CY ON RB.BillCycleId = CY.CycleId)       
		ON S.SiteId = RB.SiteId)      
 INNER JOIN (dbo.ALP_tblArAlpSysType ST       
			INNER JOIN (dbo.ALP_tblArAlpSiteRecBillServ RBS       
			INNER JOIN dbo.ALP_tblArAlpSiteSys SS ON RBS.SysId = SS.SysId)       
			ON ST.SysTypeId = SS.SysTypeId)       
		ON RB.RecBillId = RBS.RecBillId)
 INNER JOIN  dbo.ALP_tblArAlpSiteRecBillServPrice RBSP ON RBS.RecBillServid = RBSP.RecBillServId      
 INNER JOIN dbo.ALP_tblArAlpBranch B ON S.BranchId = B.BranchId  
 LEFT OUTER JOIN dbo.ALP_tblInItem AI ON  AI.AlpItemId = RBS.ServiceID      
 LEFT OUTER JOIN dbo.tblInItemLoc IL ON IL.ItemId = RBS.ServiceID AND IL.LocID = RBS.LocId      
 LEFT OUTER JOIN dbo.ALP_tblArAlpMarket ON ALP_tblArAlpMarket.MarketId = S.MarketId  
       
 SET @str = 'INSERT INTO tmpSites (SiteId, RMR, RMRCost, RMRNet, SiteName,SiteAddr1, SiteAddr2,SiteCity, SiteRegion, SitePostalCode, SitePhone,       
Branch ,DistCode, Market, Type) SELECT SiteId, SUM(RMR), SUM(RMRCost), SUM(RMRNet),SiteName,
SiteAddr1, SiteAddr2,SiteCity, SiteRegion, SitePostalCode, SitePhone,Branch ,DistCode, Market, Type FROM #temp '
   + CASE WHEN @Where IS NULL THEN ' '        
  WHEN @Where = '' THEN ' '        
  WHEN @Where = ' ' THEN ' '        
  ELSE ' WHERE ' + @Where        
  END  + ' GROUP BY  SiteId, SiteName, SiteAddr1, SiteAddr2,SiteCity, SiteRegion, SitePostalCode, SitePhone,Branch ,DistCode, Market, Type '        
execute (@str)  
--SELECT SiteId, SiteName, SUM( RMR), SUM(RMRCost), SUM(RMRNet),
--  SiteAddr1, SiteAddr2,SiteCity, SiteRegion, SitePostalCode, SitePhone,       
--  Branch ,DistCode, Market, Type 
--FROM #temp2 
--GROUP BY SiteId, SiteName, 
--  SiteAddr1, SiteAddr2,SiteCity, SiteRegion, SitePostalCode, SitePhone ,Branch ,DistCode, Market, Type      
SELECT SiteId, RMR, RMRCost, RMRNet, SiteName,SiteAddr1, SiteAddr2,SiteCity, SiteRegion, SitePostalCode, SitePhone,       
Branch ,DistCode, Market, Type
FROM tmpSites ORDER BY SiteId
--GROUP BY SiteId, SiteName, 
--  SiteAddr1, SiteAddr2,SiteCity, SiteRegion, SitePostalCode, SitePhone ,Branch ,DistCode, Market, Type        
 DROP TABLE #temp 
 DROP TABLE tmpSites     
 END TRY          
BEGIN CATCH        
 DROP TABLE #temp
 DROP TABLE tmpSites        
 EXEC dbo.trav_RaiseError_proc          
END CATCH