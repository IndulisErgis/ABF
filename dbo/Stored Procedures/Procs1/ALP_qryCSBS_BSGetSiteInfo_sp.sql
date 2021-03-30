CREATE Procedure [dbo].[ALP_qryCSBS_BSGetSiteInfo_sp]
--EFI# 1416 MAH 042904 - return only site last name ( for compare against CS site name )
-- SRP added a clause to check pulleddate on 06/08/2020 to fix Customer number mismatch issue in report generated on CS interface
-- SRP added a clause to check status on 06/09/2020 to fix Site name mismatch and Site address mismatch issue in report generated on CS interface
	(
	@Transmitter varchar(36) = ''
	)
As
	set nocount on
	SELECT
		SS.AlarmId AS Transmitter,
		SS.CustId,
		SS.SiteId,
		SS.SysID,
--EFI# 1416 MAH 042904:
		[Name] =  S.SiteName,
--		[Name] = CASE 
--			   WHEN S.AlpFirstName IS NULL Then S.SiteName
--			   ELSE S.AlpFirstName + ' ' + S.SiteName
--			END,
		S.Addr1
	FROM ALP_tblArAlpSite S(NOLOCK)
		INNER JOIN ALP_tblArAlpSiteSys SS(NOLOCK)
		ON S.SiteID = SS.SiteID
	WHERE SS.AlarmID = @Transmitter 
		and PulledDate is null -- added this line on 06/08/2020
		and status <> 'Inactive' -- added this line on 06/09/2020
	return