
CREATE PROCEDURE dbo.trav_ArTransPost_Tax_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'

	IF @PostRun IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Insert Tax Amounts
	INSERT dbo.tblSmTaxLocTrans (TaxLocId, TaxClassCode
		, PostRun, SourceCode, LinkID, LinkIDSub, LinkIDSubLine
		, TransDate, GLPeriod, FiscalYear, TaxSales, NonTaxSales
		, TaxCollect, TaxPurch, NonTaxPurch, TaxCalcSales, TaxPaid, TaxRefund)
	Select t.TaxLocID, t.TaxClass
		, @PostRun, 'AR', t.TransID, NULL, NULL
		, h.InvcDate, h.GLPeriod, h.FiscalYear
		, Sum((convert(decimal(28,10),SIGN(h.TransType)) * convert(decimal(28,10),t.Taxable)))
		, Sum((convert(decimal(28,10),SIGN(h.TransType)) * convert(decimal(28,10),t.NonTaxable)))
		, Sum((convert(decimal(28,10),SIGN(h.TransType)) * convert(decimal(28,10),t.TaxAmt)))
		, 0, 0
		, Sum((convert(decimal(28,10),SIGN(h.TransType)) * convert(decimal(28,10), t.TaxAmt)))
		, 0, 0
	FROM dbo.tblARTransHeader h 
	INNER JOIN dbo.tblArTransTax t ON h.TransId = t.TransId
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	GROUP BY t.TransID, t.TaxLocID, t.TaxClass,	h.InvcDate, h.GLPeriod, h.FiscalYear

	--Insert AdjAmount to TaxPaid
	INSERT dbo.tblSmTaxLocTrans (TaxLocId, TaxClassCode
		, PostRun, SourceCode, LinkID, LinkIDSub, LinkIDSubLine
		, TransDate, GLPeriod, FiscalYear, TaxSales, NonTaxSales
		, TaxCollect, TaxPurch, NonTaxPurch, TaxCalcSales, TaxPaid, TaxRefund)
	Select h.TaxLocAdj, h.TaxClassAdj
		, @PostRun, 'AR', h.TransID, NULL, NULL
		, h.InvcDate, h.GLPeriod, h.FiscalYear
		, 0, 0
		, Sum((convert(decimal(28,10),SIGN(h.TransType)) * convert(decimal(28,10), h.TaxAmtAdj)))
		, 0, 0, 0, 0, 0 
	FROM dbo.tblARTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	WHERE h.TaxAmtAdj <> 0 
	GROUP BY h.TransID, h.TaxLocAdj, h.TaxClassAdj, h.InvcDate, h.GLPeriod, h.FiscalYear

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_Tax_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_Tax_proc';

