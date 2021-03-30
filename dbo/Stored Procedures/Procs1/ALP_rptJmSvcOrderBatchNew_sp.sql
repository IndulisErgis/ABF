
CREATE PROCEDURE [dbo].[ALP_rptJmSvcOrderBatchNew_sp]           
-- Created for EFI# 1454 MAH 08/24/04          
-- Modified 11/04/2011 by Shanthakumar.  Added JObStatus and WorkCode parameters          
-- Ravi changed @IncludeComments bit=0, assigned default value to the parameter on 03.21.2014        
-- MAH 04/21/14: added Scheduled Time to the sort order ( for both sort options )      
(          
 @CompName varchar(50),          
 @CompAddr varchar(50),          
 @IncludeComments bit=0, -- The default value added by ravi on 03.21.2014         
 @SchedFrom datetime,          
 @SchedThru datetime,          
 @TechFrom varchar(3),          
 @TechThru varchar(3),          
 @BranchFrom varchar(255),          
 @BranchThru varchar(255),          
 @DeptFrom varchar(10),          
 @DeptThru varchar(10),          
 @Order varchar(1),          
 @JobStatus varchar(50),  -- added by NSK on 11/04/2011          
 @WorkCode varchar(50) -- added by NSK on 11/04/2011          
)           
AS           
Set nocount on          
SELECT dbo.ALP_tblJmSvcTkt.TicketId, dbo.ALP_tblJmSvcTkt.ProjectId, dbo.ALP_tblJmSvcTkt.PrefTime,           
 CONVERT(varchar,ALP_tblJmSvcTkt.CreateDate,1) AS CreateDate,           
 ALP_tblJmSvcTkt.CreateBy, dbo.ALP_tblJmSvcTkt.CustId,          
 CASE WHEN ALP_tblArCust_view.AlpFirstName IS NULL OR ALP_tblArCust_view.AlpFirstName = '' THEN CustName           
  ELSE CustName + ', ' + ALP_tblArCust_view.AlpFirstName END AS Customer,ALP_tblJmSvcTkt.SiteId,           
 CASE WHEN ALP_tblArAlpSite.AlpFirstName IS NULL OR ALP_tblArAlpSite.AlpFirstName = '' THEN SiteName           
  ELSE SiteName + ', ' + ALP_tblArAlpSite.AlpFirstName END AS Site,          
 CASE WHEN ALP_tblArAlpSite.Addr2 IS NULL OR ALP_tblArAlpSite.Addr2 = '' THEN ALP_tblArAlpSite.Addr1           
  ELSE ALP_tblArAlpSite.Addr1 + ', ' + ALP_tblArAlpSite.Addr2 END AS Address,          
 coalesce(ALP_tblArAlpSite.City,'') + ', ' + coalesce(ALP_tblArAlpSite.Region,'') + ' '           
  + coalesce(ALP_tblArAlpSite.PostalCode,'') AS CityState, ALP_tblJmSvcTkt.Contact, ALP_tblJmSvcTkt.ContactPhone,           
 ALP_tblJmSvcTkt.SysId, ALP_tblArAlpSiteSys.SysDesc, ALP_tblArAlpSiteSys.CentralId, ALP_tblArAlpSiteSys.AlarmId,          
 CASE WHEN LeaseYn = 1 THEN 'Yes' Else 'No' END AS LseYn, ALP_tblArAlpSiteSys.WarrExpires, ALP_tblArAlpRepairPlan.RepPlan,          
 ALP_tblJmSvcTkt.PriceId, ALP_tblArCust_view.AlpJmCustLevel, ALP_tblJmWorkCode.WorkCode, ALP_tblJmTech.[Name] AS TechName,           
 ALP_tblArAlpSite.Directions, ALP_tblJmSvcTkt.WorkDesc, ALP_tblJmTimeCard.StartDate AS SchedDate,          
 ALP_tblJmTimeCard.StartTime AS SchedTime, @CompName AS CompName, @CompAddr AS CompAddr,           
 CASE WHEN OutOfRegYn = 1 THEN 'Out Of Regular' WHEN HolidayYn = 1 THEN 'Holiday' Else 'Regular' END AS LaborRate,          
 ALP_tblJmSvcTkt.InvcNum, ALP_tblJmTech.Tech, ALP_tblArAlpSite.County, ALP_tblArAlpSite.CrossStreet, ALP_tblArAlpSite.MapId,           
        CASE WHEN Structure = 1 THEN 'Ranch' WHEN Structure = 2 THEN 'Two-Level' WHEN Structure = 3 THEN 'Split-Level'           
  WHEN Structure = 4 THEN 'Office' WHEN Structure = 5 THEN 'Warehouse' Else '' END AS Struct,           
 CASE WHEN Basement = 1 THEN 'Full' WHEN Basement = 2 THEN 'Part' WHEN Basement = 3 THEN 'Drop Ceiling'           
  WHEN Basement = 4 THEN 'All Finished' WHEN Basement = 5 THEN 'None' Else '' END AS Bsmt,           
 CASE WHEN Attic = 0 THEN 'None' WHEN Attic = 1 THEN 'Full' WHEN Attic = 2 THEN 'Part'           
  WHEN Attic = 3 THEN 'Small' Else '' END AS Att,           
 [SqFt]*1000 AS SqFoot, ALP_tblArAlpSubdivision.Subdiv, ALP_tblArAlpSite.Block, ALP_tblJmSvcTkt.SalesRepId,           
 ALP_tblJmSvcTkt.OtherComments, ALP_tblJmSvcTkt.Status, ALP_tblArAlpSite.Status AS SiteStatus,          
 CASE WHEN @IncludeComments = 1 THEN OtherComments Else '' END AS Comments,           
 CASE WHEN CreditHold = 1  THEN 'ON HOLD'              
  WHEN coalesce(ALP_tblArCust_view.CurAmtDue, 0) + coalesce(ALP_tblArCust_view.BalAge1, 0)        
   + coalesce(ALP_tblArCust_view.BalAge2, 0) + coalesce(ALP_tblArCust_view.BalAge3, 0)          
