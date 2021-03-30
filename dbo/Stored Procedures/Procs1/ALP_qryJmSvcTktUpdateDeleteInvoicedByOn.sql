    
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateDeleteInvoicedByOn]     
@Ticketid int    
AS    
Update ALP_tbljmsvctkt set InvoicedBy=NULL   
where ticketid=@Ticketid