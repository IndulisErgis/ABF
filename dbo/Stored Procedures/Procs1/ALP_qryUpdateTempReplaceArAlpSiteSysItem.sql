    
CREATE Procedure [dbo].[ALP_qryUpdateTempReplaceArAlpSiteSysItem]    
@SysItemId int,        
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
As                
        
Update ALP_tblArAlpReplaceSiteSysItem    
set SysId=@SysId,ItemId=@ItemId,[Desc]=@Desc,EquipLoc=@EquipLoc,Qty=@Qty,Zone=@Zone,TicketId=@TicketId,WarrExpires=@WarrExpires    
,UnitCost=@UnitCost,LocId=@LocId    
where SysItemId=@SysItemId