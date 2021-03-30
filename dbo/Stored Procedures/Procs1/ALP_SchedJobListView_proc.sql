
CREATE PROCEDURE [dbo].[ALP_SchedJobListView_proc]           
 (@Where nvarchar(1000)= NULL)          
AS            
SET NOCOUNT ON;          
DECLARE @str nvarchar(2000) = NULL            
          
BEGIN TRY            
 CREATE TABLE #temp (          
  [TicketId] [int],          
  [CreateDate] [datetime] NULL,          
  [SiteId] [int]NULL,          
  [Status] [varchar](10) NULL,          
  [Contact] [varchar](60) NULL,          
  [ContactPhone] [varchar](15) NULL,          
  [WorkDesc] [text] NULL,          
  [CustId] [varchar](10) NULL,          
  [EstHrs] [float] NULL,          
  [PrefDate] [datetime] NULL,          
  [PrefTime] [varchar](50) NULL,          
  [OtherComments] [text] NULL,          
  [CloseDate] [datetime] NULL,          
  [SalesRepId] [varchar](3) NULL,          
  [ProjectId] [varchar](10) NULL,          
  [CsConnectYn] [bit] NULL,          
  [CompleteDate] [datetime] NULL,          
  [TurnoverDate] [datetime] NULL,          
  [CancelDate] [datetime] NULL,          
  [BoDate] [datetime] NULL,          
  [StagedDate] [datetime] NULL,          
  [BinNumber] [varchar](10) NULL,          
  [ToSchDate] [datetime] NULL,          
  [SysId] [int] NULL,          
  [WorkCodeId] [int] NULL,          
  [LeadTechId] [int] NULL,          
  [DeptId] [int] NULL,      
  [DivId] [int] NULL,          
  [BranchId] [int] NULL,  
  [ResolId] [int] NULL)             
           
 SET @str =            
  'INSERT INTO #temp (TicketId,CreateDate,SiteId,Status,          
  Contact,ContactPhone,WorkDesc,CustId,EstHrs,          
  PrefDate,PrefTime,OtherComments,CloseDate,SalesRepId,          
  ProjectId,CsConnectYn,CompleteDate,TurnoverDate,CancelDate,BoDate,          
  StagedDate,BinNumber,ToSchDate,SysId,WorkCodeId,          
  LeadTechId,DeptId, DivId, BranchId, ResolId)          
  SELECT  TicketId, CONVERT(datetime,CreateDate,1) as [CreateDate],SiteId, Status,          
  Contact, ContactPhone, WorkDesc, CustID,EstHrs,PrefDate, PrefTime,          
  OtherComments,CloseDate,SalesRepId,          
  ProjectId,CsConnectYn,CompleteDate,TurnoverDate,CancelDate,BoDate,          
  StagedDate,BinNumber,ToSchDate,SysId,WorkCodeId,          
  LeadTechId,DeptId , DivId, BranchId , ResolId       
  FROM ALP_tblJmSvcTkt   '          
  + CASE WHEN @Where IS NULL THEN ' '          
   WHEN @Where = '' THEN ' '          
   WHEN @Where = ' ' THEN ' '          
   ELSE ' WHERE ' + @Where          
   END           
          
 execute (@str)          
           
 SELECT T.TicketId, CONVERT(datetime,T.CreateDate,1) as CreateDate,T.SiteId, T.Status,          
  T.Contact, T.ContactPhone, T.WorkDesc, T.CustID,T.EstHrs,          
  T.PrefDate as Targeted, T.PrefTime,T.OtherComments,T.CloseDate as Closed,T.SalesRepId,          
  T.ProjectId,      
  --T.CsConnectYn,      
  CASE WHEN T.CsConnectYn  = 0 THEN 'N' ELSE 'Y' END AS CsConnectYn,      
  T.CompleteDate as Completed,T.TurnoverDate,T.CancelDate,T.BoDate,          
  T.StagedDate as Staged,T.BinNumber,T.ToSchDate,S.SiteName, S.AlpFirstName as FirstName,          
  S.Addr1, S.Addr2, S.City,S.PostalCode,S.MapId,SS.AlarmId,          
  W.WorkCode,ST.SysType, JT.Tech AS Tech,      
   ALP_tblArAlpDept.Dept, ALP_tblArAlpBranch.Branch,       
   ALP_tblArAlpDivision.Division as Div ,    
   dbo.ALP_ufxJmNextDate(T.TicketId) as NextSched,    
   dbo.ALP_ufxJmNextTech(T.TicketId) as NextTech,  
   --mah 09/16/16 - added:  
   RC.ResolCode as TktResol, RC.Descr as TktResolDescr  , S.Region   
  FROM ALP_tblJmTech JT RIGHT JOIN (ALP_tblJmWorkCode W          
  INNER JOIN (ALP_tblArAlpSysType ST          
   INNER JOIN  (((((ALP_tblArAlpSite S          
    INNER JOIN #temp T ON S.SiteId = T.SiteId)          
    INNER JOIN ALP_tblArAlpSiteSys SS ON T.SysId = SS.SysId)          
    INNER JOIN ALP_tblArAlpDept ON T.DeptId = ALP_tblArAlpDept.DeptId)           
    INNER JOIN ALP_tblArAlpBranch ON T.BranchId = ALP_tblArAlpBranch.BranchId)      
    INNER JOIN ALP_tblArAlpDivision ON T.DivId = ALP_tblArAlpDivision.DivisionId)  
    LEFT OUTER JOIN ALP_tblJmResol RC ON  T.ResolId = RC.ResolId         
   ON ST.SysTypeId = SS.SysTypeId)           
  ON W.WorkCodeId = T.WorkCodeId)           
  ON JT.TechID = T.LeadTechId           
 ORDER BY TicketId DESC           
 DROP TABLE #temp          
       
          
 -- select Techs/timecards           
SELECT  TC.TicketId, Tech.Tech,           
  CAST(TC.StartDate AS DATE) AS StartDate, CAST(TC.EndDate AS DATE) AS EndDate,           
  dbo.ALP_ufxConvertToTimeFormat(TC.StartTime) as StartTime,          
  dbo.ALP_ufxConvertToTimeFormat(TC.EndTime) as EndTime,          
        CONVERT(decimal(10,2),ROUND(TC.BillableHrs,2)) as BillableHrs, TC.Points, TC.TimeCardComment, TC.SpecializedLaborType,           
                      Tech.Name, CD.TimeCode          
FROM #TransList t           
  INNER JOIN  ALP_tblJmTimeCard  TC ON t.TicketID = TC.TicketID           
  LEFT OUTER JOIN  ALP_tblJmTimeCode CD ON TC.TimeCodeID = CD.TimeCodeID           
        LEFT OUTER JOIN ALP_tblJmTech Tech ON TC.TechID = Tech.TechId          
ORDER BY TicketId DESC          
           
 --select job actions           
SELECT  TI.TicketId, TI.ItemID,I.Descr as Description, CAST(QtyAdded AS Decimal(10,2)) as Qty,           
 CAST(QtyRemoved as Decimal(10,2)) as QtyRemoved,           
 CAST(QtyServiced as Decimal(10,2)) as QtyServiced,           
 ResDesc as Resolution, CauseDesc as Cause ,Comments,UOM,          
 UnitPrice, UnitCost, PartPulledDate,            
 WhseId, EquipLoc          
FROM #TransList t           
 INNER JOIN  ALP_tblJmSvcTktItem  TI ON t.TicketID = TI.TicketID           
 LEFT OUTER JOIN tblInItem I ON TI.ItemId = I.ItemId          
ORDER BY TicketId DESC          
          
END TRY            
BEGIN CATCH            
 EXEC dbo.trav_RaiseError_proc            
END CATCH