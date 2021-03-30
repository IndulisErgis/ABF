
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateContact]	
@Contact varchar(25),
@TicketId int,
--Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@RevisedBy varchar(50)=null,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)


AS
Update ALP_tbljmsvctkt set Contact=@Contact,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101),ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE() where ticketid=@TicketId