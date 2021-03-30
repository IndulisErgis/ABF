
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateSysWarrExpires]
@ID int,@ModifiedBy varchar(16)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSys 
SET ALP_tblArAlpSiteSys.WarrExpires = 
	CASE WHEN WarrTerm = 0 THEN InstallDate 
	ELSE DateAdd(month,[WarrTerm],[InstallDate])
	END,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblArAlpSiteSys RIGHT JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId 
WHERE ALP_tblArAlpSiteSys.WarrExpires Is Null AND ALP_tblJmSvcTkt.TicketId = @ID