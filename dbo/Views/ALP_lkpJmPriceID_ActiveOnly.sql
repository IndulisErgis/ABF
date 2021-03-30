Create View [dbo].[ALP_lkpJmPriceID_ActiveOnly] as
 SELECT     PriceId, [Desc], InactiveYN
FROM         dbo.ALP_tblJmPricePlanGenHeader
WHERE     (InactiveYN = 0)