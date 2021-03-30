    
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateCompletedNonPartsPulledDate]     
@TicketItemid int,    
@ModifiedBy varchar(50),  
@PartPulledDate datetime=null  
    
AS    
Update ALP_tbljmsvctktItem set PartPulledDate=@PartPulledDate,  
ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()    
where ticketItemid=@TicketItemid