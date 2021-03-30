
CREATE PROCEDURE [dbo].[ALP_IV_JobSched_sp_test]         
 --Created 04/13/16 by mah     
(        
  @Where nvarchar(1000)= NULL          
)        
AS            
SET NOCOUNT ON;          
DECLARE @str nvarchar(3000) = NULL            
BEGIN TRY      
    
SET @str = 'SELECT  T.ProjectId,T.TicketId, T.Status, T.SiteId, T.CustId,    
 T.LeadTechId,    
 T.SalesRepId as SalesRep,    
 T.ResolComments,    
 RC.ResolCode as Resolution,     
 T.WorkDesc,WC.WorkCode,    
 T.OtherComments as JobComments,     
 CAST(T.StagedDate as DATE) as StagedDate,     
 CAST(T.PrefDate as DATE) as TargetDate,     
 CAST(T.CompleteDate AS DATE) as CompleteDate,    
 CAST(T.CloseDate AS DATE) as CloseDate,    
 CAST(T.TurnoverDate AS DATE) as TurnoverDate,    
 CAST(T.OrderDate AS DATE) as OrderDate, 
 Case When T.Status =''Scheduled'' then dbo.ALP_ufxJmNextDate(T.TicketId) else NULL End as NxtDt,       
 CASE WHEN T.LseYn = 0 THEN ''N'' ELSE ''Y'' END as LeaseYn,     
 CASE WHEN T.CsConnectYn = 0 THEN ''N'' ELSE ''Y'' END AS CS,     
 T.ContactPhone,    
 T.EstHrs, T.PrefTime,    
 T.SysId,T.ResolId,T.WorkCodeId,    
 T.ReturnYn ,T.BranchId, T.DivId,     
 T.DeptId     
INTO #temp      
FROM dbo.ALP_tblJmSvcTkt T      
 INNER JOIN dbo.ALP_tblJmWorkCode WC ON WC.WorkCodeId = T.WorkCodeId    
 LEFT OUTER JOIN dbo.ALP_tblJmResol RC  ON RC.ResolID = T.ResolId '     
 + CASE WHEN @Where IS NULL THEN ' '          
  WHEN @Where = '' THEN ' '          
  WHEN @Where = ' ' THEN ' '          
  ELSE ' WHERE ' + @Where          
  END  + '     
  SELECT T.*, SiteName, S.Addr1, ISNULL(S.Addr2, '''') as Addr2, S.City, S.PostalCode as Zip, S.Block as Lot,    
   tech.Tech as LeadTech,    
   Case When T.Status =''Scheduled'' then dbo.ALP_ufxJmNextDate(T.TicketId) else NULL End as NxtDt,    
   Case When T.Status =''Scheduled'' then dbo.ALP_ufxJmNextTime(T.TicketId) else '''' End as NxtTm,    
   Case When T.Status =''Scheduled'' then dbo.ALP_ufxJmNextTech(T.TicketId) else '''' End as NxtTch,     
 ST.SysType, SS.SysDesc as SystemDesc,  SS.AlarmId,SB.Subdiv as SubDiv    
   FROM #temp T    
   INNER JOIN dbo.ALP_tblJmWorkCode WC ON WC.WorkCodeId = T.WorkCodeId    
   INNER JOIN dbo.ALP_tblArAlpSiteSys SS ON SS.SysId = T.SysId    
   INNER JOIN dbo.ALP_tblArAlpSysType ST ON ST.SysTypeId = SS.SysTypeId    
   LEFT OUTER JOIN dbo.ALP_tblArAlpSite S ON S.SiteId = T.SiteId    
   LEFT OUTER JOIN dbo.ALP_tblJmResol RC  ON RC.ResolID = T.ResolId     
   LEFT OUTER JOIN dbo.ALP_tblJmTech tech ON tech.TechId = T.LeadTechId    
   LEFT OUTER JOIN dbo.ALP_tblArAlpSubdivision SB ON SB.SubDivID = S.SubDivId '    
  select @str     
 execute (@str)     
     
 END TRY            
BEGIN CATCH          
  EXEC dbo.trav_RaiseError_proc            
END CATCH