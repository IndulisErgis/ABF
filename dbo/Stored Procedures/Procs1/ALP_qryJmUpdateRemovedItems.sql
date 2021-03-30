
CREATE PROCEDURE [dbo].[ALP_qryJmUpdateRemovedItems]
@ID int,@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
As
SET NOCOUNT ON
UPDATE ALP_tblArAlpSIteSysItem 
SET ALP_tblArAlpSiteSysItem.RemoveYN = 1, ALP_tblArAlpSiteSysItem.TicketId = @ID,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
FROM ALP_tblJmResolution INNER JOIN (ALP_tblJmSvcTkt INNER JOIN (ALP_tblArAlpSiteSysItem INNER JOIN ALP_tblJmSvcTktItem 
	ON ALP_tblArAlpSiteSysItem.SysItemId = ALP_tblJmSvcTktItem.SysItemId) ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId) 
	ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId 
WHERE ALP_tblJmResolution.[Action] = 'Remove' AND ALP_tblJmSvcTkt.TicketId = @ID