+ coalesce(ALP_tblArCust_view.BalAge4, 0) + (coalesce(ALP_tblArCust_view.UnapplCredit, 0) * -1)           
   - coalesce(ALP_tblArCust_view.UnpaidFinch, 0) > 0           
  AND (ALP_tblArCust_view.BalAge1 > 0 Or ALP_tblArCust_view.BalAge2 > 0           
  Or ALP_tblArCust_view.BalAge3 > 0 Or ALP_tblArCust_view.BalAge4 > 0) THEN 'Past Due'          
 Else 'Current' END As CreditStatus    
 ,ALP_tblJmSvcTkt.RecSvcId --Added by NSK on 04 Aug 2016 for bug id 400.
      FROM  ALP_tblJmSvcTkt           
      INNER JOIN ALP_tblJmWorkCode ON ALP_tblJmSvcTkt.WorkCodeId  = ALP_tblJmWorkCode.WorkCodeId          
      INNER JOIN ALP_tblArAlpSite ON ALP_tblJmSvcTkt.SiteId = ALP_tblArAlpSite.SiteId           
      INNER JOIN ALP_tblArCust_view ON ALP_tblJmSvcTkt.CustId = ALP_tblArCust_view.CustId           
      INNER JOIN ALP_tblArAlpSiteSys ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId           
      INNER JOIN ALP_tblArAlpDept ON ALP_tblJmSvcTkt.DeptId = ALP_tblArAlpDept.DeptID           
      LEFT JOIN ALP_tblArAlpRepairPlan ON ALP_tblJmSvcTkt.RepPlanId = ALP_tblArAlpRepairPlan.RepPlanId           
      LEFT JOIN ALP_tblJmTimeCard ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmTimeCard.TicketId           
      Left JOIN ALP_tblJmTech ON ALP_tblJmTech.TechID = ALP_tblJmTimeCard.TechID          
      left JOIN ALP_tblArAlpBranch ON ALP_tblJmTech.BranchId = ALP_tblArAlpBranch.BranchId             
      LEFT  JOIN dbo.ALP_tblArAlpSubdivision ON dbo.ALP_tblArAlpSite.SubDivID = dbo.ALP_tblArAlpSubdivision.SubdivId           
