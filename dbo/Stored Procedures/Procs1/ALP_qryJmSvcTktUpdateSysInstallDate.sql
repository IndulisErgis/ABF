
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateSysInstallDate]
@ID int, @IDate datetime, @Term int,@ModifiedBy varchar(16)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSys 
SET ALP_tblArAlpSiteSys.InstallDate = @IDate, ALP_tblArAlpSiteSys.WarrTerm = @Term,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblArAlpSiteSys INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId 
WHERE ALP_tblArAlpSiteSys.InstallDate Is Null AND ALP_tblJmSvcTkt.TicketId = @ID