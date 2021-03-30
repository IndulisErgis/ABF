
CREATE PROCEDURE [dbo].[ALP_IV_ServiceContracts_sp] 
 --Created 07/10/17 by MAH
(
	 @Where nvarchar(1000)= NULL  
)
AS    
SET NOCOUNT ON;  
DECLARE @str nvarchar(2000) = NULL  
DECLARE @AsOf Date 
BEGIN TRY  
         
 CREATE TABLE #Work (          
  [SiteId] [int]NULL,          
  [SysId] [int] NULL, 
  [SysType] [varchar](10) NULL, 
  [SysDesc] [varchar](255) NULL, 
  [Site]  [varchar](120) NULL,
  [Address] [varchar](110) NULL,
  [WorkCode] [varchar](10) NULL, 
  [JobCount] [int] NULL,
  [JobPrice] [decimal](20, 10) NULL,   
  [PartCost]  [decimal](20, 10) NULL,      
  [OtherCost]  [decimal](20, 10) NULL,      
  [LaborCost]  [decimal](20, 10) NULL,      
  [CommCost]  [decimal](20, 10) NULL,      
  [JobCost]  [decimal](20, 10) NULL,
  [LastVisit] [date] NULL ,
  [BilledFromJob]  [decimal](20, 10) NULL,
 -- [LeadTech] [varchar](3) NULL,
  [Rep] [varchar] (3) NULL,
  [JobPV] [decimal](20, 10) NULL    
 
  )             
 CREATE TABLE #RMR (          
  [RSiteId] [int]NULL,          
  [RSysId] [int] NULL,
  [ServiceID] [varchar](24) NULL,
  [ServiceCount] int NULL,
  [RMRToDate] [decimal](20, 10) NULL
  )           

  INSERT INTO #Work (SiteId,SysId, [SysType], [SysDesc] ,Site, Address, [WorkCode],JobCount,JobPrice,PartCost,OtherCost,LaborCost,CommCost, JobCost,LastVisit, BilledFromJob, Rep, JobPV )          
  SELECT  Q9.Q9SiteId, Q9.Q9SysId,Q9.SysType,  Q9.SysDesc, Q9.Q9Site, Q9.Q9Address, Q9.WorkCode, COUNT(Q9.Q9TicketId),SUM(Q9.Q9JobPrice),
	SUM(Q9.Q9PartCost) , SUM(Q9.Q9OtherCost), SUM(Q9.Q9LaborCost),SUM(Q9.Q9CommCost) , SUM(Q9.Q9JobCost), MAX(Q9.LastVisitDate), SUM(Q9.Q9BilledTotal) , MAX(Q9.Rep) , SUM(Q9.Q9JobPV) 
  FROM ufxALP_IV_ServiceContracts_JobInfo_Q9() Q9  INNER JOIN ALP_tblJmSvcTkt T	
		ON	Q9.Q9TicketId = T.TicketId 
  GROUP BY Q9.Q9SiteId, Q9.Q9SysId,Q9.SysType,  Q9.SysDesc, Q9.Q9Site, Q9.Q9Address, Q9.WorkCode
  
  SET @AsOf = GetDate()
  INSERT INTO #RMR (RSiteId, RSysId, ServiceId, ServiceCount,  RMRToDate )          
  SELECT  Q8.Q8SiteId, Q8.Q8SysId, Q8.ServiceId, COUNT(Q8.RecBillServID), SUM(Q8.Price * Q8.MonthsAtThisPrice)
	FROM  [dbo].[ufxALP_IV_ServiceContracts_RMR_Q8] (@AsOf)  Q8
	GROUP BY Q8.Q8SiteId, Q8.Q8SysId, Q8.ServiceId

--  SET @str = 'SELECT #Work.SysId, #Work.SiteId, #Work.SysDesc, #Work.SysType, #Work.Site, #Work.WorkCode, #Work.JobCost,#Work.BilledAmt, #RMR.ServiceId,#RMR.ServiceCount, #RMR.RMRToDate as ServiceContractRMR, '
--	+ '#Work.Address '
--	+ ' from #Work LEFT OUTER JOIN #RMR ON #Work.SiteID = #RMR.RSiteId  AND #Work.SysID = #RMR.RSysId '
--    + CASE WHEN @Where IS NULL THEN ' '          
--		WHEN @Where = '' THEN ' '          
--		WHEN @Where = ' ' THEN ' '          
--		ELSE ' WHERE ' + @Where          
--	  END 
--execute (@str) 

--produce main dataset
  SET @str = 'SELECT SysId, SiteId, SysDesc, SysType, Site, Rep,  WorkCode, JobPV, JobCost, BilledFromJob, LastVisit, ServiceId, ServiceCount,RMRToDate as ServiceContractRMR, '
	+ ' Address '
	+ ' from #Work LEFT OUTER JOIN #RMR ON #Work.SiteID = #RMR.RSiteId  AND #Work.SysID = #RMR.RSysId '
    + CASE WHEN @Where IS NULL THEN ' '          
		WHEN @Where = '' THEN ' '          
		WHEN @Where = ' ' THEN ' '          
		ELSE ' WHERE ' + @Where          
	  END 
execute (@str) 

----produce Work details
	SELECT 	Q9TicketId as TicketId, Q9SiteId as SiteId, Q9SysId, WorkCode, WorkDesc,OrderDate, CompleteDate, CloseDate, ResolCode,LastVisitDate,
	Q9JobPrice as JobPrice, Q9PartCost as PartCost, Q9OtherCost as OtherCost, Q9LaborCost as LaborCost, Q9CommCost as CommCost, Q9JobCost as JobCost,
	Q9JobPV as JobPV, Billed, Q9BilledTotal as BilledFromJob, Q9.LeadTech, Q9.Rep  
	FROM  #TransList t     
		INNER JOIN  ufxALP_IV_ServiceContracts_JobInfo_Q9() Q9 ON t.SysId = Q9.Q9SysId


----produce ServiceContract details  
	SELECT Q8SiteId as SiteId, Q8SysId, RecBillServId, ServiceID,ServiceDescription, ServiceStartDate, StartBillDate, EndBillDate, FinalBillDate, CanServEndDate as Cancelled, 
	AsOfDate, Price, MonthsAtThisPrice, Q8ItemId as BillGroup, ToDate = Price * MonthsAtThisPrice, ' ' as WorkCode
	FROM  #TransList t     
		INNER JOIN   [dbo].[ufxALP_IV_ServiceContracts_RMR_Q8] (@AsOf)  Q8 ON t.SysId = Q8.Q8SysId
           
END TRY
BEGIN CATCH            
 EXEC dbo.trav_RaiseError_proc            
END CATCH