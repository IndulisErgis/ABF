CREATE PROCEDURE dbo.ALP_qryJmProjectJobsForSys_sp             
--Created: 10/28/04 MAH for EFI# 1532            
--EFI# 1557 MAH 12/09/04 - added Billed amount per Job            
--EFI# 1645 MAH 02/08/06 - added EstimatedHours_FromQM        
--EFI# 712  BranchId added by ravi on 3rd august 2018       
 (            
 @ProjectID int,            
 @SysID int = NULL            
 )            
As            
SET NOCOUNT ON            
SELECT  T.ProjectId, T.SysId, T.TicketId AS [Job No],             
    CASE WHEN TotalPts IS NULL             
  THEN 0 ELSE TotalPts END AS Points,            
   --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE     
   CASE WHEN ALP_stpJmSvcTktProjectJobsEstHrs.EstHrs IS NULL             
   THEN 0 ELSE ALP_stpJmSvcTktProjectJobsEstHrs.EstHrs END     
  END AS Ehrs,            
    CASE WHEN CsConnectYn = 1 THEN 'Y' ELSE '' END AS CS,            
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE T.RMRAdded END AS RMR,            
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE dbo.ALP_stpJm0021SvcJobPrice.JobPrice END AS JobPrice,            
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE T.BaseInstPrice END AS BaseInstPrice,            
    dbo.ALP_tblArAlpSiteSys.SysDesc AS [System],            
    ALP_tblJmWorkCode.WorkCode,            
    T.CustId AS [Bill To],            
    dbo.ALP_tblArAlpDivision.Division,            
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0     
  ELSE isNull(EstCostParts,0) + isNull(EstCostMisc,0) + isnull(EstCostLabor,0) END AS EstCostTotal,                 
    T.Status,            
    CASE WHEN ALP_stpJmSvcTktProjectJobsHrs.ActualHrs IS NULL             
  THEN 0 ELSE ALP_stpJmSvcTktProjectJobsHrs.ActualHrs END AS Hrs,             
    T.SalesRepId AS Rep,             
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE T.CommAmt END AS CommAmt,            
    T.OrderDate AS Ordered,              
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE     
   CASE WHEN EstCostParts IS NULL             
   THEN 0 ELSE EstCostParts END     
  END AS EstCostParts,             
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE     
   CASE WHEN EstCostMisc IS NULL             
   THEN 0 ELSE EstCostMisc END     
  END AS EstCostMisc,             
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE     
   CASE WHEN EstCostLabor IS NULL             
   THEN 0 ELSE EstCostLabor END     
  END AS EstCostLabor,             
    TotalBilled = dbo.ALP_ufxJmSvcTktTotalBilled(T.TicketId),            
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE T.RMRExpense END AS RMRExpense,T.ContractMths,T.DiscRatePct,            
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE T.EstHrs_FromQM END AS EstHrs_FromQM,            
    --mah 11/20/15 - do not include value for canceled jobs    
    CASE WHEN T.Status = 'canceled' THEN 0 ELSE T.TotalPts END AS EstPts_FromQM            
    --PriceId added by NSK on 05 Jan 2015          
    ,T.PriceId          
    --Contract Id added by NSK on 05 Feb 2015        
    , T.ContractId        
     --Site Id added by NSK on 20 Apr 2015        
    ,T.SiteId     
     --ResolComments added by ravi on 6th june 2018   
     ,T.ResolComments   
        --WorkCodeId added by ravi on 6th june 2018   
     ,T.WorkCodeId   
      --BranchId added by ravi on 3rd august 2018   
     ,T.BranchId 
FROM dbo.ALP_tblJmWorkCode INNER JOIN            
    dbo.ALP_tblArAlpDivision RIGHT OUTER JOIN            
    dbo.ALP_tblJmSvcTktProject INNER JOIN            
    dbo.ALP_tblJmSvcTkt T ON             
    dbo.ALP_tblJmSvcTktProject.ProjectId = T.ProjectId LEFT            
     OUTER JOIN            
    dbo.ALP_tblArAlpSiteSys ON             
    T.SysId = dbo.ALP_tblArAlpSiteSys.SysId ON             
    dbo.ALP_tblArAlpDivision.DivisionId = T.DivId LEFT OUTER            
     JOIN            
    dbo.ALP_stpJm0021SvcJobPrice ON             
    T.TicketId = dbo.ALP_stpJm0021SvcJobPrice.TicketId LEFT     
     OUTER JOIN            
    dbo.ALP_stpJmSvcTktProjectJobsEstHrs ON             
    T.TicketId = dbo.ALP_stpJmSvcTktProjectJobsEstHrs.TicketId            
     LEFT OUTER JOIN            
    dbo.ALP_stpJmSvcTktProjectJobsHrs ON             
    T.TicketId = dbo.ALP_stpJmSvcTktProjectJobsHrs.TicketId            
     ON             
    dbo.ALP_tblJmWorkCode.WorkCodeId = T.WorkCodeId            
WHERE dbo.ALP_tblJmSvcTktProject.SvcTktProjectId = @ProjectID            
 AND            
 (( @SysID is null ) OR ( (@SysID is not null ) AND (T.SysId = @SysID)))            
ORDER BY T.ProjectId, T.SysID, T.TicketID