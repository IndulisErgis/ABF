  
Create PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateUnCompletedByOn]   
@Ticketid int  
AS  
Update ALP_tbljmsvctkt set CompletedBy=NULL,CompletedOn=NULL 
where ticketid=@Ticketid