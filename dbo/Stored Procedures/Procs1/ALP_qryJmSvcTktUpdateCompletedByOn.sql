  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateCompletedByOn]   
@Ticketid int,  
@CompletedBy varchar(16)  
  
AS  
Update ALP_tbljmsvctkt set CompletedBy=@CompletedBy,CompletedOn=CONVERT(VARCHAR(10),GETDATE(),101) 
where ticketid=@Ticketid