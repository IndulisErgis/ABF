
CREATE PROCEDURE [dbo].[trav_SoPricePromoList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT  p.PromoId, Descr, PriceIdFrom, PriceIdThru, CustLevelFrom, CustLevelThru, ProductLineFrom, ProductLineThru, ItemIdFrom, ItemIdThru, 
			UomFrom, UomThru, LocIdFrom, LocIdThru, UsrFld1From, UsrFld1Thru, UsrFld2From, UsrFld2Thru, PriceAdjBase, PriceAdjType, PriceAdjAmt, 
			DateStart, DateEnd, WebOnlyYn, ts, CF
	FROM   dbo.tblSoPricePromo p INNER JOIN #tmpPricePromo t ON t.PromoId = p.PromoId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoPricePromoList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoPricePromoList_proc';

