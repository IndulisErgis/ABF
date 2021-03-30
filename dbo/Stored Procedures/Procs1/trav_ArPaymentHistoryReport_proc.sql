
CREATE PROCEDURE dbo.trav_ArPaymentHistoryReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD', --Base currency WHEN @PrintAllInBase = 1
@IncludeVoid tinyint = 0, -- 0 = Transactions, 1 = Voids, 2 = Both
@FiscalPeriodFrom smallint = 0,
@FiscalPeriodThru smallint = 366,
@FiscalYearFrom smallint = 0,
@FiscalYearThru smallint = 9999,
@TransactionDateFrom datetime = '19000101',
@TransactionDateThru datetime = '21991231',
@IncludeCustomer bit = 1
AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #temp
(
	CustId pCustID NULL,
	PmtDate datetime,
	Rep1Id pSalesRep,
	Rep2Id pSalesRep,
	CheckNum  pCheckNum,
	InvcNum pInvoiceNum,
	TransId pTransID,
	Disc  pDec,
	PmtAmt pDec,
	VoidYn bit
)

--process expects the list of customer to process to be provided via the following temporary table
--Create Table #tmpCustomerList (CustId pCustId, CustName nvarchar(30))

DECLARE @FiscalFrom int, @FiscalThru int
SELECT @FiscalFrom = (ISNULL(@FiscalYearFrom, 0) * 1000) + ISNULL(@FiscalPeriodFrom, 0)
	, @FiscalThru = (ISNULL(@FiscalYearThru, 0) * 1000) + ISNULL(@FiscalPeriodThru, 0)

INSERT INTO #temp (CustId, PmtDate, Rep1Id, Rep2Id, CheckNum, InvcNum, TransId, Disc, PmtAmt, VoidYn)
SELECT l.CustId, p.PmtDate, p.Rep1Id, p.Rep2Id, p.CheckNum, p.InvcNum, p.TransId
	, CASE WHEN @PrintAllInBase = 1 THEN DiffDisc ELSE DiffDiscFgn END AS Disc
	, CASE WHEN @PrintAllInBase = 1 THEN PmtAmt ELSE PmtAmtFgn END AS PmtAmt
	, p.VoidYn
FROM #tmpCustomerList l
INNER JOIN dbo.tblArHistPmt p on l.CustId = p.CustId
WHERE (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND p.CurrencyId = @ReportCurrency))
	AND ((p.VoidYn = 0 AND @IncludeVoid = 0) OR (p.VoidYn = 1 AND @IncludeVoid = 1) OR (@IncludeVoid = 2)) --conditionally process voids --PET:http://webfront:801/view.php?id=230902
	AND (p.FiscalYear * 1000) + p.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru
	AND p.PmtDate BETWEEN @TransactionDateFrom AND @TransactionDateThru		

IF @IncludeCustomer = 1
BEGIN
	INSERT INTO #temp (CustId, PmtDate, Rep1Id, Rep2Id, CheckNum, InvcNum, TransId, Disc, PmtAmt, VoidYn)
	SELECT null, p.PmtDate, p.Rep1Id, p.Rep2Id, p.CheckNum, p.InvcNum, p.TransId
		, CASE WHEN @PrintAllInBase = 1 THEN DiffDisc ELSE DiffDiscFgn END AS Disc
		, CASE WHEN @PrintAllInBase = 1 THEN PmtAmt ELSE PmtAmtFgn END AS PmtAmt
		, p.VoidYn
	FROM dbo.tblArHistPmt p 
	WHERE (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND p.CurrencyId = @ReportCurrency))
		AND ((p.VoidYn = 0 AND @IncludeVoid = 0) OR (p.VoidYn = 1 AND @IncludeVoid = 1) OR (@IncludeVoid = 2)) --conditionally process voids --PET:http://webfront:801/view.php?id=230902
		AND (p.FiscalYear * 1000) + p.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru
		AND p.PmtDate BETWEEN @TransactionDateFrom AND @TransactionDateThru
		AND p.CustId IS NULL		
END

SELECT CustId, PmtDate, Rep1Id, Rep2Id, CheckNum, InvcNum, TransId, Disc, PmtAmt, VoidYn FROM #temp

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPaymentHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPaymentHistoryReport_proc';

