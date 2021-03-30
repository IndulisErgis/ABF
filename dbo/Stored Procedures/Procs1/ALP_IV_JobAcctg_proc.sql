CREATE PROCEDURE [dbo].[ALP_IV_JobAcctg_proc]           
 (@Where nvarchar(1000)= NULL)        
 --created by mah 3/2016      
 --modified by mah 09/13/16 - added ticket resolution information      
 --modified by ravi 13 oct 17 - added sysDesc and SysId information  
AS            
SET NOCOUNT ON;          
DECLARE @str nvarchar(2000) = NULL            
          
BEGIN TRY            
 CREATE TABLE #temp (          
  [TicketId] [int],          
  [SiteId] [int]NULL,          
  [Status] [varchar](10) NULL,          
  [WorkDesc] [text] NULL,          
  [CustId] [varchar](10) NULL,          
  [OtherComments] [text] NULL,          
  [CloseDate] [datetime] NULL,          
  [SalesRepId] [varchar](3) NULL,          
  [ProjectId] [varchar](10) NULL,          
  [CsConnectYn] [bit] NULL,          
  [CompleteDate] [datetime] NULL,          
  [TurnoverDate] [datetime] NULL,          
  [CancelDate] [datetime] NULL,          
  [WorkCodeId] [int] NULL,          
  [DeptId] [int] NULL,      
  [DivId] [int] NULL,          
  [BranchId] [int] NULL,      
  [CommPaidDate] [datetime] NULL,      
  [InvcDate] [datetime] NULL,      
  [StartRecurDate] [datetime] NULL,      
  [BilledYn] [bit] NULL,      
  [RMRAdded] decimal(20,10) NULL,      
  [CommAmt]  decimal(20,10) NULL,      
  [InvcNum] [varchar] (15) NULL,      
  [JobPrice] decimal(20,2) NULL,      
  [InvcStatus] varchar (5) NULL ,    
  [ResolId] int NULL,    
  [ResolComments] text NULL , 
  --modified by ravi 13 oct 17 - added sysId information  
  SysId INT 
  )             
           
 SET @str =            
  'INSERT INTO #temp (TicketId,SiteId,Status,          
  WorkDesc,CustId,          
  OtherComments,CloseDate,SalesRepId,          
  ProjectId,CsConnectYn,CompleteDate,TurnoverDate,CancelDate,         
  WorkCodeId,  DeptId, DivId, BranchId,      
  CommPaidDate,  InvcDate,  StartRecurDate,  BilledYn,      
  RMRAdded,  CommAmt,  InvcNum,  JobPrice,  InvcStatus, ResolId, ResolComments ,SysId 
 )          
  SELECT  TicketId, ALP_tblJmSvcTkt.SiteId, Status,          
  WorkDesc, ALP_tblJmSvcTkt.CustID,          
  OtherComments,CAST(CloseDate AS DATE),SalesRepId,          
  ProjectId,CsConnectYn,CAST(CompleteDate as DATE),TurnoverDate,CancelDate,         
  WorkCodeId,          
  DeptId , DivId, BranchId ,      
  CommPaidDate,  InvcDate,  StartRecurDate,  BilledYn,      
  RMRAdded,  CommAmt,  InvcNum,  100,  ''OPEN'', ResolId, ResolComments  ,
  --modified by ravi 13 oct 17 - added sysId information 
  ALP_tblJmSvcTkt.SysId      
   FROM ALP_tblJmSvcTkt 
   --modified by ravi 13 oct 17 - added sysDesc information  
   LEFT OUTER JOIN ALP_tblArAlpSiteSys on  ALP_tblJmSvcTkt.SysId= ALP_tblArAlpSiteSys.sysId 
   and ALP_tblJmSvcTkt.SiteId=ALP_tblArAlpSiteSys.SiteId 
   LEFT OUTER JOIN Alp_tblAralpSysType ON ALP_tblArAlpSiteSys.SysTypeId= Alp_tblAralpSysType.SysTypeId'          
   
  + CASE WHEN @Where IS NULL THEN ' '          
   WHEN @Where = '' THEN ' '          
   WHEN @Where = ' ' THEN ' '          
   ELSE ' WHERE ' + @Where          
   END           
           
         -- Print @str
 execute (@str)          
      
 SELECT T.TicketId, T.SiteId, T.Status,          
  T.WorkDesc, T.CustID, T.OtherComments,T.CloseDate as Closed,T.SalesRepId as Rep,          
  T.ProjectId,  CASE WHEN T.CsConnectYn  = 1 THEN 'Y' ELSE 'N' END AS CsConnectYN,      
  T.CompleteDate as Completed,T.TurnoverDate,T.CancelDate,          
  S.SiteName, S.AlpFirstName as FirstName, S.Addr1, S.Addr2, S.City,S.PostalCode,          
  W.WorkCode, ALP_tblArAlpDept.Dept, ALP_tblArAlpBranch.Branch, ALP_tblArAlpDivision.Division as Div ,      
  T.CommPaidDate as CommPaid,  T.InvcDate, T.StartRecurDate as StartRecur,        
  CASE WHEN T.BilledYn = 0 THEN 'N' ELSE 'Y' END AS BilledYN,      
  CAST(T.RMRAdded as Decimal(10,2)) as RMRAdded,CAST(T.CommAmt as Decimal(10,2)) as CommAmt,      
  T.InvcNum,      
  CAST(dbo.ALP_ufxJmComm_GetSvcJobPrice(T.TicketID) AS DECIMAL(20,2)) AS JobPrice,      
  CASE WHEN InvcNum IS NULL THEN '' WHEN InvcNum = '' THEN ''       
  ELSE dbo.ALP_ufxJmComm_CheckInvcStatus(T.InvcNum) END AS InvcStatus,      
  Case When T.Status ='Scheduled' then dbo.ALP_ufxJmNextDate(T.TicketId) else NULL End as NextVisit ,      
  dbo.ALP_ufxJmLastDate(T.TicketId)  as LastVisit  ,    
  ALP_tblJmResol.ResolCode as Resolution, ALP_tblJmResol.Descr as ResolDescription, T.ResolComments  ,
  --modified by ravi 13 oct 17 - added sysDesc,SysType information  
   T.SysId, sys.SysDesc  ,sysType.SysType
     FROM #temp T INNER JOIN ALP_tblArAlpSite S    ON S.SiteId = T.SiteId       
     
    INNER JOIN ALP_tblJmWorkCode W  ON W.WorkCodeId = T.WorkCodeId        
    INNER JOIN ALP_tblArAlpDept ON T.DeptId = ALP_tblArAlpDept.DeptId           
	INNER JOIN ALP_tblArAlpBranch ON T.BranchId = ALP_tblArAlpBranch.BranchId      
    INNER JOIN ALP_tblArAlpDivision ON T.DivId = ALP_tblArAlpDivision.DivisionId      
    LEFT OUTER JOIN ALP_tblJmResol ON T.ResolId = ALP_tblJmResol.ResolId    
    --modified by ravi 13 oct 17 - added sysDesc information  
    INNER JOIN ALP_tblArAlpSiteSys  sys ON S.SiteId= sys.SiteId and T.SysId = sys.SysId  
    LEFT OUTER JOIN      ALP_tblArAlpSysType sysType ON sysType.SysTypeId =sys.SysTypeId
 DROP TABLE #temp             
END TRY            
BEGIN CATCH            
 EXEC dbo.trav_RaiseError_proc            
END CATCH