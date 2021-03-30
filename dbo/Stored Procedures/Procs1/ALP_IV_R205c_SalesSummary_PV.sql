CREATE PROCEDURE [dbo].[ALP_IV_R205c_SalesSummary_PV]     
--Created 03/25/15 by MAH  
--04/16/15 MAH: modified to add SalesRep info     
(      
  @Where nvarchar(1000)= NULL        
)     
AS    
    
SET NOCOUNT ON      
DECLARE @str nvarchar(2000) = NULL            
BEGIN TRY        
SELECT       
 P.InitialOrderDate as OrderDate,       
 P.ProjectID,      
 P.[Desc] AS ProjDesc,           
 ALP_tblArAlpPromotion.Promo,          
 ALP_tblArAlpLeadSource.LeadSource,           
 JMMKT.MarketCode,       
 case MKT.[MarketType] when 1 then'Residential' when 2 then 'Commercial' else 'Government' end AS ResComm,      
 BR.Branch AS Branch,        
 P.SiteId,       
 SUM(PI.CO) AS CO,       
 CAST(SUM(PI.ContractValue) AS Decimal(10,2)) AS ContractValue,       
 CAST(SUM(ISNULL(JobPrice,0)) AS Decimal(10,2)) AS Price,       
 --ISNULL(ContractMths,0) AS MOC,       
 CAST(SUM(EstCost) AS Decimal(10,2)) AS Cost,       
 CAST(SUM(ISNULL(RMRAdded,0)) AS Decimal(10,2)) AS RInc,       
 CAST(SUM(ISNULL(RMRExpense,0)) AS Decimal(10,2)) AS RExp,       
 CAST(SUM(ISNULL(CommAmt,0)) AS Decimal(10,2)) AS Commission,       
 --MAH 06/30/14: remove separation between Purchased and Leased systems:      
 --CASE PI.LseYn WHEN 0 THEN 'P' WHEN 1 THEN 'L' ELSE '-' END AS LorP,      
 --CASE PI.LseYn WHEN 0 THEN 'P' ELSE 'L' END AS LorP,      
 --Pi.LseYn AS LorP,      
 --SR.Name,       
 ASite.SiteName,      
 GrossPV  = CAST(SUM(GrossPV)AS Decimal(10,2)),      
 NetPV = CAST(SUM(GrossPV) - SUM(ISNULL(CommAmt,0)) AS Decimal(10,2)),  
 MIN(FirstTicket) AS FirstTicket,   
 'NONE' AS Rep, 'NONE' AS OtherRep   
INTO #temp      
FROM ufx_IV_R205c_SalesSummary_PV(NULL,NULL) PI    
 INNER JOIN ALP_tblJmSvcTktProject  P  ON PI.[ProjectId] = P.ProjectId      
 INNER JOIN ALP_tblArAlpSite ASite   ON PI.SiteId = ASite.SiteId   
 INNER JOIN ALP_tblArAlpBranch  BR ON ASite.BranchId = BR.BranchId           
    LEFT JOIN ALP_tblArAlpPromotion ON P.[PromoId] = ALP_tblArAlpPromotion.PromoId           
    LEFT JOIN ALP_tblArAlpLeadSource ON P.[LeadSourceId] = ALP_tblArAlpLeadSource.[LeadSourceId]         
 LEFT JOIN ALP_tblJmMarketCode JMMKT ON P.[MarketCodeId] = JMMKT.[MarketCodeId]      
 LEFT JOIN ALP_tblArAlpMarket  MKT  ON ASite.MarketId = MKT.MarketId           
 WHERE ((PI.ProjectId IS NOT NULL) AND   (PI.ProjectId <> '') AND  (PI.ProjectId <> ' '))        
---      
--added    
 GROUP BY       
 P.ProjectID,P.InitialOrderDate,       
 P.[Desc],           
 ALP_tblArAlpPromotion.Promo,          
 ALP_tblArAlpLeadSource.LeadSource,           
 JMMKT.MarketCode,       
 case MKT.[MarketType] when 1 then'Residential' when 2 then 'Commercial' else 'Government' end,      
 BR.Branch, P.SiteId,ASite.SiteName  
 --GROUP BY     
 --P.ProjectID,P.InitialOrderDate,     
 --P.[Desc],         
 --ALP_tblArAlpPromotion.Promo,        
 --ALP_tblArAlpLeadSource.LeadSource,         
 --ALP_tblJmMarketCode.MarketCode,     
 --case MKT.[MarketType] when 1 then'Residential' when 2 then 'Commercial' else 'Government' end,    
 --BR.Branch,    
 --P.SiteId,SiteName     
 ORDER BY     
  P.InitialOrderDate, P.ProjectID,     
  P.[Desc],         
  ALP_tblArAlpPromotion.Promo,        
  ALP_tblArAlpLeadSource.LeadSource,         
  JMMKT.MarketCode,     
  case MKT.[MarketType] when 1 then'Residential' when 2 then 'Commercial' else 'Government' end,    
  BR.Branch,    
  P.SiteId,SiteName   
      
UPDATE #temp SET #temp.Rep = T.SalesRepID --.SalesRepId   
FROM #temp INNER JOIN  ALP_tblJmSvcTkt T ON #temp.FirstTicket = T.TicketId   
  
UPDATE #temp SET #temp.OtherRep = T.SalesRepID   
FROM #temp INNER JOIN  ALP_tblJmSvcTkt T ON #temp.ProjectId = T.ProjectId  
WHERE #temp.FirstTicket <> T.TicketId and #temp.Rep <> T.SalesRepId   
    
    
 SET @str =        
'SELECT * FROM #temp '         
  + CASE WHEN @Where IS NULL THEN ' '        
 WHEN @Where = '' THEN ' '        
 WHEN @Where = ' ' THEN ' '        
 ELSE ' WHERE ' + @Where        
 END  + ' '       
      
 execute (@str)       
 DROP TABLE #temp      
 END TRY          
BEGIN CATCH        
 DROP TABLE #temp         EXEC dbo.trav_RaiseError_proc          
END CATCH