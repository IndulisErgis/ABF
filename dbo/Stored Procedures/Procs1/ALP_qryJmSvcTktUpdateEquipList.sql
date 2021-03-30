

CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateEquipList]
@ID int,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSysItem
SET ALP_tblArAlpSiteSysItem.WarrStarts = 
	CASE WHEN WarrStarts Is Null THEN InstallDate
	ELSE WarrStarts
	END, 
	ALP_tblArAlpSiteSysItem.WarrTerm = [ALP_tblArAlpSiteSys].[WarrTerm], ALP_tblArAlpSiteSysItem.WarrExpires = [ALP_tblArAlpSIteSys].[WarrExpires]
	,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM (ALP_tblArAlpSiteSys INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSys.SysId = ALP_tblJmSvcTkt.SysId) 
	INNER JOIN ALP_tblArAlpSiteSysItem ON ALP_tblArAlpSiteSys.SysId = ALP_tblArAlpSiteSysItem.SysId 
WHERE ALP_tblJmSvcTkt.TicketId = @ID