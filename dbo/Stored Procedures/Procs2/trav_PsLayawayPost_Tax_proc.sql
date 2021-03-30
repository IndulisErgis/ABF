
CREATE PROCEDURE dbo.trav_PsLayawayPost_Tax_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PostRun pPostRun, @FiscalYear smallint, @FiscalPeriod smallint

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'

	IF @PostRun IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Insert Tax Amounts
	INSERT dbo.tblSmTaxLocTrans (TaxLocId, TaxClassCode, PostRun, SourceCode, LinkID, LinkIDSub, LinkIDSubLine, TransDate, 
		GLPeriod, FiscalYear, TaxSales, NonTaxSales, TaxCollect, TaxPurch, NonTaxPurch, TaxCalcSales, TaxPaid, TaxRefund)
	SELECT x.TaxLocID, x.TaxClass, @PostRun, 'PS', t.TransID, NULL, NULL, h.TransDate, @FiscalPeriod, @FiscalYear, 
		SUM(x.Taxable), SUM(x.NonTaxable), SUM(x.TaxAmt), 0, 0, SUM(x.TaxAmt), 0, 0
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransTax x ON h.ID = x.HeaderID
	WHERE h.VoidDate IS NULL
	GROUP BY t.TransID, x.TaxLocID, x.TaxClass, h.TransDate

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_Tax_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_Tax_proc';

