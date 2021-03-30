
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktDelete]	
@TicketId int
AS
Delete ALP_tblJmSvcTkt  where TicketId=@TicketId