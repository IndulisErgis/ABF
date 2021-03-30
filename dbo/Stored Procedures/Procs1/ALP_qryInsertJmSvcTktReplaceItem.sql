CREATE Procedure [dbo].[ALP_qryInsertJmSvcTktReplaceItem]      
@TicketItemId int,      
@OriginalSysItemId int,  
@OriginalItemQty float,  
@OriginalUom varchar(5),
@OriginalEquipLoc varchar(30),
@OriginalZone varchar(5)  
As      
      
insert into ALP_tblJmSvcTktReplaceItem(TicketItemId,OriginalSysItemId,OriginalItemQty,OriginalUom,OriginalEquipLoc,OriginalZone)      
values(@TicketItemId,@OriginalSysItemId,@OriginalItemQty,@OriginalUom,@OriginalEquipLoc,@OriginalZone)