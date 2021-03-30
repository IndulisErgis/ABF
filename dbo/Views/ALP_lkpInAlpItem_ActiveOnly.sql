Create View [dbo].[ALP_lkpInAlpItem_ActiveOnly] as
SELECT     ItemId, Descr, ItemType
FROM         dbo.tblInItem
WHERE     (ItemStatus = 1)