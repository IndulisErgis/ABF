
CREATE PROCEDURE [dbo].[trav_SoPriceStructList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT h.PriceId, h.Descr, h.DfltAdjBase, h.DfltAdjType, h.DfltAdjAmt, d.CustLevel, d.Descr AS [Desc], 
		   d.PriceAdjBase, d.PriceAdjType, d.PriceAdjAmt
	FROM   dbo.tblSoPriceStructHeader AS h LEFT OUTER JOIN dbo.tblSoPriceStructDetail AS d ON h.PriceId = d.PriceId
		   INNER JOIN #tmpPriceStruct t ON 	h.PriceId = t.PriceId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoPriceStructList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoPriceStructList_proc';

