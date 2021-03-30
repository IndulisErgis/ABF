
CREATE PROCEDURE [dbo].[trav_SmClearTax_proc]                
@Date datetime,
@PriorOption tinyint, --ENUM:1;Date;2;Fiscal Period/Year
@ClearOption tinyint, --ENUM:1;Sales;2;Purchase;3;Both
@FiscalYear smallint,
@FiscalPeriod smallint

AS
BEGIN TRY
            
IF(@ClearOption = 1 OR @ClearOption = 3) --Sales/Both
BEGIN
	DELETE dbo.tblSmTaxLocTrans 
		FROM dbo.tblSmTaxLocTrans t 
		INNER JOIN #tmpTaxLoc tmp ON tmp.TaxLocId = t.TaxLocId
	WHERE ((t.TransDate IS NOT NULL AND t.TransDate <= @Date AND @PriorOption = 1)
		OR (((t.FiscalYear * 1000) + t.GLPeriod) < ((@FiscalYear * 1000) + @FiscalPeriod) AND @PriorOption = 2))
		AND ((t.SourceCode = 'SM' AND (t.NonTaxSales + t.TaxSales + t.TaxCollect + t.TaxCalcSales <> 0))
		OR (t.SourceCode = 'AR' OR t.SourceCode = 'SO' OR t.SourceCode = 'SD' OR t.SourceCode = 'JC' OR t.SourceCode = 'PS'))
END   

IF(@ClearOption = 2 OR @ClearOption = 3) --Purchase/Both     
BEGIN
	DELETE dbo.tblSmTaxLocTrans 
		FROM dbo.tblSmTaxLocTrans t 
		INNER JOIN #tmpTaxLoc tmp ON tmp.TaxLocId = t.TaxLocId
	WHERE ((t.TransDate IS NOT NULL AND t.TransDate <= @Date AND @PriorOption = 1)
		OR (((t.FiscalYear * 1000) + t.GLPeriod) < ((@FiscalYear * 1000) + @FiscalPeriod) AND @PriorOption = 2))
		AND ((t.SourceCode = 'SM' AND (t.NonTaxPurch + t.TaxPurch + t.TaxPaid +	t.TaxRefund + t.TaxCalcPurch <> 0)) 
		OR	(t.SourceCode = 'AP' OR t.SourceCode = 'PO'))
END


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmClearTax_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmClearTax_proc';

