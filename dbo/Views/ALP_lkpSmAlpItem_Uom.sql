Create view [dbo].[ALP_lkpSmAlpItem_Uom] as
SELECT     ItemCode AS ItemId, '**********' AS LocId, Units AS Uom
FROM         dbo.tblSmItem