
CREATE PROCEDURE [dbo].[trav_DbApPurchaseHistory_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @FiscalYear smallint, @Period smallint
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	-- return resultset
SELECT ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period THEN 
			CASE WHEN @Foreign = 0 THEN (Taxable + NonTaxable) ELSE (TaxableFgn + NonTaxableFgn) END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS InvoicesPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period THEN 
			CASE WHEN @Foreign = 0 THEN (Taxable + NonTaxable) ELSE (TaxableFgn + NonTaxableFgn) END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS InvoicesYTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period THEN 
			CASE WHEN @Foreign = 0 THEN Freight ELSE FreightFgn END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS FreightPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period THEN 
			CASE WHEN @Foreign = 0 THEN Freight ELSE FreightFgn END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS FreightYTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period THEN 
			CASE WHEN @Foreign = 0 THEN (SalesTax + TaxAdjAmt) ELSE (SalesTaxFgn + TaxAdjAmtFgn) END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS SalesTaxPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period THEN 
			CASE WHEN @Foreign = 0 THEN (SalesTax + TaxAdjAmt) ELSE (SalesTaxFgn + TaxAdjAmtFgn) END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS SalesTaxYTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period THEN 
			CASE WHEN @Foreign = 0 THEN Misc ELSE MiscFgn END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS MiscPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period THEN 
			CASE WHEN @Foreign = 0 THEN Misc ELSE MiscFgn END 
				* SIGN(TransType) ELSE 0 END),0), @Prec) AS MiscYTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period THEN 
			CASE WHEN @Foreign = 0 THEN (Taxable + NonTaxable + Freight + SalesTax + TaxAdjAmt + Misc) 
				ELSE (TaxableFgn + NonTaxableFgn + FreightFgn + SalesTaxFgn + TaxAdjAmtFgn + MiscFgn) END 
					* SIGN(TransType) ELSE 0 END),0), @Prec) AS TotPurchasesPTD
		, ROUND(ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod <= @Period THEN 
			CASE WHEN @Foreign = 0 THEN (Taxable + NonTaxable + Freight + SalesTax + TaxAdjAmt + Misc) 
				ELSE (TaxableFgn + NonTaxableFgn + FreightFgn + SalesTaxFgn + TaxAdjAmtFgn + MiscFgn) END 
					* SIGN(TransType) ELSE 0 END),0), @Prec) AS TotPurchasesYTD
						FROM dbo.tblApHistHeader 
	END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApPurchaseHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApPurchaseHistory_proc';

