CREATE Procedure [dbo].[ALP_qryInsertJmSvcTktServiceItem]        
@TicketItemId int,        
@SysItemId int   
As        
insert into ALP_tblJmSvcTktServiceItem(TicketItemId,SysItemId)        
values(@TicketItemId,@SysItemId)