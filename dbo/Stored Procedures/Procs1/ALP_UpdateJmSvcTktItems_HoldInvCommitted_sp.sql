          
Create PROCEDURE ALP_UpdateJmSvcTktItems_HoldInvCommitted_sp          
(          
 @TicketItemID int = 0,   
 @HoldInvCommitted bit       
)          
AS          
Update ALP_tblJmSvcTktItem  
set  HoldInvCommitted=@HoldInvCommitted  
where TicketItemID =@TicketItemID