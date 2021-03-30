
CREATE Procedure Alp_ItemInfo_by_ItemId   @pItemId pItemID    
as  
begin   
    
select   Itemid,  LocId,ItemLocStatus ,0 as QtyOnHand,0 as QtyCommitted,0 as QtyAvailable,0 as QtyOnOrder,0 as QtyOnShelf,0 as QtyInUse,0 as AlpQtyInUse into #t1  
from tblInItemLoc  
where ItemId=@pItemId  
--OnHand  
update a set a.QtyOnHand=b.QtyOnHand   
   from #t1 a inner join   
 (select itemId,LocId, sum([Qty]-[InvoicedQty]-[RemoveQty]) as QtyOnHand from dbo.tblInQtyOnHand where ItemId=@pItemId   group by itemid,LocId ) b   
 on a.Itemid =b.ItemId  and a.LocId=b.LocId  
--Committed  
update #t1  set QtyCommitted=  b.QtyCommitted    
  from #t1 a inner join  
 ( select i.itemId,   LocId,Sum(CASE WHEN TransType=0 AND tt.TicketId IS NOT NULL THEN Qty ELSE 0 END ) AS QtyCommitted -- added 'AND tt.TicketId IS NOT NULL' on 06/23/2020  as QtyCommitted   
 from  dbo.tblInQty i  
  LEFT OUTER JOIN  [ALP_tblJmSvcTktItem] tt on tt.ticketitemid = i.linkidSub -- added on 06/23/2020    
    where i.ItemId=  @pItemId and TransType=0   group by i.itemid,LocId)   
 b on a.ItemId=b.ItemId and a.LocId=b.LocId    
--InUse  
update #t1  set QtyInUse=  b.QtyInUse    
  from #t1 a inner join  
 ( select itemId,   LocId,sum(Qty) as QtyInUse from  dbo.tblInQty  where ItemId= @pItemId and TransType=1   group by itemid,LocId)   
 b on a.ItemId=b.ItemId and a.LocId=b.LocId    
--On Order  
update #t1  set QtyOnOrder=  b.QtyOnOrder    
  from #t1 a inner join  
 ( select itemId,  LocId, sum(Qty) as QtyOnOrder from  dbo.tblInQty  where ItemId=  @pItemId and TransType=2  group by itemid,LocId)   
 b on a.ItemId=b.ItemId  and a.LocId=b.LocId   
 --   AlpQtyInUse  
 update #t1  set AlpQtyInUse =  b.AlpQtyInUse    
  from #t1 a inner join  
 ( select a.itemId, LocId, sum(Qty) as AlpQtyInUse from  dbo.tblInQty a
 left outer join ALP_tblJmSvcTktItem s on a.LinkIDSub= s.TicketItemId
 where a.ItemId=  @pItemId and s.PartPulledDate is not null and (  TransType=0 AND LinkIdSubline=1 AND LinkId='JM')   
  group by a.itemid,LocId)   
 b on a.ItemId=b.ItemId  and a.LocId=b.LocId  
  
 --Available(Onhand - committed - inuse)  
update #t1  set QtyAvailable=  QtyOnHand-QtyCommitted  
--on shelf  
update #t1  set QtyOnShelf=  QtyOnHand-AlpQtyInUse  
--Item Location Status  
update #t1  set ItemLocStatus=b.ItemLocStatus from #t1 a inner join  dbo.tblInItemLoc b on a.ItemId=b.ItemId where a.LocId=b.locId   
select * from #t1  
end