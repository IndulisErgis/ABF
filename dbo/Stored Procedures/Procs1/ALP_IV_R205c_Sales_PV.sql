   
CREATE PROCEDURE [dbo].[ALP_IV_R205c_Sales_PV]   
--Created 02/27/15 by MAH   
(    
  @Where nvarchar(1000)= NULL      
)   
AS  
  
SET NOCOUNT ON  
DECLARE @str nvarchar(2000) = NULL        
BEGIN TRY    
SELECT   
 ContrYY+ContrMM AS YYMM,   
 PI.ContrYY,   
 PI.ContrMM,   
 PI.SalesRepID,
 P.InitialOrderDate AS OrderDate,      
 --PI.OrderDate,   
 PI.ProjectID,  
 --mah added 03/02/15  
 P.[Desc] AS ProjDesc,       
 ALP_tblArAlpPromotion.Promo,      
 ALP_tblArAlpLeadSource.LeadSource,       
 ALP_tblJmMarketCode.MarketCode,   
 case MKT.[MarketType] when 1 then'Residential' when 2 then 'Commercial' else 'Government' end AS ResComm,  
 BR.Branch AS Branch,    
 PI.Division,       
   -- end   
 PI.ContractID,   
 PI.CustName,   
 PI.CustID,   
 PI.SiteId,   
 PI.CO,   
 CAST(PI.ContractValue AS Decimal(10,2)) AS ContractValue,   
 CAST(ISNULL(JobPrice,0) AS Decimal(10,2)) AS Price,   
 ISNULL(ContractMths,0) AS MOC,   
 CAST(EstCost AS Decimal(10,2)) AS Cost,   
 CAST(ISNULL(RMRAdded,0) AS Decimal(10,2)) AS RInc,   
 CAST(ISNULL(RMRExpense,0) AS Decimal(10,2)) AS RExp,   
 CAST(ISNULL(CommAmt,0) AS Decimal(10,2)) AS Commission,   
 --MAH 06/30/14: remove separation between Purchased and Leased systems:  
 --CASE PI.LseYn WHEN 0 THEN 'P' WHEN 1 THEN 'L' ELSE '-' END AS LorP,  
 --CASE PI.LseYn WHEN 0 THEN 'P' ELSE 'L' END AS LorP,  
 Pi.LseYn AS LorP,  
 SR.Name,   
 ASite.SiteName,  
 CAST(ROUND(JobPrice-ISNULL(EstCost , 0)   
  + dbo.ufxPresentValue(ISNULL(RMRAdded,0)-ISNULL(RMRExpense,0), .10, ISNULL(ContractMths,0)),2)AS Decimal(10,2)) AS GrossPV ,  
 CAST(ROUND(JobPrice-ISNULL(EstCost , 0) - ISNULL(CommAmt,0)   
  + dbo.ufxPresentValue(ISNULL(RMRAdded,0)-ISNULL(RMRExpense,0), .10, ISNULL(ContractMths,0)),2) AS Decimal(10,2)) AS NetPV  
         
INTO #temp  
FROM ALP_tblArAlpSite AS ASite  
 INNER JOIN ALP_tblArSalesRep_view AS SR   
 INNER JOIN (  
  SELECT *   
  FROM ufxABFRpt205B_ProjInfo(NULL,NULL)) AS PI  
 ON SR.SalesRepID = PI.SalesRepID   
 ON ASite.SiteId=PI.SiteId   
  
--mah added 03/02/15:  
 INNER JOIN ALP_tblJmSvcTktProject  P  ON PI.[ProjectId] = P.[ProjectId]  
 INNER JOIN ALP_tblArAlpBranch AS BR ON ASite.BranchId = BR.BranchId       
    LEFT JOIN ALP_tblArAlpPromotion ON P.[PromoId] = ALP_tblArAlpPromotion.[PromoId]       
    LEFT JOIN ALP_tblArAlpLeadSource ON P.[LeadSourceId] = ALP_tblArAlpLeadSource.[LeadSourceId]     
       
 LEFT JOIN ALP_tblJmMarketCode ON P.[MarketCodeId] = ALP_tblJmMarketCode.[MarketCodeId]  
 LEFT JOIN ALP_tblArAlpMarket AS MKT  ON ASite.MarketId = MKT.MarketId       
 WHERE ((PI.ProjectId IS NOT NULL) AND   (PI.ProjectId <> '') AND  (PI.ProjectId <> ' '))    
  
 ORDER BY   
 PI.ContrYY,   
 PI.ContrMM,   
 PI.SalesRepID,  
 P.InitialOrderDate
 --PI.OrderDate DESC   
  
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
 DROP TABLE #temp      
 EXEC dbo.trav_RaiseError_proc        
END CATCH