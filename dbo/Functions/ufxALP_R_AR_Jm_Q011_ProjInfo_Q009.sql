
CREATE Function  [dbo].[ufxALP_R_AR_Jm_Q011_ProjInfo_Q009](  
--@Branch varchar(255)  
) 
--MAH 02/25/15 - modified to turn Y/N connect info into count of connects by project  
RETURNS TABLE   
AS  
RETURN   
(  
  
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
  Min(Q009.OrderDate) AS ProjOrderDate,   
  Max(Q009.CompleteDate) AS ProjCmpltdDate,   
  Max(Q009.CloseDate) AS ProjCloseDate,   
  min(Q009.SysType) AS FirstOfSysType,   
  Sum(cast(Q009.LseYn as int)) AS SumOfLseYn,   
 min (Q009.SalesRepID) AS FirstOfSalesRepID,  
  min (Q009.Branch) AS FirstOfBranch,   
   min(Q009.Division) AS FirstOfDivision,   
   min(Q009.Dept) AS FirstOfDept, 
   -- MAH 02/25/15:  
   Sum(CASE WHEN [CsConnectYn] <> 0 THEN 1 ELSE 0 END) AS Connects, 
   --Sum(([CsConnectYn]*-1)) AS Connects, 
   Sum(isnull(Q009.JobPrice,0)) AS ProjPrice,   
   Sum(isnull(Q009.JobCost,0)) AS ProjCost,   
   Sum(isnull(JobPV,0)) AS ProjPv,   
   Sum(isnull(Q009.CommAmt,0)) AS ProjComm,   
   Sum(isnull(Q009.RMRAdded,0)) AS ProjRmr,   
   Sum(isnull(Q009.RmrExpense,0)) AS ProjRmrExp,  
    Sum(isnull(Q009.EstCostParts,0)) AS SumOfEstCostParts,   
   Sum(isnull(Q009.EstCostLabor,0)) AS SumOfEstCostLabor,   
   Sum(isnull(Q009.EstCostMisc,0)) AS SumOfEstCostMisc,   
   Sum((isnull([EstHrs],0)*isnull([FudgeFactorHrs],0))+isnull([AdjHrs],0)) AS EstHours,   
   Sum(isnull(Q009.PartCost,0)) AS ProjPartCost,   
   Sum(isnull(Q009.OtherCost,0)) AS ProjOtherCost,   
   Sum(isnull(Q009.LaborCost,0)) AS ProjLaborCost,  
   Sum(isnull(Q009.CommCost,0)) AS ProjCommCost,   
   Sum(isnull(Q009.BaseInstPrice,0)) AS ProjBaseInst  
FROM [ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008]('<ALL>','<ALL>') as Q009  
INNER JOIN (ALP_tblJmSvcTktProject  
    LEFT JOIN ALP_tblArAlpPromotion ON ALP_tblJmSvcTktProject.[PromoId] = ALP_tblArAlpPromotion.[PromoId]   
    LEFT JOIN ALP_tblArAlpLeadSource ON ALP_tblJmSvcTktProject.[LeadSourceId] = ALP_tblArAlpLeadSource.[LeadSourceId])   
   ON Q009.[ProjectId] = ALP_tblJmSvcTktProject.[ProjectId]  
 LEFT JOIN ALP_tblJmMarketCode ON ALP_tblJmSvcTktProject.[MarketCodeId] = ALP_tblJmMarketCode.[MarketCodeId]  
GROUP BY ALP_tblJmSvcTktProject.ProjectId,   
ALP_tblJmSvcTktProject.[Desc],  
 ALP_tblArAlpPromotion.Promo,   
 ALP_tblArAlpLeadSource.LeadSource,   
 ALP_tblJmMarketCode.MarketCode, ALP_tblJmSvcTktProject.SiteId,   
 Q009.Site,   
 Q009.Address,   
 [MarketType],   
 Q009.Subdiv, Q009.Block  
)