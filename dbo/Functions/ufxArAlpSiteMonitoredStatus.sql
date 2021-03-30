CREATE FUNCTION [dbo].[ufxArAlpSiteMonitoredStatus]
/* created 08/19/04 EFI 1469  MAH					*/
/* 	- determines the monitoring status of a site:			*/
/*	'Local' = system installed, but not monitored,			*/
/*	'Monitored' = system installed, w/ new or active monitoring service(s)*/	
/*  	' '(blank) = n/a							*/		
(
	@SiteId int = null
)
RETURNS varchar(20)
AS
begin
DECLARE @Status varchar(20)
SET @Status = ' '	--default status
IF exists (
	SELECT SS.SiteId
	FROM dbo.ALP_tblArAlpSiteSys SS 
	INNER JOIN dbo.ALP_tblArAlpSite S 
	ON SS.SiteId = S.SiteId
	WHERE (SS.SiteID = @SiteID ) and 
		(SS.PulledDate IS NULL) AND (SS.InstallDate IS NOT NULL)
	   )
	BEGIN
	SET @Status = 'Local'	--System installed, but not monitored
	IF exists (
		--Look for at least one recurring service with service type = 4
		SELECT  RB.SiteId
		FROM    dbo.ALP_tblArAlpSiteRecBill RB
			INNER JOIN  dbo.ALP_tblArAlpSiteRecBillServ RBS
			ON RB.RecBillId = RBS.RecBillId
		WHERE   (RB.SiteID = @SiteID ) and RBS.ServiceType = 4 
			and ((RBS.Status = 'Active') OR(RBS.Status = 'New'))
			
		)
		BEGIN
		SET @Status = 'Monitored '	--System installed, with monitoring services 
		END
	END
RETURN @Status
end