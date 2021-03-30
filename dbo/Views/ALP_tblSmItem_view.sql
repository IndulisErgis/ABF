CREATE VIEW dbo.ALP_tblSmItem_view
AS
SELECT trav_tblSmItem_view.ItemCode as ItemId ,trav_tblSmItem_view.[Desc] as Descr,0 as CostBase,
dbo.trav_tblSmItem_view.*, dbo.ALP_tblSmItem.*
FROM dbo.ALP_tblSmItem INNER JOIN
dbo.trav_tblSmItem_view ON dbo.ALP_tblSmItem.AlpItemCode = dbo.trav_tblSmItem_view.ItemCode