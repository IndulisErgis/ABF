
Create View dbo.trav_DrPlannedProduction_View
AS
Select	i.ItemId, l.LocId, isnull(i.ProductLine, '') ProductLine, isnull(l.ABCClass, '') ABCClass,
		i.UomDflt,isnull(r.QtyOnHand, 0) QtyOnHand, 
		Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End ConvFactor ,r.RunId 
	From dbo.tblInItem i
	Inner join (Select AssemblyId From dbo.tblMbAssemblyHeader inner join tblSmApp_Installed I on I.AppID='MB'
	 Group By AssemblyId
				union
				SELECT b.BmItemId 
				FROM dbo.tblBmBom b left join dbo.tblInItem i on b.BmItemId = i.ItemId inner join tblSmApp_Installed A on A.AppID='BM'
				Where i.KittedYn = 0
				Group By b.BmItemId ) h on i.ItemId = h.AssemblyId 
	inner join dbo.tblInItemLoc l on i.ItemId = l.ItemId 
	Inner join dbo.tblDRRunItemLoc r  on l.ItemId = r.ItemId and l.LocId = r.LocId
	Left join dbo.tblInItemUom u  on i.ItemId = u.ItemId and i.UomDflt = u.UOM
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrPlannedProduction_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrPlannedProduction_View';

