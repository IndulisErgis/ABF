CREATE PROCEDURE [dbo].[ALP_qryInsertArAlpSiteSysItem]  
@SysItemId int out,  
@SysId int,  
@ItemId varchar(24),  
@Descr varchar(255),  
@LocId varchar(10),  
@PanelYN bit=0,  
@SerNum varchar(35),  
@EquipLoc varchar(30),  
@Qty float(8),  
@UnitCost numeric(20,10),--decimal changed to numeric by NSK on 12 jan 2021 for bug id 1105   
@WarrPlanId int,  
@WarrTerm int,  
@WarrStarts datetime,  
@WarrExpires datetime,  
@Comments text,  
@RemoveYN bit=0,  
@Zone varchar(5),  
@TicketId int,  
@RepPlanId int,  
@LeaseYN bit=0,  
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017  
@ModifiedBy varchar(50)  
  
AS  
insert into ALP_tblArAlpSiteSysItem(SysId,ItemId,[Desc],LocId,PanelYN,SerNum,EquipLoc,Qty,UnitCost,WarrPlanId,WarrTerm,  
WarrStarts,WarrExpires,Comments,RemoveYN,[Zone],TicketId,RepPlanId,LeaseYN,ModifiedBy,ModifiedDate)  
Values(@SysId, @ItemId,@Descr,@LocId,@PanelYN,@SerNum, @EquipLoc,@Qty,@UnitCost,@WarrPlanId,@WarrTerm,  
@WarrStarts,@WarrExpires,@Comments,@RemoveYN,@Zone,@TicketId,@RepPlanId,@LeaseYN,@ModifiedBy,GETDATE())  
  
set @SysItemId= SCOPE_IDENTITY();