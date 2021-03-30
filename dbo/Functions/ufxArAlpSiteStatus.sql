CREATE FUNCTION dbo.ufxArAlpSiteStatus
/* created 08/19/04 EFI 1469  MAH				*/
/* 	- determines the status of a site			*/
/*	- used in code and sprocs to update the site status	*/
--MAH 07/11/06 - bypass expired and cancelled services when checking for pending items.
(
	@SiteId int = null
)
RETURNS varchar(20)
AS
begin
DECLARE @Status varchar(20)
SET @Status = (SELECT Status FROM dbo.tblArAlpSite WHERE @SiteId = dbo.tblArAlpSite.SiteId)
If @Status <> 'Prospect' and @Status <> 'Dead'
	BEGIN
	SET @Status = 'Inactive'
	IF exists (
		--Look for at least one recurring service without a start date
		SELECT  RB.SiteId, RBS.ServiceStartDate, RBS.Status
		FROM    dbo.tblArAlpSiteRecBill RB
			INNER JOIN  dbo.tblArAlpSiteRecBillServ RBS
			ON RB.RecBillId = RBS.RecBillId
		WHERE   (RBS.ServiceStartDate IS NULL and RBS.Status <> 'Expired' and RBS.Status <> 'Cancelled') and (RB.SiteID = @SiteID )
		)
		BEGIN
		SET @Status = 'Pending'
		END
	If exists (
		--are there any recurring services that are active ( have start dates )
		SELECT  RB.SiteId, RBS.ServiceStartDate, RBS.Status
		FROM    dbo.tblArAlpSiteRecBill RB
		INNER JOIN  dbo.tblArAlpSiteRecBillServ RBS
		ON RB.RecBillId = RBS.RecBillId
		WHERE   (NOT (RBS.ServiceStartDate IS NULL)) 
		AND 
		((RBS.Status = 'Active') OR(RBS.Status = 'New'))
		AND (RB.SiteID = @SiteID )
		)
		BEGIN
		SET @Status = 'Active'
		END
	END
RETURN @Status
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxArAlpSiteStatus] TO PUBLIC
    AS [dbo];

