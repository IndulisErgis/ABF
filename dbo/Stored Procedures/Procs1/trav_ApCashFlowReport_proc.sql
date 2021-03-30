
CREATE PROCEDURE dbo.trav_ApCashFlowReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD', --Base currency WHEN @PrintAllInBase = 1
@PeriodDate1 datetime = '20090103',
@PeriodDate2 datetime = '20090202',
@PeriodDate3 datetime = '20090304',
@UseDiscountDates bit = 1,
@PrintInvoiceStatus tinyint = 3,--0, Released Invoices;1, Held Invoices;2, Temporary Hold Invoices;3, All Invoices
@WksDate datetime = '20081210'
AS
SET NOCOUNT ON
BEGIN TRY

--PET:http://webfront:801/view.php?id=239865

	CREATE TABLE #tmpApCashFlow
	(
		VendorID pVendorID NOT NULL, 
		InvoiceNum pInvoiceNum NOT NULL, 
		Status tinyint NULL DEFAULT (0), 
		Ten99InvoiceYN bit NULL DEFAULT (0), 
		DistCode pDistCode NULL, 
		InvoiceDate datetime NULL DEFAULT (GETDATE()), 
		DiscDueDate datetime NULL, 
		NetDueDate datetime NULL, 
		GrossAmtDue pDecimal NULL DEFAULT (0), 
		DiscAmt pDecimal NULL DEFAULT (0), 
		GrossAmtDueFgn pDecimal NULL DEFAULT (0), 
		DiscAmtFgn pDecimal NULL DEFAULT (0), 
		CheckNum pCheckNum NULL, 
		CheckDate datetime NULL, 
		CurrencyID pCurrency NOT NULL, 
		ExchRate pDecimal NULL DEFAULT (0), 
		GlPeriod smallint NULL DEFAULT (0), 
		FiscalYear smallint NULL DEFAULT (0), 
		TermsCode pTermsCode NULL, 
		DueDate datetime NULL, 
		Discounted bit NULL DEFAULT (0)
	)

	INSERT INTO #tmpApCashFlow (VendorID, InvoiceNum, [Status], Ten99InvoiceYN, DistCode, InvoiceDate, DiscDueDate, NetDueDate
		, GrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn, CheckNum, CheckDate, CurrencyID, ExchRate
		, GlPeriod, FiscalYear, TermsCode, DueDate, Discounted) 
	SELECT i.VendorID, i.InvoiceNum, i.[Status], i.Ten99InvoiceYN, i.DistCode, i.InvoiceDate, i.DiscDueDate, i.NetDueDate
		, i.GrossAmtDue, i.DiscAmt, i.GrossAmtDueFgn, i.DiscAmtFgn, i.CheckNum, i.CheckDate, i.CurrencyID, i.ExchRate
		, i.GlPeriod, i.FiscalYear, i.TermsCode
		, CASE WHEN @UseDiscountDates = 1 AND i.DiscDueDate >= @WksDate AND i.DiscAmt > 0 THEN i.DiscDueDate ElSE i.NetDueDate END AS DueDate
		, CASE WHEN @UseDiscountDates = 1 AND i.DiscDueDate >= @WksDate AND i.DiscAmt > 0 THEN 1 ELSE 0 END AS Discounted 
	FROM #tmpVendorList t INNER JOIN dbo.tblApOpenInvoice i ON t.VendorId = i.VendorId 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode
	WHERE i.[Status] = (CASE WHEN @PrintInvoiceStatus = 3 THEN i.[Status] ELSE @PrintInvoiceStatus END) 
		AND i.[Status] NOT IN (3, 4) AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	SELECT v.VendorID, v.[Name], t.CurrencyId, t.InvoiceNum, t.Status, t.InvoiceDate, t.NetDueDate, t.DiscDueDate
		, t.Discounted, CASE WHEN @PrintAllInBase = 1 THEN t.GrossAmtDue ELSE t.GrossAmtDueFgn END AS GrossAmountDue
		, CASE WHEN @PrintAllInBase = 1 THEN t.DiscAmt ELSE t.DiscAmtFgn END AS DiscAmount1
		, CASE WHEN t.DueDate <= @PeriodDate1 OR t.GrossAmtDue < 0 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.GrossAmtDue ELSE t.GrossAmtDueFgn END) ELSE 0 END AS PeriodGross1
		, CASE WHEN t.DueDate <= @PeriodDate1 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.DiscAmt ELSE t.DiscAmtFgn END) ELSE 0 END AS PeriodDisc1
		, CASE WHEN t.DueDate > @PeriodDate1 AND t.DueDate <= @PeriodDate2 AND GrossAmtDue >= 0 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.GrossAmtDue ELSE t.GrossAmtDueFgn END) ELSE 0 END AS PeriodGross2
		, CASE WHEN t.DueDate > @PeriodDate1 AND t.DueDate <= @PeriodDate2 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.DiscAmt ELSE t.DiscAmtFgn END) ELSE 0 END AS PeriodDisc2
		, CASE WHEN t.DueDate > @PeriodDate2 AND t.DueDate <= @PeriodDate3 AND GrossAmtDue >= 0 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.GrossAmtDue ELSE t.GrossAmtDueFgn END) ELSE 0 END AS PeriodGross3
		, CASE WHEN t.DueDate > @PeriodDate2 AND t.DueDate <= @PeriodDate3 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.DiscAmt ELSE t.DiscAmtFgn END) ELSE 0 END AS PeriodDisc3
		, CASE WHEN t.DueDate > @PeriodDate3 AND t.GrossAmtDue >= 0 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.GrossAmtDue ELSE t.GrossAmtDueFgn END) ELSE 0 END AS BeyondGross1
		, CASE WHEN t.DueDate > @PeriodDate3 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN t.DiscAmt ELSE t.DiscAmtFgn END) ELSE 0 END AS BeyondDisc1 
	FROM #tmpVendorList v INNER JOIN #tmpApCashFlow t ON v.VendorID = t.VendorID 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApCashFlowReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApCashFlowReport_proc';

