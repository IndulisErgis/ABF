
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateLineNumber]	
@LineNumber varchar(50),
@TicketItemId int,@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 

AS
update ALP_tblJmSvcTktItem set LineNumber=@LineNumber,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE() where ticketitemid=@TicketItemId