CREATE VIEW dbo.ALP_lkpPriceBaseWithUOM AS
SELECT  PriceBase,ALP_tblInItem_view.ItemId,LocId,tblInItemLocUomPrice.UOM FROM tblInItemLocUomPrice INNER JOIN ALP_tblInItem_view
 ON (tblInItemLocUomPrice.ItemId = ALP_tblInItem_view.ItemId)