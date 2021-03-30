          
Create PROCEDURE ALP_UpdateJmSvcTktItems_InvCommitted_sp          
(          
 @TicketID int = 0          
)          
AS          
Update ALP_tblJmSvcTktItem  
set  HoldInvCommitted=0  
where TicketID=@TicketID