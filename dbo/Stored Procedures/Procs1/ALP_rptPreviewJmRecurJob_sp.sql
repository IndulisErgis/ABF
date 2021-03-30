CREATE procedure [dbo].[ALP_rptPreviewJmRecurJob_sp]                    
--Created by NSK on 22 Sep 2015.This is a copy of  ALP_rptJmRecurJob_sp.          
--Replaced ALP_tblArAlpSiteRecJob with ALP_tmpArAlpSiteRecJob          
(                    
 @CustIdFrom pCustId,                    
 @CustIdThru pCustId,                    
 @SiteNameFrom varchar(100),                    
 @SiteNameThru varchar(100),                    
 @BranchFrom varchar(255),                    
 @BranchThru varchar(255),                    
 @GroupFrom varchar(1),                    
 @GroupThru varchar(1),                    
 @ClassFrom varchar(6),                    
 @ClassThru varchar(6),                    
 @WorkCodeFrom varchar(10),                    
 @WorkCodeThru varchar(10),                    
 @NextDate datetime,          
 @UserId varchar(50)                 
) 
--modified to increase Alpine userID length of 50 from 16, mah 05/05/17   
                   
AS                    
SET NOCOUNT ON                    
                    
--delete all prior contents of tmp Recur Job table                    
DELETE FROM ALP_tmpJmRecurJob where UserId=  @UserId -- where condition added by NSK on 05 Oct 2015                    
--insert results from current Recur Job Process                    
INSERT INTO ALP_tmpJmRecurJob                    
    SELECT RJ.RecJobEntryId, RJ.CreateDate,                     
 RJ.CustId, RJ.SiteId, RJ.RecBillEntryId, RJ.RecSvcId,                    
 RJ.SysId, RJ.ContractId, RJ.CustPoNum,                     
 RJ.JobCycleId,RJ.LastCycleStartDate,                     
 RJ.NextCycleStartDate, RJ.ExpirationDate, RJ.LastDateCreated,RJ.Contact,                    
 RJ.ContactPhone, RJ.WorkDesc, RJ.WorkCodeId,                    
 RJ.RepPlanId,RJ.PriceId, RJ.BranchId,                     
 RJ.DeptId, RJ.DivId, RJ.SkillId, RJ.PrefTechId,                     
 RJ.EstHrs, RJ.PrefTime, RJ.OtherComments,                    
 RJ.SalesRepId, S.SiteName, CY.Cycle,                     
 SS.SysDesc, W.WorkCode, RBS.ServiceID,                     
 SS.InstallDate,  
 --RBS.Status,--Commented by NSK on 11 Jul 2016  
 --Below code added by NSK on 11 Jul 2016 to display status correctly. Bug id 400  
 --start  
 CASE WHEN dbo.ALP_ufxArAlpSite_IsServiceActive (RJ.SiteId,RJ.RecSvcId,RJ.NextCycleStartDate) = 1 -- Case Added by NSK on 08 Jul 2016 for bug id 400                       
  THEN 'Active'                        
  ELSE 'InActive'                        
 END as Status,  
 --end  
 CY.Units,                    
 CC.ClassId            
  ,@UserId -- User ID added by NSK on 05 Oct 2015                  
    FROM dbo.tblArCustClass CC RIGHT OUTER JOIN dbo.ALP_tmpArAlpSiteRecJob RJ           
 --Below line commented by NSK on 28 Sep 2015 because we are not using ALP_tblArAlpSiteRecJobUdf table                  
 --LEFT OUTER JOIN dbo.ALP_tblArAlpSiteRecJobUdf RJU  ON RJ.RecJobEntryId = RJU.RecJobEntryId                     
 INNER JOIN dbo.ALP_tblArAlpSite S ON RJ.SiteId = S.SiteId                     
 LEFT OUTER JOIN dbo.ALP_tblArCust_view C ON RJ.CustId = C.CustId                     
 INNER JOIN dbo.ALP_tblJmWorkCode W ON RJ.WorkCodeId = W.WorkCodeId                     
 LEFT OUTER JOIN dbo.ALP_tblArAlpCycle CY ON RJ.JobCycleId = CY.CycleId                     
 LEFT OUTER JOIN dbo.ALP_tblArAlpSiteSys SS ON RJ.SysId = SS.SysId                     
 LEFT OUTER JOIN dbo.ALP_tblArAlpSiteRecBillServ RBS                    
 ON RJ.RecSvcId = RBS.RecBillServId                     
 LEFT OUTER JOIN dbo.ALP_tblArAlpBranch B ON RJ.BranchId = B.BranchId                     
 ON CC.ClassId = C.ClassId                     
    WHERE (RJ.ExpirationDate > GETDATE() OR RJ.ExpirationDate IS NULL)                    
 AND (RBS.Status <> 'New' OR RBS.Status IS NULL)                    
 AND (NextCycleStartDate <= @NextDate )                  
                 
 --Below lines added by NSK on 28 Jan 2015 for bug id 176                 
 --Start                 
                 
 --check Site From condition:                
