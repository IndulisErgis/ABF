
CREATE  Procedure [dbo].[ALP_qryDeleteJmSvcTktReplaceItem]    
@TicketItemId int   
As    
Delete from ALP_tblJmSvcTktReplaceItem
where TicketItemId=@TicketItemId