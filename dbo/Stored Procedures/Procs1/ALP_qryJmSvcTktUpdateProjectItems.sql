
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateProjectItems]
@ID varchar(10), @TktID int, @Sys int,@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSysItem
SET ALP_tblArAlpSiteSysItem.WarrStarts = [InstallDate], ALP_tblArAlpSiteSysItem.WarrTerm = [ALP_tblArAlpSiteSys].[WarrTerm], 
	ALP_tblArAlpSiteSysItem.WarrExpires = [ALP_tblArAlpSiteSys].[WarrExpires],ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM (ALP_tblArAlpSiteSysItem INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSysItem.TicketId = ALP_tblJmSvcTkt.TicketId) 
	INNER JOIN ALP_tblArAlpSiteSys ON (ALP_tblArAlpSiteSys.SysId = ALP_tblArAlpSiteSysItem.SysId) AND (ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId) 
WHERE ALP_tblArAlpSiteSysItem.WarrStarts Is Null AND ALP_tblJmSvcTkt.ProjectId = @ID And ALP_tblJmSvcTkt.ProjectId Is Not Null 
	AND ALP_tblJmSvcTkt.TicketId <> @TktID AND ALP_tblJmSvcTkt.SysId = @Sys