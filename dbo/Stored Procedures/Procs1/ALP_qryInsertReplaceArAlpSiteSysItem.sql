CREATE Procedure [dbo].[ALP_qryInsertReplaceArAlpSiteSysItem]            
@SysId int,            
@ItemId varchar(24),            
@Desc varchar(255),            
@EquipLoc varchar(30),            
@Qty float,            
@Zone varchar(5),            
@TicketId int,        
@WarrExpires datetime      
,@UnitCost decimal      
,@LocId varchar(10)  
,@SysItemId int out    
As            
            
insert into ALP_tblArAlpSiteSysItem(SysId,ItemId,[Desc],EquipLoc,Qty,Zone,TicketId,WarrExpires,RemoveYN,UnitCost,LocId)            
values(@SysId,@ItemId,@Desc,@EquipLoc,@Qty,@Zone,@TicketId,@WarrExpires,0,@UnitCost,@LocId)   
  
set @SysItemId= SCOPE_IDENTITY();            
SELECT SysItemId FROM ALP_tblArAlpSiteSysItem WHERE SysItemId=@SysItemId