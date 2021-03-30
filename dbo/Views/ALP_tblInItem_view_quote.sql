CREATE VIEW dbo.ALP_tblInItem_view_quote  
AS  
SELECT     dbo.trav_tblInItem_view.*, dbo.ALP_tblInItem.*,loc.LocId  
FROM       dbo.trav_tblInItem_view LEFT OUTER JOIN dbo.ALP_tblInItem ON dbo.trav_tblInItem_view.ItemId = dbo.ALP_tblInItem.AlpItemId  
           inner join dbo.ALP_tblInItemLocation_view loc    ON  loc.ItemId = dbo.trav_tblInItem_view.ItemId  
Where     (dbo.trav_tblInItem_view.ItemStatus = 1 or dbo.trav_tblInItem_view.ItemStatus=3)