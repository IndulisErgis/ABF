CREATE PROCEDURE dbo.ALP_lkpJmSvcTktProjectJobs_Count_sp  
/*       */  
/* History: created 12/16/05 M.Hueser   */  
--EFI# 1645 MAH 01/31/06 - added PartsCostPlusOh ( Tot Parts Cost plus overhead ), and ContractAmt  
--11/20/15 mah  - modified to inclde 0 amounts for canceled jobs. 
--              ( must still list the job, but with no impact of the project summary totals )  
 (  
 @ProjectID varchar(10) = null,  
 @TicketID int = null  
 )  
AS  
SELECT  COUNT(T.ProjectId) AS CountOfProjectId,   
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(ST.TotalPts,0) END) AS SumOfPoints,   
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(ST.PartsPrice,0) + isnull(ST.LabPriceTotal,0) END) 
	+ SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(T.OtherPrice,0) END) AS ProjectPrice,  
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(ST.RMRAdded,0) END) AS SumOfRMR,   
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(T.EstHrs,0) END)AS SumOfEhrs,  
 T.ProjectId,   
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(ST.EstCostParts,0) END) AS SumOfEstCostParts,   
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(ST.EstCostLabor,0) END) AS SumOfEstCostLabor,   
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(ST.EstCostMisc,0) END) AS SumOfEstCostMisc,  
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(T.PartsCost,0) END) AS SumOfPartsCost,  
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(T.OtherCost,0) END) AS SumOfOtherCost,  
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(T.OtherCostLabor,0) END) AS SumOfOtherLabor,  
--EFI# 1645 MAH 01/31/06, added next 3 fields:  
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE (isnull(T.PartsCost,0) * (1 + ST.PartsOhPct )) END) AS SumOfPartsCostPlusOH,  
 isnull(dbo.ALP_ufxJmProject_GetContractAmt(@ProjectId),0) AS SumOfContractValue,  
 SUM(CASE WHEN ST.Status = 'Canceled' THEN 0 ELSE isnull(ST.EstHrs_FromQM,0) END) AS SumOfEstHrs_FromQM  
FROM ALP_tblJmSvcTktProject P   
      LEFT JOIN ALP_tblJmSvcTkt ST ON P.ProjectID = ST.ProjectID  
	  LEFT JOIN dbo.ALP_ufxJmSvcTkt_PriceCostTotals(@ProjectID,@TicketID)  T   
  ON ST.TicketID = T.TicketID  
WHERE P.ProjectID = @ProjectID  
 AND ST.ProjectID = @ProjectID
GROUP BY T.ProjectId