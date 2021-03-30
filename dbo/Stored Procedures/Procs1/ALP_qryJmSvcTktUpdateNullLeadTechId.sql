
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateNullLeadTechId]	
@TicketId int,
@RevisedBy varchar(20)=null,@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 

AS
Update ALP_tbljmsvctkt set LeadTechId=null,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101),ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where ticketid=@TicketId