

CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateOrderDate]	
@TicketId int,@OrderDate datetime,
@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 

AS
Update ALP_tblJmSvcTkt set OrderDate=@OrderDate
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where ticketid=@TicketId