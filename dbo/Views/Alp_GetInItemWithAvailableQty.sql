
CREATE view Alp_GetInItemWithAvailableQty
as
 WITH TEMP (ItemId, LocId, ItemLocStatus,QtyOnHand,QtyCommitted,QtyAvailable,QtyOnOrder,QtyOnShelf,QtyInUse,QAlpQtyInUse) 
    AS 
    (
        select * from Alp_UfxGetItemInfoNew()
    )
select a.*,   QtyAvailable ,ItemLocStatus
from ALP_tblInItem_view  a inner join TEMP  b on a.ItemId=b.itemid and b.locid='abf' and 
b. ItemLocStatus=1
union All
select a.*,   QtyAvailable ,b.ItemLocStatus
from ALP_tblInItem_view  a inner join TEMP  b on a.ItemId=b.itemid and b.locid='abf' and 
b. ItemLocStatus<>1 and b.QtyAvailable >0