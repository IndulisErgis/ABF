
CREATE PROCEDURE dbo.ALP_qryJmSvcTktGetSysInstallDate
@ID int
As
SET NOCOUNT ON
SELECT ALP_tblJmSvcTkt.TicketId, ALP_tblArAlpSiteSys.InstallDate
FROM ALP_tblArAlpSiteSys INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId
WHERE ALP_tblJmSvcTkt.TicketId = @ID AND ALP_tblArAlpSiteSys.InstallDate Is Null