Create PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateInvCommittedAddItems]                   
@TicketItemId varchar(20)                       
,@HoldInvCommitted bit     
AS                 
update ALP_tblJmSvcTktItem set HoldInvCommitted=@HoldInvCommitted    
where LineNumber like '%' + @TicketItemId + '%'