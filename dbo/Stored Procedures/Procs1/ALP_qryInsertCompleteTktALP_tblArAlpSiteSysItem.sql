CREATE Procedure [dbo].[ALP_qryInsertCompleteTktALP_tblArAlpSiteSysItem]                  
@TicketItemId int,       
@SysItemId int         
As                  
      
DECLARE @NewSysItemId int;        
                  
insert into ALP_tblArAlpSiteSysItem(SysId,ItemId,[Desc],LocId,PanelYN,        
SerNum,EquipLoc,          
Qty,UnitCost,WarrPlanId,WarrTerm,WarrStarts,WarrExpires,Comments,RemoveYN,Zone,TicketId,        
WorkOrderId,          
RepPlanId,LeaseYN,ModifiedBy,ModifiedDate)          
select SysId,ItemId,[Desc],LocId,PanelYN,SerNum,EquipLoc,          
Qty,UnitCost,WarrPlanId,WarrTerm,WarrStarts,WarrExpires,Comments,RemoveYN,Zone,TicketId,        
WorkOrderId,          
RepPlanId,LeaseYN,ModifiedBy,ModifiedDate          
from ALP_tblArAlpReplaceSiteSysItem          
where sysItemId=@SysItemId       
    
set @NewSysItemId= SCOPE_IDENTITY();      
    
update ALP_tblJmSvcTktItem set sysItemid=@NewSysItemId where TicketItemid=@TicketItemId  
  
--Added by NSK on 17 Jul 2019 for bug id 915  
--start  
insert into ALP_tblArAlpReplaceCompletedSiteSysItem(SysItemId,SysId,ItemId,[Desc],LocId,PanelYN,        
SerNum,EquipLoc,          
Qty,UnitCost,WarrPlanId,WarrTerm,WarrStarts,WarrExpires,Comments,RemoveYN,Zone,TicketId,        
WorkOrderId,          
RepPlanId,LeaseYN,ModifiedBy,ModifiedDate,TicketItemId)          
select sysItemId=@NewSysItemId ,SysId,ItemId,[Desc],LocId,PanelYN,SerNum,EquipLoc,          
Qty,UnitCost,WarrPlanId,WarrTerm,WarrStarts,WarrExpires,Comments,RemoveYN,Zone,TicketId,        
WorkOrderId,          
RepPlanId,LeaseYN,ModifiedBy,ModifiedDate,@TicketItemId          
from ALP_tblArAlpSiteSysItem          
where sysItemId=@NewSysItemId   
--end  