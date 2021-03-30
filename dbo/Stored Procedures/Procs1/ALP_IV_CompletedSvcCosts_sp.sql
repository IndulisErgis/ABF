 
CREATE PROCEDURE [dbo].[ALP_IV_CompletedSvcCosts_sp]   
 --Created 01/06/15 by MAH  - based on data needed for old reports R170C and R175
(  
  @Where nvarchar(1000)= NULL    
)  
AS      
SET NOCOUNT ON;    
DECLARE @str nvarchar(2000) = NULL      
BEGIN TRY    
  
SELECT Q009.TicketId,  
 Q009.SiteId,    
 Q009.Site,     
 Q009.Address,     
 CASE WHEN [MarketType] = 1 then'Residential'   
  when [MarketType] = 2 then 'Commercial'   
  else 'Government' end AS ResComm, 
 Q009.CustId,   
 Q009.Subdiv,     
 Q009.Block,     
 Q009.OrderDate ,     
 Q009.CompleteDate ,     
 Q009.CloseDate ,     
 Q009.SysType,   
 Q009.WorkCode,  
 Q009.WorkDesc,
 Q009.Tech,   
 CASE WHEN Q009.LseYn <> 0 THEN 'Y' ELSE 'N' END AS LeaseYN,     
 Q009.SalesRepID AS SalesRepID,    
 Q009.Branch AS Branch,     
 Q009.Division AS Division,     
 Q009.Dept AS Dept,     
 CASE WHEN [CsConnectYn] <> 0 THEN 'Y' ELSE 'N' END AS ConnectYN,     
 Round(CASE WHEN Q009.JobPrice IS NULL THEN 0 ELSE Q009.JobPrice END,2) AS Price,     
 Round(CASE WHEN Q009.JobCost IS NULL THEN 0 ELSE Q009.JobCost END,2) AS JobCost,     
 Round(CASE WHEN JobPV IS NULL THEN 0 ELSE JobPV END,2) AS JobPV,     
 CASE WHEN Q009.CommAmt IS NULL THEN 0 ELSE Q009.CommAmt END AS Comm,     
 CASE WHEN Q009.RMRAdded IS NULL THEN 0 ELSE Q009.RMRAdded END AS RMRAdded,     
 CASE WHEN Q009.RmrExpense IS NULL THEN 0 ELSE Q009.RmrExpense END AS RMRExp,    
 CASE WHEN Q009.EstCostParts IS NULL THEN 0 ELSE Q009.EstCostParts END AS EstCostParts,     
 CASE WHEN Q009.EstCostLabor IS NULL THEN 0 ELSE Q009.EstCostLabor END AS EstCostLabor,     
 CASE WHEN Q009.EstCostMisc IS NULL THEN 0 ELSE Q009.EstCostMisc END AS EstCostMisc,     
 CASE WHEN [EstHrs] IS NULL THEN 0 ELSE [EstHrs] END AS EstHrs,     
 CASE WHEN Q009.PartCost IS NULL THEN 0 ELSE Q009.PartCost END AS PartCost,     
 CASE WHEN Q009.OtherCost IS NULL THEN 0 ELSE Q009.OtherCost END AS OtherCost,     
 CASE WHEN Q009.LaborCost IS NULL THEN 0 ELSE Q009.LaborCost END AS LaborCost,    
 CASE WHEN Q009.CommCost IS NULL THEN 0 ELSE Q009.CommCost END AS CommCost,     
 CASE WHEN Q009.BaseInstPrice IS NULL THEN 0 ELSE Q009.BaseInstPrice END AS BaseInstPrice,
 Round(CASE WHEN Q009.Billed IS NULL THEN 0 ELSE Q009.Billed END,2) AS TotBilled,
 Round(CASE WHEN Q009.Billed IS NULL 
		THEN CASE WHEN Q009.JobCost IS NULL THEN 0 ELSE Q009.JobCost * -1 END
		ELSE CASE WHEN Q009.JobCost IS NULL THEN Q009.Billed
				ELSE Q009.Billed - Q009.JobCost END
	END,2) AS MarginAmt, 
 Round(CASE WHEN (Q009.Billed IS NULL ) OR (Q009.Billed = 0)
		THEN 0 
		ELSE CASE WHEN Q009.JobCost IS NULL THEN 100 
				ELSE ((Q009.Billed - Q009.JobCost)/(Q009.Billed))* 100 END
	END,2) AS Margin,
 CASE WHEN Q009.LseYN = 0 THEN Q009.GLAcctSaleCOS ELSE Q009.GLAcctLseCOS END 
	AS CosAcct
   INTO #temp  
FROM [ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008]('<ALL>','<ALL>')  Q009   
WHERE ((Q009.ProjectId IS  NULL) OR   (Q009.ProjectId = '') OR  (Q009.ProjectId = ' '))  
 AND ((Q009.Status = 'Completed') OR (Q009.Status = 'Closed') )  
ORDER BY  Q009.SiteId,     
 Q009.Site,     
 Q009.Address,     
 Q009.Subdiv, Q009.Block,   
 Q009.TicketID   
   
 --SELECT * FROM #temp  
 SET @str =    
'SELECT * FROM #temp '  + CASE WHEN @Where IS NULL THEN ' '    
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