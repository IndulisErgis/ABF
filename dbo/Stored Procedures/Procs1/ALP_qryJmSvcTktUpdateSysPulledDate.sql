
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateSysPulledDate]
@ID int, @PDate datetime,@ModifiedBy varchar(16)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSys 
SET ALP_tblArAlpSiteSys.PulledDate = @PDate,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblJmWorkCode INNER JOIN (ALP_tblArAlpSiteSys INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId) 
	ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId 
WHERE ALP_tblArAlpSiteSys.PulledDate Is Null AND ALP_tblJmSvcTkt.TicketId = @ID AND ALP_tblJmWorkCode.PullSystemYn =1