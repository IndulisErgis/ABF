CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktRemoveAllEquipList]
@ID int,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSysItem 
SET ALP_tblArAlpSiteSysItem.RemoveYN = 1,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblJmWorkCode INNER JOIN (ALP_tblArAlpSiteSysItem INNER JOIN ALP_tblJmSvcTkt ON ALP_tblArAlpSiteSysItem.SysId = ALP_tblJmSvcTkt.SysId) 
	ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId 
WHERE ALP_tblJmWorkCode.PullSystemYn = 1 AND ALP_tblJmSvcTkt.TicketId = @ID