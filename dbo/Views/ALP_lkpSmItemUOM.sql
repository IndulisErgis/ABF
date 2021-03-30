CREATE VIEW dbo.ALP_lkpSmItemUOM AS
SELECT Units as Uom, 1 as ConvFactor,ItemCode FROM ALP_tblSmItem_view