and ((@SiteNameFrom IS NULL) OR (@SiteNameFrom is not null and S.SiteName >= @SiteNameFrom))                
--check Site Thru condition:                
and ((@SiteNameThru IS NULL) OR (@SiteNameThru is not null and S.SiteName <= @SiteNameThru))                
                
--check Branch From condition:                
and ((@BranchFrom IS NULL) OR (@BranchFrom is not null and B.Branch >= @BranchFrom))                
--check Branch Thru condition:                
and ((@BranchThru IS NULL) OR (@BranchThru is not null and B.Branch <= @BranchThru))                
                
--check WorkCode From condition:                
and ((@WorkCodeFrom IS NULL) OR (@WorkCodeFrom is not null and W.WorkCode >= @WorkCodeFrom))                
--check WorkCode Thru condition:               
and ((@WorkCodeThru IS NULL) OR (@WorkCodeThru is not null and W.WorkCode <= @WorkCodeThru))                
                
--check CustId From condition:                
and ((@CustIdFrom IS NULL) OR (@CustIdFrom is not null and C.CustId >= @CustIdFrom))                
--check CustId Thru condition:                
and ((@CustIdThru IS NULL) OR (@CustIdThru is not null and C.CustId <= @CustIdThru))                
                
                
--check GroupCode From condition:                
and ((@GroupFrom IS NULL) OR (@GroupFrom is not null and C.GroupCode >= @GroupFrom))                
--check GroupCode Thru condition:                
and ((@GroupThru IS NULL) OR (@GroupThru is not null and C.GroupCode <= @GroupThru))                
                
                
--check ClassId From condition:                
and ((@ClassFrom IS NULL) OR (@ClassFrom is not null and CC.ClassId >= @ClassFrom))                
--check ClassId Thru condition:                
and ((@ClassThru IS NULL) OR (@ClassThru is not null and CC.ClassId <= @ClassThru))                
                
--End                
and RJ.UserId=@UserId               
--output contents for edit report                     
--06/04/09 MAH added:                    
                    
select RJ.*,ActivePrice = Case when RBS.ActivePrice is null then 0                    
 else RBS.ActivePrice end                    
from ALP_tmpJmRecurJob RJ                    
LEFT OUTER JOIN dbo.ALP_tblArAlpSiteRecBillServ RBS                    
 ON RJ.RecSvcId = RBS.RecBillServId        
where RJ.UserId=@UserId  -- added by NSK on 07 Oct 2015                   
--MAH 04/11/14 - added sort order to the output                    
order by SiteName , SysDesc                    
                    
                    
--NOTE: this tmp table will also be used in qryJmAppendRecurJobs and qryJmUpdateRecJobDates                    
-- (to create the new Recurring Jobs, and update SvcTkt fields). 