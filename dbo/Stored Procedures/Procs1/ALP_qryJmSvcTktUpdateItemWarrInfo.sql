
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateItemWarrInfo]
@ID int, @Term int, @WDate datetime,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSysItem 
SET ALP_tblArAlpSiteSysItem.WarrStarts = @WDate, ALP_tblArAlpSiteSysItem.WarrTerm = @Term, ALP_tblArAlpSiteSysItem.WarrExpires = DateAdd(month,@Term,@WDate)
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblJmResolution INNER JOIN (((ALP_tblArAlpSiteSys INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId) 
	INNER JOIN ALP_tblArAlpSiteSysItem ON (ALP_tblArAlpSiteSys.SysId = ALP_tblArAlpSiteSysItem.SysId) AND (ALP_tblJmSvcTkt.TicketId = ALP_tblArAlpSiteSysItem.TicketId)) 
	INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId) ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId 
WHERE ALP_tblJmSvcTktItem.TicketId = @ID AND (ALP_tblJmResolution.[Action] = 'Add' Or ALP_tblJmResolution.[Action]='Replace')