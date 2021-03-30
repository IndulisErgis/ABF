CREATE VIEW dbo.ALP_lkpInItemUom AS
SELECT tblInItemUom.Uom, CASE WHEN tblInItemUom.ConvFactor is null THEN 1 ELSE tblInItemUom.ConvFactor END as ConvFactor ,ALP_tblInItem_view.ItemId
FROM ALP_tblInItem_view INNER JOIN tblInItemUom ON ALP_tblInItem_view.ItemId = tblInItemUom.ItemId