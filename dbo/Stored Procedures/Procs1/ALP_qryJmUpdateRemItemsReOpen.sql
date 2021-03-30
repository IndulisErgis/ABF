
CREATE Procedure [dbo].[ALP_qryJmUpdateRemItemsReOpen]
	@ID int,@ModifiedBy varchar(16)
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
AS
SET NOCOUNT ON
UPDATE ALP_tblArAlpSiteSysItem 
SET ALP_tblArAlpSiteSysItem.RemoveYN = 0,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
WHERE ALP_tblArAlpSiteSysItem.RemoveYN = 1 AND ALP_tblArAlpSiteSysItem.TicketId = @ID