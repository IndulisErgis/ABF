
CREATE PROCEDURE dbo.trav_PoDailySalesTaxJournal_proc
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpPoDailyTax
	(
		TaxLocId nvarchar (10) NOT NULL, 
		TaxClass tinyint NOT NULL, 
		TaxableAmt pDecimal NOT NULL, 
		NontaxableAmt pDecimal NOT NULL, 
		TaxCalculated pDecimal NOT NULL, 
		TaxPaid pDecimal NOT NULL, 
		TaxRefundable pDecimal NOT NULL
	)

	CREATE TABLE #tmpPoDailyTaxRpt
	(
		TaxLocId nvarchar (10) NOT NULL, 
		TaxClass tinyint NOT NULL, 
		TaxableAmt pDecimal NOT NULL, 
		NontaxableAmt pDecimal NOT NULL, 
		TaxCalculated pDecimal NOT NULL, 
		TaxPaid pDecimal NOT NULL, 
		TaxRefundable pDecimal NOT NULL
	)

	INSERT INTO #tmpPoDailyTax (TaxLocId, TaxClass, TaxableAmt, NontaxableAmt, TaxCalculated, TaxPaid, TaxRefundable) 
	SELECT x.TaxLocID, x.TaxClass, SIGN(h.TransType) * x.CurrTaxable, SIGN(h.TransType) * x.CurrNonTaxable
		, SIGN(h.TransType) * x.CurrTaxAmt, SIGN(h.TransType) * x.CurrTaxAmt, SIGN(h.TransType) * x.CurrRefundable 
	FROM #tmpTransactionList t INNER JOIN dbo.tblPoTransHeader h ON t.TransId = h.TransId
		INNER JOIN 
			(SELECT DISTINCT TransId, InvoiceNum FROM dbo.tblPoTransInvoice WHERE [Status] = 0) i ON h.TransId = i.TransId 
		INNER JOIN dbo.tblPoTransInvoiceTax x ON i.TransId = x.TransId AND i.InvoiceNum = x.InvcNum  
		INNER JOIN #tmpTaxLocactionList l ON x.TaxLocID = l.TaxLocID
	WHERE (x.CurrTaxable <> 0 OR x.CurrNonTaxable <> 0)

	INSERT INTO #tmpPoDailyTax (TaxLocId, TaxClass, TaxableAmt, NontaxableAmt, TaxCalculated, TaxPaid, TaxRefundable) 
	SELECT t.CurrTaxAdjLocID, t.CurrTaxAdjClass, 0, 0, 0, SIGN(TransType) * t.CurrTaxAdjAmt, 0 
	FROM #tmpTransactionList m INNER JOIN dbo.tblPoTransHeader h ON m.TransId = h.TransId
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
		INNER JOIN #tmpTaxLocactionList l ON t.CurrTaxAdjLocID = l.TaxLocID
	WHERE t.Status = 0 AND t.CurrTaxAdjAmt <> 0

	INSERT INTO #tmpPoDailyTaxRpt (TaxLocId, TaxClass, TaxableAmt, NontaxableAmt, TaxCalculated, TaxPaid, TaxRefundable) 
	SELECT TaxLocID, TaxClass, SUM(TaxableAmt), SUM(NontaxableAmt), SUM(TaxCalculated), SUM(TaxPaid), SUM(TaxRefundable) 
	FROM #tmpPoDailyTax 
	GROUP BY TaxLocID, TaxClass

	SELECT t.TaxLocId, t.TaxClass, t.TaxableAmt, t.NontaxableAmt, t.TaxCalculated, t.TaxPaid, t.TaxRefundable, 
		d.PurchTaxPct, d.RefundPct, l.Name AS TaxLocDesc, l.TaxAuthority, l.TaxId , l.TaxOnFreight, l.TaxOnMisc,
		l.TaxRefAcct, c.[Desc] AS ClassDesc, t.TaxPaid - t.TaxCalculated AS OverShort 
	FROM #tmpPoDailyTaxRpt t INNER JOIN dbo.tblSmTaxLoc l ON t.TaxLocID = l.TaxLocID 
		INNER JOIN dbo.tblSmTaxLocDetail d ON t.TaxLocID = d.TaxLocID AND t.TaxClass = d.TaxClassCode 
		INNER JOIN dbo.tblSmTaxClass c ON t.TaxClass = c.TaxClassCode

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoDailySalesTaxJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoDailySalesTaxJournal_proc';

