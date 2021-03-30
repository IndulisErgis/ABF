
Create View dbo.trav_DrPlannedPurchase_View
AS  
Select i.ItemId, l.LocId,isnull(l.DfltVendId, '') VendId, isnull(i.ProductLine, '') ProductLine,
	   isnull(l.ABCClass, '') ABCClass,isnull(r.QtyOnHand, 0) QtyOnHand, i.UomDflt ,
	   Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End ConvFactor ,r.RunId ,t.BmItemId 
	From dbo.tblInItem i 
	inner join dbo.tblInItemLoc l 	on i.ItemId = l.ItemId 
	inner join dbo.tblDRRunItemLoc r  on l.ItemId = r.ItemId and l.LocId = r.LocId 
	Left join dbo.tblInItemUom u  on i.ItemId = u.ItemId and i.UomDflt = u.UOM 
	Left Join (SELECT b.BmItemId, b.BmLocId, b.Descr, l.Descr LocDescr
	FROM dbo.tblBmBom b left join dbo.tblInItem i on b.BmItemId = i.ItemId
	left join dbo.tblInLoc l on b.BmLocId = l.LocId
	Where i.KittedYn = 0) t 	on i.ItemId = t.BmItemId  
	where  t.BmItemId is null  
	and i.ItemId not in (Select AssemblyId From dbo.tblMbAssemblyHeader Group by AssemblyId)
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrPlannedPurchase_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrPlannedPurchase_View';

