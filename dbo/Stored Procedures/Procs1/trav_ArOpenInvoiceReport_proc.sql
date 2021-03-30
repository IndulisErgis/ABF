
CREATE PROCEDURE dbo.trav_ArOpenInvoiceReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@ExcludePaidInvoices bit = 0, 
@PrintSales bit = 1,  --AR/SO invoices
@PrintProjects bit = 1,  --Project invoices     
@PrintService bit = 1, --Service invoices 
@IncludeRegularInvcType bit=1 ,  
@IncludeProformaInvcType bit=1  
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmp 
	(
		CustId pCustID NULL, 
		InvcNum pInvoiceNum NULL, 
		AmtFgn pDecimal
	)

	INSERT INTO #tmp (CustId, InvcNum, AmtFgn) 
	SELECT o.CustId, o.InvcNum
		, CASE WHEN SUM(SIGN(o.RecType) * o.AmtFgn) IS NOT NULL THEN SUM(SIGN(o.RecType) * o.AmtFgn) ELSE 0 END AS AmtFgn 
	FROM #tmpCustomerList t INNER JOIN dbo.tblArOpenInvoice o (NOLOCK) ON t.CustId = o.CustId
	AND ((o.RecType<>5 AND @IncludeRegularInvcType=1)OR (o.RecType=5 AND  @IncludeProformaInvcType=1))  
	GROUP BY o.CustId, o.InvcNum

	IF @PrintAllInBase = 1 
	BEGIN
	SELECT c.CustId, c.CustName, o.PmtMethodId, o.CurrencyId, o.RecType, o.Status
		, o.TransDate, o.NetDueDate, o.DiscDueDate, o.InvcNum, o.SourceApp
		, CASE WHEN o.RecType > 0 THEN o.Amt ELSE 0 END 
			+ CASE WHEN o.RecType = -3 THEN -o.Amt ELSE 0 END AS GrossAmtDue -- include GainLoss in the GrossAmountDue column
		, CASE WHEN o.RecType = -1 THEN -1 * o.DiscAmt Else o.DiscAmt End AS Discount
		, CASE WHEN o.RecType = -2 THEN o.Amt ELSE 0 END AS Payments
		, CASE WHEN o.RecType = -1 THEN o.Amt ELSE 0 END AS Credits
		, CASE WHEN o.RecType > 0 THEN o.Amt ELSE 0 END 
			- CASE WHEN o.RecType < 0 THEN o.Amt ELSE 0 END AS Balance -- catch credit memo/payment/GainLoss (-1, -2, -3)
		FROM #tmpCustomerList c INNER JOIN dbo.tblArOpenInvoice o (NOLOCK)	ON c.CustId = o.CustId 
			INNER JOIN #tmp t ON t.CustId = o.CustId AND t.InvcNum = o.InvcNum 
		WHERE o.Status <> 4 AND c.AcctType = 0 AND ((t.AmtFgn <> 0 AND @ExcludePaidInvoices = 1) OR @ExcludePaidInvoices = 0) 
			AND (((o.SourceApp = 0 OR o.SourceApp = 1 OR o.SourceApp = 4) AND @PrintSales = 1) 
				OR (o.SourceApp = 3 AND @PrintProjects = 1) OR (o.SourceApp = 2 AND @PrintService = 1))
				AND ((o.RecType<>5 AND @IncludeRegularInvcType=1)OR (o.RecType=5 AND  @IncludeProformaInvcType=1))
	END
	ELSE
	BEGIN
		-- foreign currency amounts
		SELECT c.CustId, c.CustName, o.PmtMethodId, o.CurrencyId, o.RecType, o.Status
			, o.TransDate, o.NetDueDate, o.DiscDueDate, o.InvcNum, o.SourceApp
			, CASE WHEN o.RecType > 0 THEN o.AmtFgn ELSE 0 END AS GrossAmtDue
			, CASE WHEN o.RecType = -1 THEN -1 * o.DiscAmtFgn ELSE o.DiscAmtFgn END AS Discount
			, CASE WHEN o.RecType = -2 THEN o.AmtFgn ELSE 0 END AS Payments
			, CASE WHEN o.RecType = -1 THEN o.AmtFgn ELSE 0 END AS Credits
			, CASE WHEN o.RecType > 0 THEN o.AmtFgn ELSE 0 END 
				- CASE WHEN o.RecType = -2 THEN o.AmtFgn ELSE 0 END 
				- CASE WHEN o.RecType = -1 THEN o.AmtFgn ELSE 0 END AS Balance 
		FROM #tmpCustomerList c INNER JOIN dbo.tblArOpenInvoice o (NOLOCK)	ON c.CustId = o.CustId
			INNER JOIN #tmp t ON t.CustId = o.CustId AND t.InvcNum = o.InvcNum 
		WHERE o.Status <> 4 AND c.AcctType = 0 AND o.CurrencyId = @ReportCurrency AND RecType <> -3 --AmtFgn for Gain/Loss should be 0 so don't recalc them
			AND ((t.AmtFgn <> 0 AND @ExcludePaidInvoices = 1) OR @ExcludePaidInvoices = 0) 
			AND (((o.SourceApp = 0 OR o.SourceApp = 1 OR o.SourceApp = 4) AND @PrintSales = 1) 
				OR (o.SourceApp = 3 AND @PrintProjects = 1) OR (o.SourceApp = 2 AND @PrintService = 1))
				AND ((o.RecType<>5 AND @IncludeRegularInvcType=1)OR (o.RecType=5 AND  @IncludeProformaInvcType=1))
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArOpenInvoiceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArOpenInvoiceReport_proc';

