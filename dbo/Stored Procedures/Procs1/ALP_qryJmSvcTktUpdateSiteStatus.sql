
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateSiteStatus]
@ID int, @sStatus varchar(10),@ModifiedBy varchar(16)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSite SET ALP_tblArAlpSite.Status = @sStatus,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
WHERE ALP_tblArAlpSite.SiteId = @ID