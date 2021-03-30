CREATE VIEW dbo.ALP_lkpInAlpItemLoc  
AS  
SELECT     TOP 100 PERCENT dbo.ALP_tblInItem_view.ItemId, dbo.ALP_tblInItem_view.Descr,
 dbo.tblInItemLoc.LocId, dbo.ALP_tblInItem_view.AlpPanelYN  ,dbo.tblInItemLoc.CostBase 
FROM         dbo.ALP_tblInItem_view INNER JOIN  
              dbo.tblInItemLoc ON dbo.ALP_tblInItem_view.ItemId = dbo.tblInItemLoc.ItemId  
ORDER BY dbo.ALP_tblInItem_view.ItemId