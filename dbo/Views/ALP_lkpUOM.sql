CREATE VIEW dbo.ALP_lkpUOM
AS
SELECT     dbo.tblInItemUom.Uom, dbo.tblInItemUom.ConvFactor, dbo.tblInItemUom.ItemId
FROM         dbo.ALP_tblInItem_view INNER JOIN
                      dbo.tblInItemUom ON dbo.ALP_tblInItem_view.ItemId = dbo.tblInItemUom.ItemId