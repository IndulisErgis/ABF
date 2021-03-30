
Create PROCEDURE [dbo].[ALP_qryJmGetExistingTimeBars]
@StartDate datetime,
@EndDate datetime
--MAH 07/27/12 - default TicketID and SiteID to 0 if null ( non job-related time bar )
AS
SELECT Tech.Tech, TC.TimeCardID, TC.TechID, convert(varchar(10),TC.StartDate,101) StartDate, convert(varchar(10),
TC.EndDate,101) EndDate , TC.StartTime, TC.EndTime, TC.TimeCodeID,
--TC.TicketId,
TicketID = CASE WHEN TC.TicketId is NULL THEN 0 ELSE TC.TicketId END,
TCD.TimeCode,TC.LockedYN,TC.TimeCardComment,
--Tkt.SiteId,
SiteID = CASE WHEN Tkt.SiteId is NULL THEN 0 ELSE Tkt.SiteId END,
Tkt.Status, Tkt.ContactPhone,Tkt.WorkDesc, Tkt.CustId, Tkt.EstHrs, Tkt.SalesRepId, Site.SiteName, Site.AlpFirstName, Site.Addr1,
Site.Addr2, Site.City, Site.PostalCode, SiteSys.SysDesc, SiteSys.AlarmId, SiteSysType.SysType, RP.[Desc] AS RepairPlan
FROM ALP_tblArAlpRepairPlan RP INNER JOIN ALP_tblArAlpSite Site INNER JOIN
ALP_tblJmSvcTkt Tkt ON Site.SiteId = Tkt.SiteId ON RP.RepPlanId = Tkt.RepPlanId INNER JOIN
ALP_tblArAlpSysType SiteSysType INNER JOIN ALP_tblArAlpSiteSys SiteSys ON SiteSysType.SysTypeId = SiteSys.SysTypeId ON Tkt.SysId = SiteSys.SysId RIGHT OUTER JOIN
ALP_tblJmTimeCard TC INNER JOIN ALP_tblJmTech Tech ON TC.TechID = Tech.TechId INNER JOIN
ALP_tblJmTimeCode TCD ON TC.TimeCodeID = TCD.TimeCodeID ON Tkt.TicketId = TC.TicketId
where (TC.StartDate >= CONVERT(DATETIME, @StartDate, 101) and TC.EndDate <= CONVERT(DATETIME,@EndDate, 101)) or
(TC.StartDate between CONVERT(DATETIME, @StartDate, 101) and CONVERT(DATETIME, @EndDate, 101)) or
(TC.EndDate between CONVERT(DATETIME, @StartDate, 101) and CONVERT(DATETIME, @EndDate, 101))
ORDER BY TC.TimeCardID