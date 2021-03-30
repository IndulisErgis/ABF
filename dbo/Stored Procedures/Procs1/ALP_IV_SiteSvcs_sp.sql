
     
CREATE PROCEDURE [dbo].[ALP_IV_SiteSvcs_sp]       
--Created 11/11/2014 by MAH      
(      
  @Where nvarchar(1000)= NULL        
  )      
AS          
SET NOCOUNT ON;        
DECLARE @str nvarchar(2000) = NULL          
BEGIN TRY        
      
SELECT C.CustId, CustName = CASE WHEN  AC.AlpFirstName IS NULL THEN C.CustName      
    ELSE C.CustName + (',' + AC.AlpFirstName)  END,      
 C.Addr1, C.Addr2, C.City,       
 C.Region, C.PostalCode, C.Phone, RB.SiteId,       
 SiteName = CASE WHEN S.AlpFirstName IS NULL THEN S.SiteName       
  ELSE S.SiteName + (', '+S.AlpFirstName) END,       
  S.Addr1 AS SiteAddr1, S.Addr2 AS SiteAddr2,       
  S.City AS SiteCity, S.Region AS SiteRegion,       
  S.PostalCode AS SitePostalCode, S.Phone AS SitePhone,       
  RB.ItemId AS RecGroup, RB.AcctCode AS AcctCode,       
  RBS.ServiceID,RBS.AcctCode AS SvcAcct,        
  RBS.ServiceStartDate AS ServiceStart, RBS.Status,  ST.SysType,       
  SS.AlarmId,RB.NextBillDate AS NextBill, CY.Cycle,       
  CAST(ROUND(RBS.ActivePrice,2) AS Decimal(10,2)) as UnitPrice,       
  --ExtPrice not correct - check CycleID usage for MTH      
  --RBS.ActivePrice * ActiveCycleId AS ExtPrice,      
  AI.AlpMFG AS SvcVendor, B.Branch, S.DistCode,      
  ALP_tblJmMarketCode.MarketCode AS Market, CASE WHEN AC.AlpCommYn <> 0 THEN 'Comm' ELSE 'Res' END AS Type      
  --mah 07/06/15:      
  ,CAST(ROUND(Isnull(RBS.ActiveRMR,0),2) AS Decimal(10,2)) as RMR      
  ,CAST(ROUND(ISNULL(RBS.ActiveCost,0),2) AS Decimal(10,2)) as RMRCost      
  ,CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2)) as RMRCostStd      
  ,CAST(ROUND(ISNULL(IL.CostAvg,0),2) AS Decimal(10,2)) as RMRCostAvg      
  ,CAST(ROUND(ISNULL(RBS.ActivePrice,0),2)AS Decimal(10,2))  - CAST(ROUND(ISNULL(IL.CostStd,0),2) AS Decimal(10,2)) as RMRNet  
  --mah 103115: - added email addresses for ADT needs
  ,C.Email
  ,S.SalesRepId1 AS Rep
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
 INNER JOIN dbo.ALP_tblArAlpBranch B ON S.BranchId = B.BranchId       
 LEFT OUTER JOIN dbo.ALP_tblInItem AI ON  AI.AlpItemId = RBS.ServiceID      
 --mah 07/06/15:      
 LEFT OUTER JOIN dbo.tblInItemLoc IL ON IL.ItemId = RBS.ServiceID AND IL.LocID = RBS.LocId      
 LEFT OUTER JOIN dbo.ALP_tblJmMarketCode ON ALP_tblJmMarketCode.MarketCodeId = S.MarketId  
 ----mah 103115: added email addresses for ADT needs
 --LEFT OUTER JOIN dbo.tblSmDocumentDelivery DD ON DD.ContactID = RB.CustId   
 --WHERE (DD.FormId = 'AR INVOICE') OR (DD.FormId IS NULL)      
 SET @str =        
'SELECT CustId, CustName ,      
 Addr1, Addr2, City,       
 Region, PostalCode,Phone, SiteId,       
 SiteName,       
  SiteAddr1, SiteAddr2,       
  SiteCity, SiteRegion,       
  SitePostalCode, SitePhone,       
  RecGroup, AcctCode,       
  ServiceID,SvcAcct,        
  ServiceStart, Status,  SysType,       
  AlarmId,NextBill, Cycle, UnitPrice,       
  SvcVendor, Branch ,DistCode, Market, Type,      
  RMR, RMRCost, RMRCostStd, RMRCostAvg,RMRNet, Email, Rep      
FROM #temp '  + CASE WHEN @Where IS NULL THEN ' '        
  WHEN @Where = '' THEN ' '        
  WHEN @Where = ' ' THEN ' '        
  ELSE ' WHERE ' + @Where        
  END  + ' '       
      
 execute (@str)       
 DROP TABLE #temp      
 END TRY          
BEGIN CATCH        
 DROP TABLE #temp        
 EXEC dbo.trav_RaiseError_proc          
END CATCH