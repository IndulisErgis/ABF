CREATE VIEW [dbo].[ALP_lkpJmJobs]            
AS            
SELECT dbo.ALP_tblJmWorkCode.WorkCode, dbo.ALP_tblJmSvcTkt.TicketId, dbo.ALP_tblArAlpSiteSys.SysDesc, dbo.ALP_tblJmSvcTkt.PrefDate,            
dbo.ALP_tblJmSvcTkt.ToSchDate, dbo.ALP_tblJmSvcTkt.Status, dbo.ALP_tblJmSvcTkt.ProjectId, dbo.ALP_tblJmSvcTkt.SiteId            
--Below line added by NSK on 15 Oct 2014          
,dbo.ALP_tblJmWorkCode.[Desc]         
--Below line added by NSK on 16 Dec 2014        
,ALP_tblJmSvcTkt.BinNumber,ALP_tblJmSvcTkt.BoDate        
--Below line added by NSK on 19 Mar 2015      
,ALP_tblJmSvcTkt.StagedDate    
--Below line added by NSK on 10 Jul 2015    
,ALP_tblJmSvcTkt.OtherComments 
--Below line added by NSK on 17 Dec 2018 for bug id 868
,ALP_tblJmSvcTkt.HoldInvCommitted      
FROM dbo.ALP_tblJmSvcTkt INNER JOIN            
dbo.ALP_tblJmWorkCode ON dbo.ALP_tblJmSvcTkt.WorkCodeId = dbo.ALP_tblJmWorkCode.WorkCodeId INNER JOIN            
dbo.ALP_tblArAlpSiteSys ON dbo.ALP_tblJmSvcTkt.SysId = dbo.ALP_tblArAlpSiteSys.SysId            
WHERE (dbo.ALP_tblJmSvcTkt.Status = 'NEW') OR            
(dbo.ALP_tblJmSvcTkt.Status = 'Targeted') OR            
(dbo.ALP_tblJmSvcTkt.Status = 'Scheduled')    
--Below condition added by NSK on 26 Aug 2016 for bug id 524   
--start        
OR (dbo.ALP_tblJmSvcTkt.Status = 'Completed')OR            
(dbo.ALP_tblJmSvcTkt.Status = 'Closed')  
--end