WHERE                 
      (dbo.ALP_tblJmSvcTkt.ProjectID IS  NULL OR dbo.ALP_tblJmSvcTkt.ProjectID = '')           
      AND           
 ((@SchedFrom is not null and @SchedThru is not null and dbo.ALP_tblJmTimeCard.StartDate between  @SchedFrom   And  @SchedThru)          
  OR          
 (@SchedFrom is not null and @SchedThru is  null  and dbo.ALP_tblJmTimeCard.StartDate >=@SchedFrom)          
 OR          
 (@SchedFrom is  null and @SchedThru is not  null and dbo.ALP_tblJmTimeCard.StartDate <=@SchedThru)          
 OR          
 (@SchedFrom is  null and @SchedThru is   null))          
     And          
          
  ( (@TechFrom is not null and @TechThru is not null  and dbo.ALP_tblJmTech.Tech Between @TechFrom and @TechThru)          
 OR          
  (@TechFrom is not  null   and @TechThru is  null and  dbo.ALP_tblJmTech.Tech >= @TechFrom )          
 OR          
  (@TechFrom is  null and @TechThru is not  null  and dbo.ALP_tblJmTech.Tech <= @TechThru)          
 OR          
  (@TechFrom is  null and @TechThru is  null ))          
      AND          
  ( (@BranchFrom is not null and @BranchThru is not null  and dbo.ALP_tblArAlpBranch.Branch Between @BranchFrom and @BranchThru)          
 OR          
      (@BranchFrom is not null and @BranchThru is  null  and dbo.ALP_tblArAlpBranch.Branch >= @BranchFrom)          
 OR          
      (@BranchFrom is  null and @BranchThru is not  null  and dbo.ALP_tblArAlpBranch.Branch <= @BranchThru)          
 OR          
      (@BranchFrom is   null and @BranchThru is   null  ))          
      AND          
  ( (@DeptFrom is not null and @DeptThru is not null  and dbo.ALP_tblArAlpDept.Dept  Between @DeptFrom and @DeptThru)          
 OR          
       (@DeptFrom is not null and @DeptThru is  null  and dbo.ALP_tblArAlpDept.Dept  >= @DeptFrom)          
 OR          
       (@DeptFrom is  null and @DeptThru is not  null  and dbo.ALP_tblArAlpDept.Dept  <= @DeptThru)          
 OR          
       (@DeptFrom is   null and @DeptThru is   null ))          
      AND          
 (@JobStatus is  null  or ALP_tblJmSvcTkt.Status=@JobStatus)          
     AND          
  (@WorkCode is  null  or ALP_tblJmSvcTkt.WorkCodeId=@WorkCode)           
       -- added by NSK on 11/04/2011             
      and           
      ALP_tblJmSvcTkt.Status<>'Closed'           
      and          
      ALP_tblJmSvcTkt.Status<>'Canceled'           
      and           
      ALP_tblJmSvcTkt.Status<>'Completed'   
      -- end by NSK on 11/04/2011          
          
ORDER BY Case WHEN @Order = '1' THEN CONVERT(varchar,dbo.ALP_tblJmTimeCard.StartDate,1)          
 ELSE dbo.ALP_tblJmTech.Tech          
 END,          
 Case WHEN @Order = '1' THEN dbo.ALP_tblJmTech.Tech          
 ELSE CONVERT(varchar,dbo.ALP_tblJmTimeCard.StartDate,1)          
 END,      
 ALP_tblJmTimeCard.StartTime