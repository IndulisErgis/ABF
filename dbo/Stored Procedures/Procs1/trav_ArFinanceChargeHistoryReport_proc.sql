
CREATE PROCEDURE dbo.trav_ArFinanceChargeHistoryReport_proc
@FiscalPeriodFrom smallint = 0,
@FiscalPeriodThru smallint = 366,
@FiscalYearFrom smallint = 0,
@FiscalYearThru smallint = 9999,
@TransactionDateFrom datetime = '19000101',
@TransactionDateThru datetime = '21991231'
AS
SET NOCOUNT ON
BEGIN TRY

--process expects the list of customer to process to be provided via the following temporary table
--Create Table #tmpCustomerList (CustId pCustId, CustName nvarchar(30))

DECLARE @FiscalFrom int, @FiscalThru int
SELECT @FiscalFrom = (ISNULL(@FiscalYearFrom, 0) * 1000) + ISNULL(@FiscalPeriodFrom, 0)
	, @FiscalThru = (ISNULL(@FiscalYearThru, 0) * 1000) + ISNULL(@FiscalPeriodThru, 0)

SELECT l.CustId, h.FinchDate, h.FinchAmt, h.GLPeriod
FROM #tmpCustomerList l
INNER JOIN dbo.tblArHistFinch h on l.CustId = h.CustId
WHERE (h.FiscalYear * 1000) + h.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru
	AND h.FinchDate BETWEEN @TransactionDateFrom AND @TransactionDateThru


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArFinanceChargeHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArFinanceChargeHistoryReport_proc';

