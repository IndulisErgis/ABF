  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateRecurJobBillableStatus]   
--Created for bug id 400 by NSK on 01 Aug 2016  
@CreateBy varchar(50),  
@Ticketid int 
--MAH 05/02/2017 - increased size of the CreateBy parameter, from 20 to 50  
  
AS  
update dbo.ALP_tblJmSvcTkt set CreateBy =@CreateBy  
where TicketId=@Ticketid