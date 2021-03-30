CREATE Procedure [dbo].[ALP_qryUpdateJmSvcTktReplaceItem]        
@TicketItemId int,        
@OriginalSysItemId int,    
@OriginalItemQty float,  
@OriginalUom varchar(5),
@OriginalEquipLoc varchar(30),
@OriginalZone varchar(5)   
As        
Update ALP_tblJmSvcTktReplaceItem set OriginalSysItemId=@OriginalSysItemId,    
OriginalItemQty=@OriginalItemQty,OriginalUom=@OriginalUom,
OriginalEquipLoc=@OriginalEquipLoc,OriginalZone=@OriginalZone
where TicketItemId=@TicketItemId