
Create PROCEDURE [dbo].[Alp_qryJmSvcTktInsertCurrentUser]     
 @TicketID int,
 @UserId varchar(50),
 @TicketOpenTime datetime
As    
SET NOCOUNT ON    
insert into    
ALP_tblJmSvcTktCurrentUsers (TicketId,UserId,TicketOpenTime)
Values (@TicketID,@UserId,@TicketOpenTime)