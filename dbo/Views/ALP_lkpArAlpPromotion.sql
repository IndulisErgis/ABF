
CREATE VIEW dbo.ALP_lkpArAlpPromotion
AS
SELECT     TOP 100 PERCENT PromoId, Promo, [Desc], InactiveYN
FROM         dbo.ALP_tblArAlpPromotion
WHERE     (InactiveYN = 0)
ORDER BY Promo