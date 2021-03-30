CREATE PROCEDURE dbo.Alp_qryArAlpSiteRecJobListview @ID int          
--Query Modified by ravi on 09.11.2015, added ExpirationDate column to show in site recurring job screen
As        
SET NOCOUNT ON        
SELECT ALP_tblArAlpSiteRecJob.RecJobEntryId, Alp_tblArAlpSiteSys.SysDesc, Alp_tblArAlpSiteRecBillServ.ServiceID, ALP_tblArAlpSiteRecJob.CustId,    
 Alp_tblJmWorkCode.WorkCode,      Alp_tblArAlpCycle.Cycle, Alp_tblArAlpSiteRecJob.NextCycleStartDate, Alp_tblArAlpSiteRecJob.EstHrs,     
 Alp_tblArAlpSiteRecJob.ContactPhone,      Alp_tblArAlpSiteRecJob.OtherComments  ,Alp_tblArAlpSiteRecJob.ExpirationDate       
FROM ((ALP_tblArAlpSiteRecJob INNER JOIN ALP_tblArAlpSiteSys  ON Alp_tblArAlpSiteRecJob.SysId = Alp_tblArAlpSiteSys.SysId)         
LEFT OUTER JOIN Alp_tblArAlpCycle ON Alp_tblArAlpSiteRecJob.JobCycleId = Alp_tblArAlpCycle.CycleId)     
LEFT OUTER JOIN Alp_tblJmWorkCode ON Alp_tblArAlpSiteRecJob.WorkCodeId = Alp_tblJmWorkCode.WorkCodeID        
LEFT OUTER JOIN Alp_tblArAlpSiteRecBillServ ON Alp_tblArAlpSiteRecJob.RecSvcId = Alp_tblArAlpSiteRecBillServ.RecBillServId        
WHERE (((Alp_tblArAlpSiteRecJob.SiteId)=@ID ))