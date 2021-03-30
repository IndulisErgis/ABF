
CREATE PROCEDURE [dbo].[ALP_IV_CompletedProjCosts_sp]   
 --Created 11/14/2014 by MAH
 --Modified 01/06/15 by MAH - added CustID
 --modified 01/19/15 by mah - added fields  
(  
  @Where nvarchar(1000)= NULL    
)  
AS      
SET NOCOUNT ON;    
DECLARE @str nvarchar(2000) = NULL      
BEGIN TRY    
SELECT ALP_tblJmSvcTktProject.ProjectId,     
 ALP_tblJmSvcTktProject.[Desc] AS ProjDesc,     
 ALP_tblArAlpPromotion.Promo,    
 ALP_tblArAlpLeadSource.LeadSource,     
 ALP_tblJmMarketCode.MarketCode,    
 ALP_tblJmSvcTktProject.SiteId,    
  Q009.Site,     
  Q009.Address,     
 case [MarketType] when 1 then'Residential' when 2 then 'Commercial' else 'Government' end AS ResComm,    
 Q009.Subdiv,     
 Q009.Block,     
  Min(Q009.OrderDate) AS OrderDate, 
  --mah 01/20/2015:
  PD.CompDate as CompleteDate,
  PD.ClosedDate as CloseDate,   
  --Max(Q009.CompleteDate) AS CompleteDate,     
  --Max(Q009.CloseDate) AS CloseDate,     
  min(Q009.SysType) AS SysType,     
  Sum(cast(Q009.LseYn as int)) AS LseYn,     
 min (Q009.SalesRepID) AS SalesRepID,    
 -- min (Q009.Branch) AS Branch, 
   (Q009.Branch) AS Branch,  
   min(Q009.Division) AS Division,     
   min(Q009.Dept) AS Dept,     
   Sum(CASE WHEN [CsConnectYn] <> 0 THEN 1 ELSE 0 END) AS Connects,     
   --CAST(ROUND(RBS.ActivePrice,2) AS Decimal(10,2))  
   CAST(ROUND(Sum(isnull(Q009.JobPrice,0)),2) AS Decimal(10,2)) AS Price,     
   CAST(ROUND(Sum(isnull(Q009.JobCost,0)),2) AS Decimal(10,2)) AS Cost,     
   CAST(ROUND(Sum(isnull(JobPV,0)),2) AS Decimal(10,2)) AS ProjPV,     
   CAST(ROUND(Sum(isnull(Q009.CommAmt,0)),2) AS Decimal(10,2)) AS Commission,     
   CAST(ROUND(Sum(isnull(Q009.RMRAdded,0)),2) AS Decimal(10,2)) AS RMRAdded,     
   CAST(ROUND(Sum(isnull(Q009.RmrExpense,0)),2) AS Decimal(10,2)) AS RMRExp,    
    CAST(ROUND(Sum(isnull(Q009.EstCostParts,0)),2) AS Decimal(10,2)) AS EstCostParts,     
   CAST(ROUND(Sum(isnull(Q009.EstCostLabor,0)),2) AS Decimal(10,2)) AS EstCostLabor,     
   CAST(ROUND(Sum(isnull(Q009.EstCostMisc,0)),2) AS Decimal(10,2)) AS EstCostMisc,     
   CAST(ROUND(Sum((isnull([EstHrs],0)*isnull([FudgeFactorHrs],0))+isnull([AdjHrs],0)) ,2) AS Decimal(10,2))AS EstHours,     
   CAST(ROUND(Sum(isnull(Q009.PartCost,0)) ,2) AS Decimal(10,2))AS PartCost,     
   CAST(ROUND(Sum(isnull(Q009.OtherCost,0)),2) AS Decimal(10,2)) AS OtherCost,     
   CAST(ROUND(Sum(isnull(Q009.LaborCost,0)),2) AS Decimal(10,2)) AS LaborCost,    
   CAST(ROUND(Sum(isnull(Q009.CommCost,0)),2) AS Decimal(10,2)) AS CommCost,     
   CAST(ROUND(Sum(isnull(Q009.BaseInstPrice,0)) ,2) AS Decimal(10,2))AS BaseInst
   --mah added 01/19/2015: parts cost without OH included:
   ,CAST(ROUND(Sum(isnull(Q009.PartsNoOH,0)) ,2) AS Decimal(10,2))AS PartsNoOH 
   ,CAST(ROUND(Sum(isnull(Q009.PartsOH,0)) ,2) AS Decimal(10,2))AS PartsOH    
   --mah 01/06/15 - added CustId ( first encountered for the project )
   ,MAX(Q009.CustId)  AS CustId 
   --mah 01/19/2015 - added CosAcct
   ,CASE WHEN Q009.LseYN = 0 THEN Q009.GLAcctSaleCOS ELSE Q009.GLAcctLseCOS END 
	AS CosAcct
   INTO #temp  
