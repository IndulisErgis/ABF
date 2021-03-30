--MOD:http://webfront:801/view.php?id=251619
CREATE PROCEDURE [dbo].[trav_DbPurchaseOrderStatus_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null
AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #ApTrans-- AP Trans Invoice & Credit Memo Totals for Today & PTD
	(
		InvcToday pDecimal NULL, 
		InvcPTD pDecimal NULL
	)

	CREATE TABLE #ApTransRcpt-- PO Trans Receipt Totals for Today
	(
		ShippedToday pDecimal NULL
	)

	CREATE TABLE #ApTransHist-- AP Hist Invoice & Credit Memo Totals for Today & PTD
	(
		InvcdToday pDecimal NULL, 
		InvcdPTD pDecimal NULL
	)

	CREATE TABLE #PoOrders-- PO Trans Totals
	(
		New pDecimal NULL, 
		Printed pDecimal NULL, 
		Shipped pDecimal NULL, 
		Returned pDecimal NULL, 
		DMemo pDecimal NULL, 
		GrandTotal pDecimal NULL, 
		InvoicedToday pDecimal NULL,
		InvoicedPTD pDecimal NULL
	)

	DECLARE @FiscalYear smallint, @Period smallint
	DECLARE  @BegPeriodDate datetime, @EndPeriodDate datetime
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	SELECT @BegPeriodDate = BegDate, @EndPeriodDate = EndDate 
	FROM dbo.tblSmPeriodConversion WHERE GlYear = @FiscalYear AND GlPeriod = @Period

	INSERT INTO #PoOrders (New, Printed, Shipped, Returned, DMemo, GrandTotal, InvoicedToday, InvoicedPTD) 
	SELECT ROUND(SUM(New), @Prec) AS New, ROUND(SUM(Printed), @Prec) AS Printed, ROUND(SUM(Shipped), @Prec) AS Shipped
	   , ROUND(SUM(Returned), @Prec) AS Returned, ROUND(SUM(DMemo), @Prec) AS DMemo, ROUND(SUM(GrandTotal), @Prec) AS GrandTotal
	   , ROUND(SUM(InvoicedToday), @Prec) AS InvoicedToday, ROUND(SUM(InvoicedPTD), @Prec) AS InvoicedPTD 
FROM
(
	SELECT  CASE WHEN TransType = 9 AND PrintStatus = 0 
			  THEN (CASE WHEN @Foreign = 0 THEN ((ISNULL(MemoTaxable, 0) + ISNULL(MemoNonTaxable, 0)) * SIGN(TransType)) 
			  ELSE ((ISNULL(MemoTaxableFgn,0) + ISNULL(MemoNonTaxableFgn,0)) * SIGN(TransType))END) ELSE 0 END AS
 New
			, CASE WHEN TransType = 9 AND PrintStatus <> 0
			  THEN (CASE WHEN @Foreign = 0 THEN ((ISNULL(MemoTaxable,0) + ISNULL(MemoNonTaxable,0)) * SIGN(TransType)) 
			  ELSE ((ISNULL(MemoTaxableFgn ,0)+ ISNULL(MemoNonTaxableFgn,0)) * SIGN(TransType))END) ELSE 0 END AS 
Printed
			, CASE WHEN TransType IN (1, 2)
			  THEN (CASE WHEN @Foreign = 0 THEN ((ISNULL(MemoTaxable,0) + ISNULL(MemoNonTaxable,0)) * SIGN(TransType)) 
			  ELSE ((ISNULL(MemoTaxableFgn,0) + ISNULL(MemoNonTaxableFgn,0)) * SIGN(TransType))END) ELSE 0 END AS 
Shipped
			, CASE WHEN TransType = -1 	
			  THEN (CASE WHEN @Foreign = 0 THEN ((ISNULL(MemoTaxable,0) + ISNULL(MemoNonTaxable,0)) * SIGN(TransType)) 
			  ELSE ((ISNULL(MemoTaxableFgn,0) + ISNULL(MemoNonTaxableFgn,0)) * SIGN(TransType))END) ELSE 0 END AS 
Returned
			, CASE WHEN TransType = -2 
			  THEN (CASE WHEN @Foreign = 0 THEN ((ISNULL(MemoTaxable,0) + ISNULL(MemoNonTaxable,0)) * SIGN(TransType)) 
			  ELSE ((ISNULL(MemoTaxableFgn,0) + ISNULL(MemoNonTaxableFgn,0)) * SIGN(TransType))END) ELSE 0 END AS 
DMemo
			, CASE WHEN @Foreign = 0 
			THEN ((ISNULL(MemoTaxable,0) + ISNULL(MemoNonTaxable,0)) * SIGN(TransType)) 
			ELSE ((ISNULL(MemoTaxableFgn,0) + ISNULL(MemoNonTaxableFgn,0)) * SIGN(TransType))END AS GrandTotal
			, 0 AS 
InvoicedToday
			, 0 AS 
InvoicedPTD 
	   FROM dbo.tblPoTransHeader
	   
		 UNION ALL
		 
		 SELECT 0 AS New, 0 AS Printed, 0 AS Shipped, 0 AS Returned, 0 AS DMemo, 0 AS GrandTotal
			  ,  CASE WHEN TransType IN (2, -2) AND InvcDate = @WksDate THEN (CASE WHEN @Foreign = 0 THEN ((ISNULL(CurrTaxable,0) + ISNULL(CurrNonTaxable,0)) * SIGN(TransType)) 
			ELSE ((ISNULL(CurrTaxableFgn,0) + ISNULL(CurrNonTaxableFgn,0)) * SIGN(TransType))END) ELSE 0 END AS InvoicedToday
		, CASE WHEN TransType IN (2, -2) AND InvcDate BETWEEN @BegPeriodDate AND @EndPeriodDate THEN (CASE WHEN @Foreign = 0 THEN ((ISNULL(CurrTaxable,0) + ISNULL(CurrNonTaxable,0)) * SIGN(TransType)) 
			ELSE ((ISNULL(CurrTaxableFgn,0) + ISNULL(CurrNonTaxableFgn,0)) * SIGN(TransType))END) ELSE 0 END AS InvoicedPTD 
	FROM dbo.tblPoTransHeader h LEFT JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId
) temp

	INSERT INTO #ApTrans (InvcToday, InvcPTD) 
	SELECT ISNULL(ROUND(SUM(CASE WHEN TransType IN (1, -1) AND InvoiceDate = @WksDate 
			THEN (CASE WHEN @Foreign = 0 THEN ((Subtotal) * SIGN(TransType)) 
			ELSE ((SubtotalFgn) * SIGN(TransType))END) ELSE 0 END), @Prec), 0) AS InvcToday
		, ISNULL(ROUND(SUM(CASE WHEN TransType IN (1, -1) AND FiscalYear = @FiscalYear AND GLPeriod = 

@Period 
			THEN (CASE WHEN @Foreign = 0 THEN ((Subtotal) * SIGN(TransType)) 
			ELSE ((SubtotalFgn) * SIGN(TransType))END) ELSE 0 END), @Prec), 0) AS InvcPTD 
	FROM dbo.tblApTransHeader

	INSERT INTO #ApTransRcpt(ShippedToday) 
	SELECT ISNULL(ROUND(SUM(CASE WHEN ReceiptDate = @WksDate 
		THEN (CASE WHEN @Foreign = 0 THEN (ExtCost * SIGN(TransType)) 
		ELSE (ExtCostFgn * SIGN(TransType)) END) ELSE 0 END), @Prec), 0) AS ShippedToday 
	FROM dbo.tblPoTransReceipt r LEFT JOIN dbo.tblPoTransHeader h ON r.TransId = h.TransId 
		INNER JOIN dbo.tblPoTransLotRcpt p ON r.TransId = p.TransId AND r.ReceiptNum = p.RcptNum

	INSERT INTO #ApTransHist (InvcdToday, InvcdPTD) 
	SELECT ROUND(SUM(CASE WHEN TransType IN (1, -1) AND InvoiceDate = @WksDate 
			THEN (CASE WHEN @Foreign = 0 THEN((Subtotal) * SIGN(TransType)) 
			ELSE ((SubtotalFgn ) * SIGN(TransType))END) ELSE 0 END), @Prec) AS InvcdToday
		, ROUND(SUM(CASE WHEN TransType IN (1, -1) AND FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN (CASE WHEN @Foreign = 0 THEN((Subtotal) * SIGN(TransType)) 
			ELSE ((SubtotalFgn ) * SIGN(TransType))END) ELSE 0 END), @Prec) AS InvcdPTD 
	FROM dbo.tblApHistHeader

	-- return resultset
	SELECT ISNULL(SUM(New), 0) AS New
		, ISNULL(SUM(Printed), 0) AS Printed
		, ISNULL(SUM(Shipped), 0) AS Shipped
		, ISNULL(SUM(Returned), 0) AS Returned
		, ISNULL(SUM(DMemo), 0) AS DMemo
		, ISNULL(SUM(GrandTotal), 0) AS GrandTotal
		, ISNULL(SUM(ShippedToday), 0) AS ShippedToday
		, SUM(ISNULL(InvoicedToday, 0)+ ISNULL(InvcToday, 0) + ISNULL(InvcdToday, 0)) AS InvcdToday
		, SUM(ISNULL(InvoicedPTD, 0) + ISNULL(InvcPTD, 0) + ISNULL(InvcdPTD, 0)) AS InvcdPTD 
	FROM #PoOrders, #ApTrans, #ApTransHist, #ApTransRcpt
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbPurchaseOrderStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbPurchaseOrderStatus_proc';

