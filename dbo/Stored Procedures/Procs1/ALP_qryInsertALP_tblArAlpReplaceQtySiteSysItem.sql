CREATE Procedure [dbo].[ALP_qryInsertALP_tblArAlpReplaceQtySiteSysItem]          
@SysItemId int,  
@TicketId int,  
@Qty int    
As          
          
insert into ALP_tblArAlpReplaceQtySiteSysItem(SysItemId,SysId,ItemId,[Desc],LocId,PanelYN,SerNum,EquipLoc,  
Qty,UnitCost,WarrPlanId,WarrTerm,WarrStarts,WarrExpires,Comments,RemoveYN,Zone,TicketId,WorkOrderId,  
RepPlanId,LeaseYN,ModifiedBy,ModifiedDate)  
select SysItemId,SysId,ItemId,[Desc],LocId,PanelYN,SerNum,EquipLoc,  
Qty=@Qty,UnitCost,WarrPlanId,WarrTerm,WarrStarts,WarrExpires,Comments,RemoveYN,Zone,TicketId=@TicketId,WorkOrderId,  
RepPlanId,LeaseYN,ModifiedBy,ModifiedDate  
from ALP_tblArAlpSiteSysItem  
where sysItemId=@SysItemId