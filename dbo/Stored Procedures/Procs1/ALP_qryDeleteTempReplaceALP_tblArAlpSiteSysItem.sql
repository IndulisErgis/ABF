Create Procedure [dbo].[ALP_qryDeleteTempReplaceALP_tblArAlpSiteSysItem]              
@TicketId int  
As              
              
delete from ALP_tblArAlpReplaceSiteSysItem where TicketId=@TicketId   
  
delete from ALP_tblArAlpReplaceQtySiteSysItem where TicketId=@TicketId