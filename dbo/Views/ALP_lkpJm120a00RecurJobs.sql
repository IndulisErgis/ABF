
  
CREATE VIEW [dbo].[ALP_lkpJm120a00RecurJobs]  
AS  
SELECT     dbo.ALP_tblArAlpSiteRecJob.RecJobEntryId, dbo.ALP_tblArAlpSiteRecJob.CreateDate, dbo.ALP_tblArAlpSiteRecJob.CustId, dbo.ALP_tblArAlpSiteRecJob.SiteId,   
                      dbo.ALP_tblArAlpSiteRecJob.RecBillEntryId, dbo.ALP_tblArAlpSiteRecJob.RecSvcId, dbo.ALP_tblArAlpSiteRecJob.SysId, dbo.ALP_tblArAlpSiteRecJob.ContractId,   
                      dbo.ALP_tblArAlpSiteRecJob.CustPoNum, dbo.ALP_tblArAlpSiteRecJob.JobCycleId, dbo.ALP_tblArAlpSiteRecJob.LastCycleStartDate,   
                      dbo.ALP_tblArAlpSiteRecJob.NextCycleStartDate, dbo.ALP_tblArAlpSiteRecJob.ExpirationDate, dbo.ALP_tblArAlpSiteRecJob.LastDateCreated,   
                      dbo.ALP_tblArAlpSiteRecJob.Contact, dbo.ALP_tblArAlpSiteRecJob.ContactPhone, dbo.ALP_tblArAlpSiteRecJob.WorkDesc, dbo.ALP_tblArAlpSiteRecJob.WorkCodeId,   
                      dbo.ALP_tblArAlpSiteRecJob.RepPlanId, dbo.ALP_tblArAlpSiteRecJob.PriceId, dbo.ALP_tblArAlpSiteRecJob.BranchId, dbo.ALP_tblArAlpSiteRecJob.DeptId,   
                      dbo.ALP_tblArAlpSiteRecJob.DivId, dbo.ALP_tblArAlpSiteRecJob.SkillId, dbo.ALP_tblArAlpSiteRecJob.PrefTechId, dbo.ALP_tblArAlpSiteRecJob.EstHrs,   
                      dbo.ALP_tblArAlpSiteRecJob.PrefTime, dbo.ALP_tblArAlpSiteRecJob.OtherComments, dbo.ALP_tblArAlpRepairPlan.[Desc] AS ALP_tblArAlpRepairPlan_Desc,   
                      dbo.ALP_tblArAlpCycle.[Desc] AS ALP_tblArAlpCycle_Desc, dbo.ALP_tblArAlpSiteSys.SysDesc, dbo.ALP_tblArAlpSiteRecBillServ.ServiceID, dbo.ALP_tblArAlpCycle.Cycle,
                      --AlarmId added by NSK on 26 Nov 2014
                      ALP_tblArAlpSiteSys.AlarmId
FROM         dbo.ALP_tblArAlpSiteSys RIGHT OUTER JOIN  
                      dbo.ALP_tblJmWorkCode RIGHT OUTER JOIN  
                      dbo.ALP_tblArAlpRepairPlan RIGHT OUTER JOIN  
                      dbo.ALP_tblArAlpCycle RIGHT OUTER JOIN  
                      dbo.ALP_tblArAlpSiteRecJob ON dbo.ALP_tblArAlpCycle.CycleId = dbo.ALP_tblArAlpSiteRecJob.JobCycleId ON   
                      dbo.ALP_tblArAlpRepairPlan.RepPlanId = dbo.ALP_tblArAlpSiteRecJob.RepPlanId ON dbo.ALP_tblJmWorkCode.WorkCodeId = dbo.ALP_tblArAlpSiteRecJob.WorkCodeId ON   
                      dbo.ALP_tblArAlpSiteSys.SysId = dbo.ALP_tblArAlpSiteRecJob.SysId LEFT OUTER JOIN  
                      dbo.ALP_tblArAlpSiteRecBillServ ON dbo.ALP_tblArAlpSiteRecJob.RecSvcId = dbo.ALP_tblArAlpSiteRecBillServ.RecBillServId