
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateSysWarrTerm]
@ID int,@ModifiedBy varchar(16)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSys 
SET ALP_tblArAlpSiteSys.WarrTerm = 0,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblArAlpSiteSys INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId 
WHERE ALP_tblArAlpSiteSys.WarrTerm Is Null AND ALP_tblJmSvcTkt.TicketId = @ID