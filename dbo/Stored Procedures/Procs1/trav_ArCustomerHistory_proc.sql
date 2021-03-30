
CREATE PROCEDURE dbo.trav_ArCustomerHistory_proc
@CustId pCustID, 
@FiscalYear smallint,
@ConsolidateYn bit = 0 --option to include invoices billed to another customer id
AS

SET NOCOUNT ON
BEGIN TRY
	--PET:http://webfront:801/view.php?id=238922

	--Returns the Customer/FGN values from Hist tables for current Customer and FiscalYear

	CREATE TABLE #HistSummary
	(
		CustId pCustId,
		FiscalYear smallint,
		FiscalPeriod smallint,
		CurrencyId pCurrency,
		Sales pDecimal,
		COGS pDecimal,
		InvoiceCount int,
		Payments pDecimal,
		Discounts pDecimal,
		PaymentCount int,
		DaysToPay int,
		UnpaidFinch pDecimal
	)
		
	--capture invoice information 
	--	(include both the BillTo and SoldTo when processing consolidated results)
	INSERT INTO #HistSummary (CustId, FiscalYear, FiscalPeriod, CurrencyId
		, Sales, COGS, InvoiceCount, Payments, Discounts, PaymentCount, DaysToPay, UnpaidFinch)
	SELECT @CustId, FiscalYear, GLPeriod AS [FiscalPeriod], CurrencyID
		, SUM(SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn)) AS [Sales]
		, SUM(SIGN(TransType) * TotCostFgn) AS [COGS]
		, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) AS [InvoiceCount]
		, 0 AS [Payments], 0 AS [Discounts], 0 AS [PaymentCount], 0 AS [DaysToPay]
		, 0 AS [UnpaidFinch]
		FROM dbo.tblArHistHeader
		WHERE (CustId = @CustId OR (SoldToId = @CustId AND @ConsolidateYn = 1)) --include SoldTo as well as Billto Customers when consolidated
			AND FiscalYear = @FiscalYear AND VoidYn = 0
		GROUP BY CustId, FiscalYear, GlPeriod, CurrencyID

	--capture payment information
	INSERT INTO #HistSummary (CustId, FiscalYear, FiscalPeriod, CurrencyId
		, Sales, COGS, InvoiceCount, Payments, Discounts, PaymentCount, DaysToPay, UnpaidFinch)
	SELECT p.CustId, p.FiscalYear, p.GLPeriod AS [FiscalPeriod], p.CurrencyId
		, 0 AS [Sales], 0 AS [COGS], 0 AS [InvoiceCount]
		, SUM(p.PmtAmtFgn) AS [Payments]
		, SUM(p.DiffDiscFgn) AS [Discounts]
		, COUNT(1) AS [PaymentCount]
		, SUM(CASE WHEN p.PmtDate > h.InvcDate THEN DATEDIFF(dy, h.InvcDate, p.PmtDate) ELSE 0 END) AS [DaysToPay]
		, 0 AS [UnpaidFinch]
		FROM dbo.tblArHistPmt p 
		LEFT JOIN (
			SELECT CustId, InvcNum, MAX(InvcDate) AS [InvcDate] 
			FROM dbo.tblArHistHeader 
			WHERE CustId = @CustId AND FiscalYear <= @FiscalYear AND TransType = 1 AND VoidYn = 0 
			GROUP BY Custid, InvcNum
		) h ON p.CustId = h.CustId AND p.InvcNum = h.InvcNum
		WHERE p.CustId = @CustId AND p.FiscalYear = @FiscalYear AND p.VoidYn = 0 
		GROUP BY p.CustId, p.FiscalYear, p.GlPeriod, p.CurrencyId

	--capture finance charges
	INSERT INTO #HistSummary (CustId, FiscalYear, FiscalPeriod, CurrencyId
		, Sales, COGS, InvoiceCount, Payments, Discounts, PaymentCount, DaysToPay, UnpaidFinch)
	SELECT CustId, FiscalYear, GLPeriod AS [FiscalPeriod], CurrencyId
		, 0 AS [Sales], 0 AS [COGS], 0 AS [InvoiceCount]
		, 0 AS [Payments], 0 AS [Discounts], 0 AS [PaymentCount], 0 AS [DaysToPay]
		, SUM(FinchAmtFgn) AS [UnpaidFinch]
		FROM dbo.tblArHistFinch 
		WHERE CustID = @CustId AND FiscalYear = @FiscalYear
		GROUP BY CustId, FiscalYear, GlPeriod, CurrencyId


	--return the results
	SELECT CustId, FiscalYear, FiscalPeriod, CurrencyID
		, SUM([Sales]) AS [Sales], SUM([COGS]) AS [COGS]
		, SUM([Sales] - [COGS]) AS [Profit], SUM([InvoiceCount]) AS [InvoiceCount]
		, SUM([Payments]) AS [Payments], SUM([Discounts]) AS [Discounts]
		, SUM([PaymentCount]) AS [PaymentCount], SUM([DaysToPay]) AS [DaysToPay]
		, SUM([UnpaidFinch]) AS [UnpaidFinch]
	FROM #HistSummary
	GROUP BY CustId, FiscalYear, FiscalPeriod, CurrencyId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerHistory_proc';

