          
Create PROCEDURE dbo.ALP_UpdateJmSvcTktOnHoldInvCommitFromProject       
(          
 @TicketId int, 
 @HoldInvCommitted bit 
 )          
AS    
Update ALP_tblJmSvcTkt 
set  HoldInvCommitted=@HoldInvCommitted  
where TicketId=@TicketId