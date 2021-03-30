
CREATE PROCEDURE [dbo].[trav_DbArSalesHistory_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null
AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #ArSalesHistory
	(
		SalesPTD pDecimal DEFAULT(0), 
		SalesYTD pDecimal DEFAULT(0), 
		ReturnsPTD pDecimal DEFAULT(0), 
		ReturnsYTD pDecimal DEFAULT(0), 
		SalesTaxPTD pDecimal DEFAULT(0), 
		SalesTaxYTD pDecimal DEFAULT(0), 
		FreightPTD pDecimal DEFAULT(0), 
		FreightYTD pDecimal DEFAULT(0), 
		MiscPTD pDecimal DEFAULT(0), 
		MiscYTD pDecimal DEFAULT(0)
	)

	CREATE TABLE #ArFinanceChargeHistory
	(
		FinChgPTD pDecimal NULL DEFAULT(0), 
		FinChgYTD pDecimal NULL DEFAULT(0)
	)

DECLARE @FiscalYear smallint, @Period smallint
SELECT @FiscalYear = GlYear, @Period = GlPeriod 
FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	/*  ArSalesHistory  */
	INSERT INTO #ArSalesHistory (SalesPTD, SalesYTD, ReturnsPTD, ReturnsYTD
		, SalesTaxPTD, SalesTaxYTD, FreightPTD, FreightYTD, MiscPTD, MiscYTD) 
	SELECT ROUND(ISNULL(SUM(CASE WHEN TransType = 1 AND FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN CASE WHEN @Foreign = 0 THEN ((TaxSubtotal + NonTaxSubTotal) * SIGN(TransType)) 
			ELSE ((TaxSubtotalFgn + NonTaxSubTotalFgn) * SIGN(TransType)) END ELSE 0 END),0), @Prec) AS SalesPTD
		, ROUND(ISNULL(SUM(CASE WHEN TransType = 1 AND FiscalYear = @FiscalYear AND GLPeriod <= @Period 
			THEN CASE WHEN @Foreign = 0 THEN ((TaxSubtotal + NonTaxSubTotal) * SIGN(TransType)) 
			ELSE ((TaxSubtotalFgn + NonTaxSubTotalFgn) * SIGN(TransType)) END ELSE 0 END),0), @Prec) AS SalesYTD
		, ROUND(ISNULL(SUM(CASE WHEN TransType = -1 AND FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN CASE WHEN @Foreign = 0 THEN ((TaxSubtotal + NonTaxSubTotal) * SIGN(TransType)) 
			ELSE ((TaxSubtotalFgn + NonTaxSubTotalFgn) * SIGN(TransType)) END ELSE 0 END), 0),@Prec) AS ReturnsPTD
		, ROUND(ISNULL(SUM(CASE WHEN TransType = -1 AND FiscalYear = @FiscalYear AND GLPeriod <= @Period 
			THEN CASE WHEN @Foreign = 0 THEN ((TaxSubtotal + NonTaxSubTotal) * SIGN(TransType)) 
			ELSE ((TaxSubtotalFgn + NonTaxSubTotalFgn) * SIGN(TransType)) END ELSE 0 END), 0),@Prec) AS ReturnsYTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN CASE WHEN @Foreign = 0 THEN (SalesTax * SIGN(TransType)) 
			ELSE (SalesTaxFgn * SIGN(TransType)) END ELSE 0 END), 0),@Prec) AS SalesTaxPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period 
			THEN CASE WHEN @Foreign = 0 THEN (SalesTax * SIGN(TransType)) 
			ELSE (SalesTaxFgn * SIGN(TransType)) END ELSE 0 END), 0),@Prec) AS SalesTaxYTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN CASE WHEN @Foreign = 0 THEN (Freight * SIGN(TransType)) 
			ELSE (FreightFgn * SIGN(TransType)) END ELSE 0 END),0), @Prec) AS FreightPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period 
			THEN CASE WHEN @Foreign = 0 THEN (Freight * SIGN(TransType)) 
			ELSE (FreightFgn * SIGN(TransType)) END ELSE 0 END),0), @Prec) AS FreightYTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN CASE WHEN @Foreign = 0 THEN (Misc * SIGN(TransType)) 
			ELSE (MiscFgn * SIGN(TransType)) END ELSE 0 END), 0),@Prec) AS MiscPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period 
			THEN CASE WHEN @Foreign = 0 THEN (Misc * SIGN(TransType)) 
			ELSE (MiscFgn * SIGN(TransType)) END ELSE 0 END),0), @Prec) AS MiscYTD 
	FROM dbo.tblArHistHeader WHERE VoidYn = 0

	/*  ArFinanceCharges  */
	INSERT INTO #ArFinanceChargeHistory (FinChgPTD, FinChgYTD) 
	SELECT ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period THEN 
		(CASE WHEN @Foreign = 0 THEN FinchAmt ELSE FinchAmtFgn END) ELSE 0 END),0) AS FinChgPTD
		, ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period THEN 
		(CASE WHEN @Foreign = 0 THEN FinchAmt ELSE FinchAmtFgn END) ELSE 0 END),0) AS FinChgYTD 
	FROM dbo.tblArHistFinch

	-- return resultset
	SELECT *
		,ISNULL([SalesPTD], 0) + ISNULL([ReturnsPTD], 0) + ISNULL([SalesTaxPTD], 0)+ ISNULL([FreightPTD], 0) + ISNULL([MiscPTD], 0) + 
		ISNULL([FinChgPTD], 0) AS TotalPTD
		, ISNULL([SalesYTD], 0) + ISNULL([ReturnsYTD], 0) + ISNULL([SalesTaxYTD], 0) 
			+ ISNULL([FreightYTD], 0) + ISNULL([MiscYTD], 0) + ISNULL([FinChgYTD], 0) AS TotalYTD 
	FROM #ArSalesHistory, #ArFinanceChargeHistory
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArSalesHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArSalesHistory_proc';

