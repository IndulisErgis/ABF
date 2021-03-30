CREATE Procedure [dbo].[ALP_qryJm110i00SvcHistory_sp]      
/* RecordSource for Job History subform of Control Center */      
 (      
  @SiteID int = null      
 )      
As      
set nocount on 
 declare @Today as date
 set @Today = GetDate()

--mah 12/8/15 - add Latest Time Card info to the result set
SELECT dbo.ALP_tblJmSvcTkt.TicketId,
	MAX(CASE WHEN dbo.ALP_tblJmTimeCard.EndDate < @Today THEN dbo.ALP_tblJmTimeCard.EndDate ELSE NULL END) AS LastVisit,   
	MIN(CASE WHEN dbo.ALP_tblJmTimeCard.EndDate >= @Today THEN dbo.ALP_tblJmTimeCard.EndDate ELSE NULL END) AS NextSchedDate,
	dbo.ALP_ufxJmLastTech( dbo.ALP_tblJmSvcTkt.TicketId) AS LastTech
	INTO #ScheduledDate
FROM dbo.ALP_tblJmSvcTkt INNER JOIN dbo.ALP_tblJmTimeCard ON dbo.ALP_tblJmSvcTkt.TicketId = dbo.ALP_tblJmTimeCard.TicketId
WHERE dbo.ALP_tblJmSvcTkt.SiteID = @SiteID
GROUP BY dbo.ALP_tblJmSvcTkt.TicketId

--mah 12/8/15 - added Scheduled Date column to output      
SELECT ALP_tblJmSvcTkt.SiteId, ALP_tblJmSvcTkt.TicketId, ALP_tblJmSvcTkt.ProjectId,       
 ALP_tblJmMarketCode.MarketCode, ALP_tblJmSvcTkt.Status,       
 ALP_tblJmSvcTkt.SysId,       
 ALP_tblJmTech.Tech, ALP_tblJmWorkCode.WorkCode, ALP_tblJmSvcTkt.WorkDesc,
 --Below order date modified by NSK on 13 Oct 2015 to display only date
  --ALP_tblJmSvcTkt.OrderDate, 
  Convert(Date, ALP_tblJmSvcTkt.OrderDate) as OrderDate,
  ALP_tblArAlpSiteSys.SysDesc, ALP_tblArAlpSiteSys.AlarmId      
 -- Below custid added by NSK on 10 Apr 2015  
 ,ALP_tblJmSvcTkt.CustId
 --mah 12/8/15 - added:
 --mah TEST for JCP on 3/25/16:
 --begin
 --,CAST(#ScheduledDate.NextSchedDate  AS DATE) as SchedDate
 ,CASE WHEN #ScheduledDate.NextSchedDate IS NULL THEN CAST(#ScheduledDate.LastVisit  AS DATE) 
 WHEN #ScheduledDate.NextSchedDate = '' THEN CAST(#ScheduledDate.LastVisit  AS DATE)
 ELSE CAST(#ScheduledDate.NextSchedDate  AS DATE) END as SchedDate
 --end
 ,CAST(#ScheduledDate.LastVisit  AS DATE) as LastVisit
 ,CAST(#ScheduledDate.NextSchedDate  AS DATE) as NextVisit
 --added by mah 05/20/16:
 ,#ScheduledDate.LastTech AS LastTech
FROM ALP_tblJmTech      
 RIGHT JOIN (ALP_tblJmWorkCode       
  RIGHT JOIN ((ALP_tblJmSvcTkt       
   INNER JOIN ALP_tblArAlpSiteSys       
                         ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId      
   LEFT JOIN ALP_tblJmSvcTktProject       
    ON ALP_tblJmSvcTkt.ProjectId = ALP_tblJmSvcTktProject.ProjectId)       
   LEFT JOIN ALP_tblJmMarketCode       
    ON ALP_tblJmSvcTktProject.MarketCodeId = ALP_tblJmMarketCode.MarketCodeId
    LEFT JOIN #ScheduledDate ON ALP_tblJmSvcTkt.TicketID = #ScheduledDate.TicketID)       
  ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId)       
 ON ALP_tblJmTech.TechID = ALP_tblJmSvcTkt.LeadTechId      
WHERE ALP_tblJmSvcTkt.SiteId = @SiteID      
--Order by replaced by Orderdate from ticketid on 16 mar 2015 by NSK    
ORDER BY OrderDate DESC, TicketId DESC;   --ALP_tblJmSvcTkt.OrderDate replaced by OrderDate on 13 Oct 2015  
return