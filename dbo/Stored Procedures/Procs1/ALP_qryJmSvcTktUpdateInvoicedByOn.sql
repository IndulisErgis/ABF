    
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateInvoicedByOn]     
@Ticketid int,    
@InvoicedBy varchar(16)    
    
AS    
Update ALP_tbljmsvctkt set InvoicedBy=@InvoicedBy   
where ticketid=@Ticketid