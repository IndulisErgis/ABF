    
CREATE PROCEDURE [dbo].[ALP_qryJmAppendRecurJobs]                    
--EFI# 1075 mah 11/11/03 - added CreateBy field to identify jobs created                    
--   by Recurring process, and identify if billable or not.                    
--EFI# 1454 MAH 08/25/04 - modified to accomodate Menu Security changes                    
--   Proc now uses tmp table (ALP_tmpJmRecurJob) rather                     
--   than view created within app ( rptJmRecurJob).                    
--EFI# 1505 mah 09/25/04 - added OrderDate; set it to current date.                    
--EFI# 1569 MAH 02/07/06 - added default of 0 for OutOfRegHrs and HolHrs                    
@NextDate datetime,   
 --Below @CreatedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@CreatedBy varchar(50)=null-- Added by NSK on 27 Jun 2016 for bug id 400    
As                    
SET NOCOUNT ON                    
INSERT INTO ALP_tblJmSvcTkt ( CreateDate, SiteId, CustId, SysId, CustPoNum, Contact, ContactPhone,                     
 WorkDesc, WorkCodeId, RepPlanId, PriceId,                     
 BranchId, DeptId, DivId, SkillId, LeadTechId,                     
 EstHrs, OtherComments, PrefTime, Status,                     
 SalesRepId,  ContractId, CreateBy, OrderDate,OutOfRegHrs,HolHrs,PrefDate --Pref date added by NSK on 14 Sep 2015                   
 ,NextInspectDate -- Next inspect date added by NSK on 29 Sep 2015           
 ,RecJobEntryId,RecSvcId) -- RecJobEntryId,RecSvcId added by NSK on 21 Jan 2016         
SELECT Convert(datetime,(convert(varchar,GetDate(),112))),                    
-- GetDate() AS Expr2,                     
 ALP_tmpJmRecurJob.SiteId, ALP_tmpJmRecurJob.CustId, ALP_tmpJmRecurJob.SysId,                    
 ALP_tmpJmRecurJob.CustPoNum, ALP_tmpJmRecurJob.Contact,ALP_tmpJmRecurJob.ContactPhone,                     
 Cast(ALP_tmpJmRecurJob.WorkDesc as nvarchar(4000)) + ' - for ' +   Convert(varchar(10),ALP_tmpJmRecurJob.NextCycleStartDate ,101), -- --Pref date concatenated by NSK on 14 Sep 2015               
 ALP_tmpJmRecurJob.WorkCodeId, ALP_tmpJmRecurJob.RepPlanId,                     
 ALP_tmpJmRecurJob.PriceId, ALP_tmpJmRecurJob.BranchId, ALP_tmpJmRecurJob.DeptId,                     
 ALP_tmpJmRecurJob.DivId, ALP_tmpJmRecurJob.SkillId,ALP_tmpJmRecurJob.PrefTechId,                     
 ALP_tmpJmRecurJob.EstHrs,ALP_tmpJmRecurJob.OtherComments, ALP_tmpJmRecurJob.PrefTime,          
  'Targeted' AS Expr1, -- Status changed to Targeted from New by NSK on 30 Sep 2015 since we are inserting the pref date                      
 ALP_tmpJmRecurJob.SalesRepId,                     
-- Below line commented by NSK on 29 Apr 2014 to not update the reviseddate column                 
-- Convert(datetime,(convert(varchar,GetDate(),112))) as RevisedDate,                    
-- GetDate() AS Expr3,                     
 ALP_tmpJmRecurJob.ContractId,   
 CASE WHEN dbo.ALP_ufxArAlpSite_IsServiceActive (ALP_tmpJmRecurJob.SiteId,ALP_tmpJmRecurJob.RecSvcId,ALP_tmpJmRecurJob.NextCycleStartDate) = 1 -- Case Added by NSK on 27 Jun 2016 for bug id 400                   
  THEN 'RJ-CONTRACT'                    
  ELSE 'RJ-BILLABLE'                    
 END,                    
  --CASE WHEN ALP_tmpJmRecurJob.RecSvcId IS NULL -- Case Commented by NSK on 27 Jun 2016 for bug id 400                    
  --THEN 'RJ-BILLABLE'                    
  --ELSE 'RJ-CONTRACT'                    
  --END,                    
 Convert(datetime,(convert(varchar,GetDate(),112))) as OrderDate,  
 --Alias name added for clarity                  
 0 as OutOfRegHrs,0 as HolHrs,ALP_tmpJmRecurJob.NextCycleStartDate as PrefDate, -- ALP_tmpJmRecurJob.NextCycleStartDate added by NSK on 14 Sep 2015                    
 --below case added by NSK on 29 Sep 2015 to update the next inspect date in the tickets table            
 CASE WHEN Cycle = 'WK' THEN  DateAdd(day,7,ALP_tmpJmRecurJob.NextCycleStartDate)                     
 ELSE DateAdd(month,ALP_tmpJmRecurJob.Units,ALP_tmpJmRecurJob.NextCycleStartDate)                    
 END as NextInspectDate,      
 ALP_tmpJmRecurJob.RecJobEntryId,ALP_tmpJmRecurJob.RecSvcId   -- RecJobEntryId,RecSvcId added by NSK on 21 Jan 2016             
FROM ALP_tmpJmRecurJob                    
WHERE ALP_tmpJmRecurJob.NextCycleStartDate <=@NextDate