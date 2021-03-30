-- =============================================
-- Author:		Indulis Ergis
-- Create date: 3/5/2021
-- Description:	Function That Is used for search
-- =============================================
CREATE FUNCTION dbo.Alp_UfxGetItemInfoNew ()
RETURNS TABLE 
AS
RETURN 
(
select   main.Itemid,  main.LocId, itemloc.ItemLocStatus ,ISNULL(b.QtyOnHand,0) as QtyOnHand,ISNULL(com.QtyCommitted,0) as QtyCommitted,
ISNULL(b.QtyOnHand - com.QtyCommitted,0) as QtyAvailable,
ISNULL(onorder.QtyOnOrder,0) as QtyOnOrder,ISNULL(b.QtyOnHand - alpinuse.AlpQtyInUse,0) as QtyOnShelf,ISNULL(inuse.QtyInUse,0) as QtyInUse,
ISNULL(alpinuse.AlpQtyInUse,0) as AlpQtyInUse      
from tblInItemLoc  main
 left outer join    
 (select itemId,LocId, sum([Qty]-[InvoicedQty]-[RemoveQty]) as QtyOnHand from dbo.tblInQtyOnHand    
    group by itemid,LocId ) b     
 on main.Itemid =b.ItemId  and main.LocId=b.LocId    
--Committed    
 left outer join   
 ( select i.itemId,   LocId,Sum(CASE WHEN TransType=0 AND tt.TicketId IS NOT NULL THEN Qty ELSE 0 END ) AS QtyCommitted -- added 'AND tt.TicketId IS NOT NULL' on 06/23/2020  as QtyCommitted     
 from  dbo.tblInQty i    
  LEFT OUTER JOIN  [ALP_tblJmSvcTktItem] tt on tt.ticketitemid = i.linkidSub -- added on 06/23/2020      
    where   TransType=0   group by i.itemid,LocId)     
 com on main.ItemId=com.ItemId and main.LocId=com.LocId      
--InUse    
 left outer join   
 ( select itemId,   LocId,sum(Qty) as QtyInUse from  dbo.tblInQty  where   TransType=1   group by itemid,LocId)     
 inuse on main.ItemId=inuse.ItemId and main.LocId=inuse.LocId      
--On Order    
left outer join   
 ( select itemId,  LocId, sum(Qty) as QtyOnOrder from  dbo.tblInQty  where   TransType=2  group by itemid,LocId)     
 onorder on main.ItemId=onorder.ItemId  and main.LocId=onorder.LocId     
 --   AlpQtyInUse    
 left outer join   
 ( select a.itemId, LocId, sum(Qty) as AlpQtyInUse from  dbo.tblInQty a  
 left outer join ALP_tblJmSvcTktItem s on a.LinkIDSub= s.TicketItemId  
 where  s.PartPulledDate is not null and (  TransType=0 AND LinkIdSubline=1 AND LinkId='JM')     
  group by a.itemid,LocId)     
 alpinuse on main.ItemId=alpinuse.ItemId  and main.LocId=alpinuse.LocId    
left outer join dbo.tblInItemLoc itemloc on main.ItemId=itemloc.ItemId where main.LocId=itemloc.locId     
--order by main.itemId
)