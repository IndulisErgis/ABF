
CREATE PROCEDURE dbo.trav_ArCashFlowReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD', --Base currency WHEN @PrintAllInBase = 1
@PrintInvoiceStatus tinyint = 0,--0, All Invoices;1, Held Invoices
@PeriodDate1 datetime = '20090103',
@PeriodDate2 datetime = '20090202',
@PeriodDate3 datetime = '20090304',
@PeriodDate4 datetime = '20090403', 
@DistributionCodeFrom pDistCode, 
@DistributionCodeThru pDistCode
AS
SET NOCOUNT ON
BEGIN TRY

--PET:http://webfront:801/view.php?id=240902

	SELECT c.CustId, c.CustName, o.InvcNum, o.RecType, o.Status, o.TransDate, o.NetDueDate
		, CASE WHEN o.NetDueDate IS NULL THEN 0 ELSE 
			SIGN(o.RecType) * CASE WHEN @PrintAllInBase = 1 THEN o.Amt ELSE o.AmtFgn END END AS Balance
		, CASE WHEN o.NetDueDate IS NULL THEN 0 ELSE 
			CASE WHEN o.NetDueDate < @PeriodDate1 THEN SIGN(o.RecType) * CASE WHEN @PrintAllInBase = 1 THEN o.Amt ELSE o.AmtFgn END ELSE 0 END END As CurrentAmount
		, CASE WHEN o.NetDueDate IS NULL THEN 0 ELSE 
			CASE WHEN o.NetDueDate >= @PeriodDate1 AND o.NetDueDate < @PeriodDate2 THEN SIGN(o.RecType) * CASE WHEN @PrintAllInBase = 1 THEN o.Amt ELSE o.AmtFgn END ELSE 0 END END As Period1Amount
		, CASE WHEN o.NetDueDate IS NULL THEN 0 ELSE 
			CASE WHEN o.NetDueDate >= @PeriodDate2 AND o.NetDueDate < @PeriodDate3 THEN SIGN(o.RecType) * CASE WHEN @PrintAllInBase = 1 THEN o.Amt ELSE o.AmtFgn END ELSE 0 END END As Period2Amount
		, CASE WHEN o.NetDueDate IS NULL THEN 0 ELSE 
			CASE WHEN o.NetDueDate >= @PeriodDate3 AND o.NetDueDate < @PeriodDate4 THEN SIGN(o.RecType) * CASE WHEN @PrintAllInBase = 1 THEN o.Amt ELSE o.AmtFgn END ELSE 0 END END As Period3Amount
		, CASE WHEN o.NetDueDate IS NULL THEN 0 ELSE 
			CASE WHEN o.NetDueDate >= @PeriodDate4 THEN SIGN(o.RecType) * CASE WHEN @PrintAllInBase = 1 THEN o.Amt ELSE o.AmtFgn END ELSE 0 END END As Period4Amount
	FROM #tmpCustomerList t INNER JOIN dbo.tblArCust c (NOLOCK) ON t.CustId = c.CustId 
		INNER JOIN dbo.tblArOpenInvoice o (NOLOCK)	ON c.CustId = o.CustId
	WHERE ((o.Status = 1 AND @PrintInvoiceStatus = 1) OR (o.Status <> 4 AND @PrintInvoiceStatus <> 1))
		AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND o.CurrencyId = @ReportCurrency))
		AND c.AcctType <> 1 
		AND o.DistCode BETWEEN ISNULL(@DistributionCodeFrom, o.DistCode) AND ISNULL(@DistributionCodeThru, o.DistCode) --always apply filter to invoice distcode

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashFlowReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashFlowReport_proc';

