
CREATE PROCEDURE [dbo].[ALP_qryJmUpdateWarrExpires]
@ID int, @DateClosed datetime,@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
As
SET NOCOUNT ON
UPDATE ALP_tblJmSvcTktItem 
SET ALP_tblJmSvcTktItem.WarrExpDate = 
	CASE WHEN WarrExpires Is Null THEN DateAdd(month, WarrTerm, @DateClosed)
	ELSE WarrExpires
	END,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblJmResolution INNER JOIN ((ALP_tblArAlpSiteSys INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId) 
	INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId) ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId 
WHERE ALP_tblJmSvcTktItem.WarrExpDate Is Null AND ALP_tblJmSvcTktItem.TicketId = @ID AND ALP_tblJmResolution.[Action] ='Add'