
CREATE PROCEDURE dbo.trav_ArFinanceChargeHistoryReport2_proc
@FiscalPeriodFrom smallint, 
@FiscalPeriodThru smallint, 
@FiscalYearFrom smallint, 
@FiscalYearThru smallint, 
@TransactionDateFrom datetime, 
@TransactionDateThru datetime

AS
BEGIN TRY
	SET NOCOUNT ON

	-- process expects the list of customer to process to be provided via the following temporary table
	-- Create Table #tmpCustomerList (CustId pCustId, CustName nvarchar(30))

	--CREATE TABLE #tmpCustomerList( CustId pCustId NOT NULL, CustName nvarchar(255) NULL, AcctType tinyint NULL PRIMARY KEY CLUSTERED ([CustId]))
	--INSERT INTO #tmpCustomerList (CustId,CustName,AcctType) SELECT CustId,CustName,AcctType FROM dbo.tblArCust

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
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArFinanceChargeHistoryReport2_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArFinanceChargeHistoryReport2_proc';

