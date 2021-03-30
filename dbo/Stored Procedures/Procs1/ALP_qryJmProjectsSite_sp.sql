

CREATE PROCEDURE dbo.ALP_qryJmProjectsSite_sp
--Created 11/07/04 MAH for EFI# 1532
	(
	@ProjectID varchar(10),
	@SiteID int = 0 OUTPUT	
	)
AS
Set NOCOUNT on
SET @SiteID = 0
IF EXISTS 
	(SELECT SiteID FROM ALP_tblJmSvcTktProject WHERE ProjectID=@ProjectID)
BEGIN
	SET @SiteID = (SELECT SiteID FROM ALP_tblJmSvcTktProject WHERE ProjectID=@ProjectID)
END