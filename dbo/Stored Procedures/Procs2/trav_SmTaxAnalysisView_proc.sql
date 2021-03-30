
CREATE PROCEDURE [dbo].[trav_SmTaxAnalysisView_proc]
@TransactionOption tinyint, 
@TransactionDateFrom datetime, 
@TransactionDateThru datetime, 
@TransactionFiscalPeriodFrom smallint, 
@TransactionFiscalYearFrom smallint, 
@TransactionFiscalPeriodThru smallint, 
@TransactionFiscalYearThru smallint

AS

SET NOCOUNT ON
BEGIN TRY

	SELECT t.TaxLocId, l.[Name], l.GLAcct, l.TaxRefAcct, t.TaxClassCode, d.ExpenseAcct, t.TransDate
		, t.GLPeriod, t.FiscalYear, t.SourceCode, t.LinkID
		, ISNULL(t.TaxSales, 0) TaxableSales, ISNULL(t.NonTaxSales, 0) NontaxSales
		, ISNULL(t.TaxCollect, 0) TaxCollected, ISNULL(t.TaxPurch, 0) TaxablePurch
		, ISNULL(t.NonTaxPurch, 0) NontaxPurch, ISNULL(t.TaxPaid, 0) TaxPaid
		, ISNULL(t.TaxRefund, 0) TaxRefundable 
	FROM #tmpTaxLoc tmp 
	INNER JOIN dbo.tblSmTaxLoc l ON l.TaxLocId = tmp.TaxLocId 
		INNER JOIN dbo.tblSmTaxLocTrans t ON tmp.TaxLocId = t.TaxLocId 
	 INNER JOIN dbo.tblSmTaxLocDetail d ON t.TaxLocId = d.TaxLocId AND t.TaxClassCode = d.TaxClassCode
	WHERE ((t.TransDate BETWEEN @TransactionDateFrom AND @TransactionDateThru AND @TransactionOption = 0) OR @TransactionOption = 1) 
		AND ((((t.FiscalYear * 1000) + t.GLPeriod BETWEEN (@TransactionFiscalYearFrom * 1000) + @TransactionFiscalPeriodFrom 
			AND (@TransactionFiscalYearThru * 1000) + @TransactionFiscalPeriodThru) 
			AND @TransactionOption = 1) OR @TransactionOption = 0)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmTaxAnalysisView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmTaxAnalysisView_proc';