FROM [ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008]('<ALL>','<ALL>') as Q009  
--mah 01/20/2015:
INNER JOIN  [dbo].[ufxALP_R_AR_Jm_Q004E_ProjCompDate]() as PD ON Q009.ProjectID = PD.ProjectId  
INNER JOIN (ALP_tblJmSvcTktProject    
    LEFT JOIN ALP_tblArAlpPromotion ON ALP_tblJmSvcTktProject.[PromoId] = ALP_tblArAlpPromotion.[PromoId]     
    LEFT JOIN ALP_tblArAlpLeadSource ON ALP_tblJmSvcTktProject.[LeadSourceId] = ALP_tblArAlpLeadSource.[LeadSourceId])     
 ON Q009.[ProjectId] = ALP_tblJmSvcTktProject.[ProjectId]    
 LEFT JOIN ALP_tblJmMarketCode ON ALP_tblJmSvcTktProject.[MarketCodeId] = ALP_tblJmMarketCode.[MarketCodeId]    
WHERE ((Q009.ProjectId IS NOT NULL) AND   (Q009.ProjectId <> '') AND  (Q009.ProjectId <> ' '))  
 AND ((Q009.Status <>  'Cancelled') OR (Q009.Status <> 'Canceled') ) 

GROUP BY    --mah 01/19/2015 - added branch and CosAcct
	Q009.Branch,
    CASE WHEN Q009.LseYN = 0 THEN Q009.GLAcctSaleCOS ELSE Q009.GLAcctLseCOS END,
	ALP_tblJmSvcTktProject.ProjectId,     
 ALP_tblJmSvcTktProject.[Desc],    
 ALP_tblArAlpPromotion.Promo,     
 ALP_tblArAlpLeadSource.LeadSource,     
 ALP_tblJmMarketCode.MarketCode, ALP_tblJmSvcTktProject.SiteId,     
 Q009.Site, Q009.Address, [MarketType],     
 Q009.Subdiv, Q009.Block , PD.CompDate, PD.ClosedDate    
 SET @str =    
'SELECT *,CASE WHEN LseYn > 0 THEN ''Y'' ELSE ''N'' END AS LeaseYN, ' +   
 ' CASE WHEN Connects > 0 THEN ''Y'' ELSE ''N'' END AS ConnectYN, ' +  
 ' CAST(ROUND(Price - Cost ,2) AS Decimal(10,2)) AS Margin, ' +   
 ' CAST(ROUND(CASE WHEN LseYn > 0 THEN CASE WHEN Cost <> 0 THEN Price/Cost ELSE 0 END ELSE 0 END ,2) AS Decimal(10,2)) AS RecovPct, ' +  
 ' CAST(ROUND(CASE WHEN LseYn = 0 THEN CASE WHEN Price <> 0 THEN ((Price - Cost)/Price) ELSE 0 END ELSE 0 END  ,2) AS Decimal(10,2))AS MarginPct '  
  + ' FROM #temp '    
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
  
--columns:  
--ProjectId, ProjDesc,Promo,LeadSource, MarketCode, SiteId, Site,     
--  [Address],ResComm, Subdiv,  Block, OrderDate, CompleteDate,     
-- CloseDate,  SysType,LseYn, SalesRepID, Branch, Division,   Dept,  
--   Connects, Price, Cost,  ProjPV, Commission,  RMRAdded,  RMRExp,    
--   EstCostParts,  EstCostLabor,  EstCostMisc,  EstHours,    
--   PartCost,   OtherCost,  LaborCost, CommCost,   BaseInst,  
--   LeaseYN,ConnectYN,Margin,RecovPct,MarginPct     