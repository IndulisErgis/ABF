
CREATE function Alp_UfxGetItemInfo (  )  
returns       @MyTempTab table (Itemid pItemID,  LocId pLocID,ItemLocStatus tinyint ,  
  QtyOnHand pDec,  QtyCommitted pDec,  QtyAvailable pDec,   
   QtyOnOrder pDec,  QtyOnShelf pDec, QtyInUse pDec,AlpQtyInUse pDec )as   
   begin  
   insert into @MyTempTab  
select   Itemid,  LocId,ItemLocStatus ,0 as QtyOnHand,0 as QtyCommitted,0 as QtyAvailable,0 as QtyOnOrder,0 as QtyOnShelf,0 as QtyInUse,0 as AlpQtyInUse      
from tblInItemLoc  --where LocId='abf'-- ItemId=@pItemId    
--OnHand    
update a set a.QtyOnHand=b.QtyOnHand     
   from @MyTempTab a inner join     
 (select itemId,LocId, sum([Qty]-[InvoicedQty]-[RemoveQty]) as QtyOnHand from dbo.tblInQtyOnHand    
    group by itemid,LocId ) b     
 on a.Itemid =b.ItemId  and a.LocId=b.LocId    
--Committed    
update @MyTempTab  set QtyCommitted=  b.QtyCommitted      
  from @MyTempTab a inner join    
 ( select i.itemId,   LocId,Sum(CASE WHEN TransType=0 AND tt.TicketId IS NOT NULL THEN Qty ELSE 0 END ) AS QtyCommitted -- added 'AND tt.TicketId IS NOT NULL' on 06/23/2020  as QtyCommitted     
 from  dbo.tblInQty i    
  LEFT OUTER JOIN  [ALP_tblJmSvcTktItem] tt on tt.ticketitemid = i.linkidSub -- added on 06/23/2020      
    where   TransType=0   group by i.itemid,LocId)     
 b on a.ItemId=b.ItemId and a.LocId=b.LocId      
--InUse    
update @MyTempTab  set QtyInUse=  b.QtyInUse      
  from @MyTempTab a inner join    
 ( select itemId,   LocId,sum(Qty) as QtyInUse from  dbo.tblInQty  where   TransType=1   group by itemid,LocId)     
 b on a.ItemId=b.ItemId and a.LocId=b.LocId      
--On Order    
update @MyTempTab  set QtyOnOrder=  b.QtyOnOrder      
  from @MyTempTab a inner join    
 ( select itemId,  LocId, sum(Qty) as QtyOnOrder from  dbo.tblInQty  where   TransType=2  group by itemid,LocId)     
 b on a.ItemId=b.ItemId  and a.LocId=b.LocId     
 --   AlpQtyInUse    
 update @MyTempTab  set AlpQtyInUse =  b.AlpQtyInUse      
  from @MyTempTab a inner join    
 ( select a.itemId, LocId, sum(Qty) as AlpQtyInUse from  dbo.tblInQty a  
 inner join ALP_tblJmSvcTktItem s on a.LinkIDSub= s.TicketItemId  
 where  s.PartPulledDate is not null and (  TransType=0 AND LinkIdSubline=1 AND LinkId='JM')     
  group by a.itemid,LocId)     
 b on a.ItemId=b.ItemId  and a.LocId=b.LocId    
    
 --Available(Onhand - committed - inuse)    
update @MyTempTab  set QtyAvailable=  QtyOnHand-QtyCommitted    
--on shelf    
update @MyTempTab  set QtyOnShelf=  QtyOnHand-AlpQtyInUse    
--Item Location Status    
update @MyTempTab  set ItemLocStatus=b.ItemLocStatus from @MyTempTab a inner join  dbo.tblInItemLoc b on a.ItemId=b.ItemId where a.LocId=b.locId     
return    
end