CREATE procedure [dbo].[ALP_qryArAlpTempSiteRecJob]     
--Below @UserId  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
--@UserId varchar(16)       
@UserId varchar(50)       
--Created by NSK on 22 Sep 2015 to move the records to a temporary table for preview purpose in recurring job form.       
as              
--delete all prior contents of tmp preview Recur Job table              
DELETE FROM ALP_tmpArAlpSiteRecJob where UserId= @UserId -- added by NSK on 06 Oct 2016           
--insert results from current preview Recur Job Process              
INSERT INTO ALP_tmpArAlpSiteRecJob          
        
SELECT     RJ.RecJobEntryId, RJ.CreateDate, RJ.CustId, RJ.SiteId, RJ.RecBillEntryId, RJ.RecSvcId, RJ.SysId, RJ.ContractId, RJ.CustPoNum, RJ.JobCycleId,         
                      RJ.LastCycleStartDate, RJ.NextCycleStartDate, RJ.ExpirationDate, RJ.LastDateCreated, RJ.Contact, RJ.ContactPhone, RJ.WorkDesc, RJ.WorkCodeId, RJ.RepPlanId,         
                      RJ.PriceId, RJ.BranchId, RJ.DeptId, RJ.DivId, RJ.SkillId, RJ.PrefTechId, RJ.EstHrs, RJ.PrefTime, RJ.OtherComments, RJ.SalesRepId, RJ.ModifiedBy,         
                      RJ.ModifiedDate, RJ.PhoneExt,@UserId        
FROM         ALP_tblArAlpSiteRecJob AS RJ INNER JOIN        
                      ALP_tmpJmRecurJob AS tmp ON tmp.RecJobEntryId = RJ.RecJobEntryId
where tmp.UserId=@UserId -- added by NSK on 06 OCt 2015