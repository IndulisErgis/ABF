
CREATE PROCEDURE [dbo].[trav_DbSalesOrderStatus_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null
AS
BEGIN TRY
	SET NOCOUNT ON

	
	CREATE TABLE #SoOrders
	(
		New pDecimal NULL, 
		Picked pDecimal NULL, 
		Verified pDecimal NULL, 
		Invoiced pDecimal NULL, 
		Backordered pDecimal NULL, 
		Returned pDecimal NULL, 
		RMAs pDecimal NULL, 
		Quoted pDecimal NULL, 
		TotToday pDecimal NULL, 
		TotPTD pDecimal NULL
	)

	CREATE TABLE #ArTrans
	(
		InvcToday pDecimal NULL, 
		InvcPTD pDecimal NULL
	)

	CREATE TABLE #ArTransHist
	(
		InvcdToday pDecimal NULL, 
		InvcdPTD pDecimal NULL
	)

	DECLARE @FiscalYear smallint, @Period smallint
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	INSERT INTO #SoOrders (New, Picked, Verified, Invoiced, Backordered, Returned, RMAs, Quoted, TotToday, TotPTD) 
	SELECT ROUND(SUM(CASE WHEN TransType = 9 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyOrdSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyOrdSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec)AS New
		, ROUND(SUM(CASE WHEN TransType = 5 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyOrdSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyOrdSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec)AS Picked
		, ROUND(SUM(CASE WHEN TransType = 4 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyShipSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyShipSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec)AS Verified
		, ROUND(SUM(CASE WHEN TransType = 1 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyShipSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyShipSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec)AS Invoiced
		, ROUND(SUM((CASE TransType WHEN 3 THEN d.QtyOrdSell WHEN 4 THEN d.QtyBackOrdSell 
				WHEN 1 THEN d.QtyBackOrdSell ELSE 0 END) 
			* (CASE WHEN @Foreign = 0 THEN d.UnitPriceSell ELSE d.UnitPriceSellFgn END) 
			* SIGN(TransType)), @Prec) AS Backordered
		, ROUND(SUM(CASE WHEN TransType = -1 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyOrdSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyOrdSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec)AS Returned
		, ROUND(SUM(CASE WHEN TransType = -2 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyOrdSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyOrdSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec)AS RMAs
		, ROUND(SUM(CASE WHEN TransType = 2 THEN (CASE WHEN @Foreign = 0 
			THEN ((QtyOrdSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyOrdSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END), @Prec)AS Quoted
		, ROUND(SUM(CASE WHEN InvcDate = @WksDate THEN ((CASE TransType WHEN -1 THEN d.QtyOrdSell 
				WHEN 4 THEN d.QtyShipSell WHEN 1 THEN d.QtyShipSell ELSE 0 END 
			* CASE WHEN @Foreign = 0 THEN d.UnitPriceSell ELSE d.UnitPriceSellFgn END) 
			* SIGN(TransType)) ELSE 0 END), @Prec) AS TotToday
		, ROUND(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN ((CASE TransType WHEN -1 THEN d.QtyOrdSell WHEN 4 THEN d.QtyShipSell 
				WHEN 1 THEN d.QtyShipSell ELSE 0 END 
			* CASE WHEN @Foreign = 0 THEN d.UnitPriceSell ELSE d.UnitPriceSellFgn END) 
			* SIGN(TransType)) ELSE 0 END), @Prec) AS TotPTD 
	FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId 
	WHERE d.Status = 0 AND d.GrpId IS NULL AND h.VoidYn = 0

	INSERT INTO #ArTrans (InvcToday, InvcPTD) 
	SELECT ROUND(ISNUll(SUM(CASE WHEN TransType IN (1,-1) AND InvcDate = @WksDate 
			THEN (CASE WHEN @Foreign = 0 THEN ((TaxSubtotal + NonTaxSubtotal) * SIGN(TransType)) 
			ELSE ((TaxSubtotalFgn + NonTaxSubtotalFgn) * SIGN(TransType))END) ELSE 0 END),0), @Prec) AS InvcToday
		, ROUND(ISNUll(SUM(CASE WHEN TransType IN (1,-1) AND FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN (CASE WHEN @Foreign = 0 THEN ((TaxSubtotal + NonTaxSubtotal) * SIGN(TransType)) 
			ELSE ((TaxSubtotalFgn + NonTaxSubtotalFgn) * SIGN(TransType))END) ELSE 0 END),0), @Prec) AS InvcPTD 
	FROM dbo.tblArTransHeader WHERE VoidYn = 0

	INSERT INTO #ArTransHist (InvcdToday, InvcdPTD) 
	SELECT ROUND(ISNUll(SUM(CASE WHEN TransType IN (1,-1) AND InvcDate = @WksDate 
			THEN (CASE WHEN @Foreign = 0 THEN((QtyShipSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyShipSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END),0), @Prec) AS InvcdToday
		, ROUND(ISNUll(SUM(CASE WHEN TransType IN (1,-1) AND FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN (CASE WHEN @Foreign = 0 THEN((QtyShipSell * UnitPriceSell) * SIGN(TransType)) 
			ELSE ((QtyShipSell * UnitPriceSellFgn) * SIGN(TransType))END) ELSE 0 END),0), @Prec) AS InvcdPTD 
	FROM dbo.tblArHistHeader h 
		INNER JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransId 
	WHERE h.VoidYn = 0 and d.EntryNum > 0 AND d.GrpId IS NULL
	--exclude freight/misc/tax from detail

	-- return resultset
	SELECT ISNUll(SUM(New),0) AS New
		, ISNUll(SUM(Picked),0) AS Picked
		, ISNUll(SUM(Backordered),0)  AS Backordered
		, ISNUll(SUM(Quoted) ,0) AS Quoted
		, ROUND(ISNUll(SUM(ISNULL(Verified, 0) + ISNULL(Invoiced, 0)),0) , @Prec) AS Shipped
		, ROUND(ISNUll(SUM(ISNULL(Returned, 0)),0) , @Prec) AS Returned
		, ROUND(ISNUll(SUM(ISNULL(RMAs, 0)),0) , @Prec) AS RMAs
		, ROUND(SUM(ISNULL(New, 0) + ISNULL(Picked, 0) + ISNULL(Verified, 0) + ISNULL(Invoiced, 0) 
			+ ISNULL(Backordered, 0) + ISNULL(Returned, 0)), @Prec) AS OrderTotal
		, ROUND(SUM(ISNULL(TotToday, 0) + ISNULL(InvcToday, 0) + ISNULL(InvcdToday, 0)), @Prec) AS InvcdToday
		, ROUND(SUM(ISNULL(TotPTD, 0) + ISNULL(InvcPTD, 0) + ISNULL(InvcdPTD, 0)), @Prec) AS InvcdPTD 
	FROM #SoOrders, #ArTrans, #ArTransHist
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSalesOrderStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSalesOrderStatus_proc';

