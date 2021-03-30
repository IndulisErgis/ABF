CREATE Procedure [dbo].[ALP_qryUpdateJmSvcTktServiceItem]        
@TicketItemId int,        
@SysItemId int   
As        
Update ALP_tblJmSvcTktServiceItem set SysItemId=@SysItemId   
where TicketItemId=@TicketItemId