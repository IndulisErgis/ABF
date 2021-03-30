
CREATE PROCEDURE dbo.trav_ApOpenInvoiceReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD', --Base currency when @PrintAllInBase = 1
@PrintInvoiceStatus tinyint = 4,--0, Released Invoices;1, Held Invoices;2, Temporary Hold Invoices;3, Prepaid Invoices;4, All Invoices
@InvoiceDueDate datetime = '20081203',
@DiscountDueDate datetime = '20081203'
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmp 
	(
		Counter int NOT NULL, 
		VendorID pVendorID NOT NULL, 
		Ten99InvoiceYN bit NULL DEFAULT (0), 
		InvoiceNo pInvoiceNum NOT NULL, 
		InvoiceDate datetime NULL DEFAULT (GETDATE()), 
		DiscDueDate datetime NULL, 
		NetDueDate datetime NULL, 
		InvoiceStatus tinyint NULL DEFAULT (0), 
		ExchRate pDecimal NULL DEFAULT (1), 
		CurrencyId pCurrency NOT NULL, 
		CurrentBalance pDecimal NULL DEFAULT (0), 
		Discount pDecimal NULL DEFAULT (0), 
		GrossDueAmt pDecimal NULL DEFAULT (0), 
		Payments pDecimal NULL DEFAULT (0), 
		NetDue pDecimal NULL DEFAULT (0) 
	)

	INSERT INTO #tmp (Counter, VendorID, Ten99InvoiceYN, InvoiceNo, InvoiceDate, DiscDueDate
		, NetDueDate, InvoiceStatus, ExchRate, CurrencyId, CurrentBalance, Discount, GrossDueAmt, Payments, NetDue) 
	SELECT o.Counter, o.VendorID, o.Ten99InvoiceYN, o.InvoiceNum, o.InvoiceDate, o.DiscDueDate
		, o.NetDueDate, o.Status, o.ExchRate, CASE WHEN @PrintAllInBase = 1 THEN @ReportCurrency ELSE o.CurrencyId END CurrencyId
		, 0 AS CurrentBalance
		, CASE WHEN o.DiscDueDate >= @DiscountDueDate 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN o.DiscAmt ELSE o.DiscAmtFgn END) ELSE 0 END AS Discount
		, CASE WHEN o.Status < 3 THEN (CASE WHEN @PrintAllInBase = 1 THEN o.GrossAmtDue ELSE o.GrossAmtDuefgn END) 
			ELSE 0 END AS GrossDueAmt
		, CASE WHEN o.Status = 3 THEN (CASE WHEN @PrintAllInBase = 1 THEN o.GrossAmtDue ELSE o.GrossAmtDuefgn END) 
			ELSE 0 END AS Payments
		, CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN o.DiscDueDate >= @DiscountDueDate AND o.Status < 3 
					THEN (o.GrossAmtDue - o.DiscAmt) WHEN o.Status = 3 THEN 0 ELSE o.GrossAmtDue END 
				ELSE CASE WHEN o.DiscDueDate >= @DiscountDueDate AND o.Status < 3 THEN (o.GrossAmtDuefgn - o.DiscAmtfgn) 
					WHEN o.Status = 3 THEN 0 ELSE o.GrossAmtDuefgn END 
			END AS NetDue 
	FROM #tmpVendorList t INNER JOIN tblApOpenInvoice o ON t.VendorID = o.VendorID 
	WHERE (o.NetDueDate <= @InvoiceDueDate OR o.GrossAmtDue < 0 
			OR (o.DiscAmt > 0 AND o.DiscDueDate BETWEEN @DiscountDueDate AND @InvoiceDueDate)) 
		AND o.Status = (CASE WHEN @PrintInvoiceStatus = 4 THEN o.Status ELSE @PrintInvoiceStatus END) 
		AND o.Status <> 4  AND (@PrintAllInBase = 1 OR o.CurrencyId = @ReportCurrency)

	UPDATE #tmp SET CurrentBalance = CASE WHEN @PrintAllInBase = 1 THEN v.GrossDue ELSE v.GrossDueFgn END 
	FROM #tmp z 
		INNER JOIN dbo.tblApVendor v ON z.VendorID = v.VendorID 
		INNER JOIN (SELECT MIN(Counter) AS Counter, VendorID FROM #tmp GROUP BY VendorID) x ON z.Counter = x.Counter

	SELECT o.VendorID, l.Name as VendorName, Ten99InvoiceYN, InvoiceNo, InvoiceDate, DiscDueDate, NetDueDate
		, InvoiceStatus, Cast((ExchRate) AS float) ExchRate, CurrencyId, CurrentBalance, Discount, GrossDueAmt, Payments, NetDue 
	FROM #tmp o inner join #tmpVendorList l on o.VendorID=l.VendorId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApOpenInvoiceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApOpenInvoiceReport_proc';

