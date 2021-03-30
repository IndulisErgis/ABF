
CREATE PROCEDURE dbo.ALP_stpJmTrackingTurnoverDetail_sp
-- EFI# 1713 MAH - additional filter parameters
	(
	@ExcludeTurnoversYN  char(1) = 'Y',
	@SalesRepID varchar(10) = '*',
	@StartDate varchar(10) = '*',
	@ExcludeClosedJobsYN varchar(1) = 'Y',
	@ShowOnlyCsConnectJobs  varchar(1) = 'Y'
	)

 AS
SET NOCOUNT ON  
DECLARE @UseDate bit 
DECLARE @dtStartDate datetime
IF @StartDate = '*'
BEGIN
	SET @UseDate = 0
	SET @dtStartDate = GetDate()
END
ELSE
BEGIN
	SET @UseDate = 1
	SET @dtStartDate = convert(datetime,@StartDate)
END
SELECT ALP_tblJmSvcTkt.TicketId, 
ALP_tblJmSvcTkt.ProjectId, 
ALP_tblJmSvcTkt.SiteId, 
Site = (dbo.ufxAlpFullName(ALP_tblArAlpSite.AlpFirstName,ALP_tblArAlpSite.SiteName)
+ '    ' + [ALP_tblArAlpSite].[Addr1] + ',  ' + [ALP_tblArAlpSite].[City] ), 
ALP_tblJmSvcTkt.CreateDate,
ALP_tblJmSvcTkt.PrefDate, 
ALP_tblJmSvcTkt.Status,
ALP_tblJmWorkCode.WorkCode, 
ALP_tblJmWorkCode.NewWorkYN, 
ALP_tblJmSvcTkt.SalesRepId, 
ALP_tblJmTech.Tech, 
ALP_tblJmSvcTkt.CompleteDate, 
ALP_tblJmSvcTkt.CsConnectYn, 
ALP_tblJmSvcTkt.ToSchDate, 
ALP_tblJmSvcTkt.TurnoverDate
FROM ALP_tblJmTech 
	--EFI# 1262 mah 11/12/03 - exclude cancelled jobs and do not require that a Lead Tech be entered in the job record
	RIGHT OUTER  JOIN (ALP_tblJmWorkCode
		 INNER JOIN (ALP_tblArAlpSite 
			INNER JOIN ALP_tblJmSvcTkt 
				ON ALP_tblArAlpSite.SiteId = ALP_tblJmSvcTkt.SiteId) 
		ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId) 
	ON ALP_tblJmTech.TechID = ALP_tblJmSvcTkt.LeadTechId
WHERE (ALP_tblJmSvcTkt.ProjectId Is Not Null)
	AND
	(ALP_tblJmSvcTkt.Status NOT LIKE 'Canc%')
	AND
	(
		(@SalesRepId = '*')
		OR
		(@SalesRepId <> '*' AND ALP_tblJmSvcTkt.SalesRepId = @SalesRepId)
	)
	AND
	(
		(@UseDate = 0)
		OR
		((@UseDate <> 0 ) AND (ALP_tblJmSvcTkt.CompleteDate < = @dtStartDate))
	)
	AND
	( 
		(@ExcludeClosedJobsYN = 'N')
		OR
		(@ExcludeClosedJobsYN <> 'N' AND ALP_tblJmSvcTkt.Status <> 'Closed')
	)
	AND
	(
		(@ShowOnlyCsConnectJobs <> 'Y')
		OR
		(@ShowOnlyCsConnectJobs = 'Y' AND ALP_tblJmSvcTkt.CsConnectYN <> 0)
	)
	AND
	(
		(@ExcludeTurnoversYN = 'N')
		OR
		((@ExcludeTurnoversYN <> 'N') AND (ALP_tblJmSvcTkt.TurnoverDate Is Null))
	)

ORDER BY ALP_tblJmSvcTkt.CompleteDate;