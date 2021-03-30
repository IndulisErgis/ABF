

CREATE PROCEDURE [dbo].[ALP_qryJM110_JobDataForScheduler_sp] 
	(
	@TicketId int = 0
	)
AS
SELECT     ALP_tblJmSvcTkt.TicketId, ALP_tblJmSvcTkt.Status, ALP_tblJmSvcTkt.SiteId, ALP_tblArAlpSite.SiteName, ALP_tblArAlpSite.AlpFirstName, ALP_tblArAlpSite.Addr1, ALP_tblArAlpSite.Addr2, 
                      ALP_tblArAlpSite.City, ALP_tblArAlpSysType.SysType, ALP_tblArAlpSiteSys.SysDesc, ALP_tblJmSvcTkt.EstHrs, ALP_tblArAlpSiteSys.AlarmId, ALP_tblArAlpSite.PostalCode, 
                      ALP_tblJmSvcTkt.WorkDesc, ALP_tblJmSvcTkt.CustId, ALP_tblJmSvcTkt.ContactPhone, ALP_tblArAlpRepairPlan.[Desc] as RepairPlan, ALP_tblJmSvcTkt.SalesRepId
FROM         ALP_tblJmSvcTkt INNER JOIN
                      ALP_tblArAlpSite ON ALP_tblJmSvcTkt.SiteId = ALP_tblArAlpSite.SiteId INNER JOIN
                      ALP_tblArAlpSiteSys ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId INNER JOIN
                      ALP_tblArAlpSysType ON ALP_tblArAlpSiteSys.SysTypeId = ALP_tblArAlpSysType.SysTypeId LEFT OUTER JOIN
                      ALP_tblArAlpRepairPlan ON ALP_tblJmSvcTkt.RepPlanId = ALP_tblArAlpRepairPlan.RepPlanId
WHERE     (ALP_tblJmSvcTkt.TicketId = @TicketId)