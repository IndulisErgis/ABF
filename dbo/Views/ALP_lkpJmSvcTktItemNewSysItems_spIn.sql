CREATE VIEW  [dbo].[ALP_lkpJmSvcTktItemNewSysItems_spIn]
As            
           
SELECT ItemId,Descr as[Desc],'' as EquipLoc,0 as SysId,'' as SerNum,'' as WarrExpires,  
'' as Zone,0 as NewSysItemId,0 as Qty,0 as RemoveYn,0 as SysItemId,LocId,UomDflt
,AlpItemStatus,SuperId  
 FROM ALP_lkpInItemLoc