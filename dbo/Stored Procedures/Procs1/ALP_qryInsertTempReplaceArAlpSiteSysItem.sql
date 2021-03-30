CREATE Procedure [dbo].[ALP_qryInsertTempReplaceArAlpSiteSysItem]                
@SysItemId varchar(30) out,                            
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
,@RepSysItemId int  =0                
As                              
                              
insert into ALP_tblArAlpReplaceSiteSysItem          
(SysId,ItemId,[Desc],EquipLoc,Qty,Zone,TicketId,WarrExpires,RemoveYN,UnitCost,LocId)                              
values(@SysId,@ItemId,@Desc,@EquipLoc,@Qty,@Zone,@TicketId,@WarrExpires,0,@UnitCost,@LocId)                   
               
set @RepSysItemId= SCOPE_IDENTITY();               
                        
--Prefix 1000000 commented and added 1000 by NSK on 17 Jun 2020 for length issue                        
Update ALP_tblArAlpReplaceSiteSysItem           
--set SysItemId= CAST(CAST('1000000' AS VARCHAR(24)) +  CAST(@RepSysItemId AS VARCHAR(12)) AS varchar(24))              
set SysItemId= CAST(CAST('1000' AS VARCHAR(24)) +  CAST(@RepSysItemId AS VARCHAR(12)) AS varchar(24))          
WHERE RepSysItemId =@RepSysItemId                   
              
--set @SysItemId= CAST(CAST('1000000' AS VARCHAR(24)) +  CAST(@RepSysItemId AS VARCHAR(12)) AS varchar(24));                 
set @SysItemId= CAST(CAST('1000' AS VARCHAR(24)) +  CAST(@RepSysItemId AS VARCHAR(12)) AS varchar(24));