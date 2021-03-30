CREATE Procedure [dbo].[ALP_qryJmSvcTktItem_Delete_sp]  
@ID int  
AS  
--Below sen nocount on code commentted by ravi on 11 nov 2017
--SET NOCOUNT ON  
DELETE dbo.ALP_tblJmSvcTktItem  
WHERE ALP_tblJmSvcTktItem.TicketItemId= @ID