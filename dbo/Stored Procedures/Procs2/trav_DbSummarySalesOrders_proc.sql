
CREATE PROCEDURE [dbo].[trav_DbSummarySalesOrders_proc]
@Prec tinyint = 2, 
@Foreign bit =0
AS
BEGIN TRY
	SET NOCOUNT ON
CREATE TABLE #SoOrders
	(
		Shipped pDecimal NULL, 
		Unshipped pDecimal NULL, 
		Returned pDecimal NULL
	)

	INSERT INTO #SoOrders (Shipped, Unshipped, Returned) 
	SELECT ROUND(SUM(CASE WHEN TransType IN (1, 4) THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyShipSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyShipSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec) AS Shipped
		, ROUND(SUM((CASE TransType WHEN 3 THEN d.QtyOrdSell WHEN 5 THEN d.QtyOrdSell WHEN 9 THEN d.QtyOrdSell 
				WHEN 4 THEN d.QtyBackOrdSell WHEN 1 THEN d.QtyBackOrdSell ELSE 0 END) 
			* (CASE WHEN @Foreign = 0 THEN d.UnitPriceSell ELSE d.UnitPriceSellFgn END) 
			* SIGN(TransType)), @Prec) AS Unshipped
		, ROUND(SUM(CASE WHEN TransType = -1 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyOrdSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyOrdSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec) AS Returned 
	FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId 
	WHERE d.Status = 0 AND d.GrpId IS NULL AND h.VoidYn = 0


	-- return resultset
	SELECT ROUND(ISNULL(SUM(ISNULL(Shipped, 0)),0), @Prec) AS Shipped
		, ROUND(ISNULL(SUM(ISNULL(Returned, 0)),0), @Prec) AS Returned
		, ROUND(ISNULL(SUM(ISNULL(Unshipped, 0)),0), @Prec) AS Unshipped 
	FROM #SoOrders
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummarySalesOrders_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummarySalesOrders_proc';

