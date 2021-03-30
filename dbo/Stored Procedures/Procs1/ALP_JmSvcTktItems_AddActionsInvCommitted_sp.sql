          
CREATE PROCEDURE ALP_JmSvcTktItems_AddActionsInvCommitted_sp          
(          
 @TicketID int = 0          
)          
AS          
select HoldInvCommitted from ALP_tblJmSvcTktItem   
where TicketID=@TicketID and HoldInvCommitted=1