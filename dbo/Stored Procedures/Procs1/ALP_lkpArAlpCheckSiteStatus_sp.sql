

CREATE PROCEDURE dbo.ALP_lkpArAlpCheckSiteStatus_sp 
/*  EFI 1469 MAH 08/19/04 - created sproc        */
	(
	@SiteId int, 
	@Status varchar(20)  OUTPUT
	)
AS
SET NOCOUNT ON
SET @Status = (select dbo.ALP_ufxArAlpSiteStatus( @SiteId ))