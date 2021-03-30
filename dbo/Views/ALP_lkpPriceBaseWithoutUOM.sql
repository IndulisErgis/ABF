CREATE VIEW dbo.ALP_lkpPriceBaseWithoutUOM AS
SELECT PriceBase,ALP_tblInItem_view.ItemId,LocId FROM tblInItemLocUomPrice INNER JOIN ALP_tblInItem_view ON (tblInItemLocUomPrice.Uom = ALP_tblInItem_view.UomDflt)
  AND (tblInItemLocUomPrice.ItemId = ALP_tblInItem_view.ItemId)