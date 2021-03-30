--PET: http://problemtrackingsystem.osas.com/view.php?id=265783
CREATE PROCEDURE dbo.trav_SoDailySalesTaxJournal_proc
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpSoDailyTax
	(
		TaxLocId pTaxLoc NOT NULL, 
		TaxClass tinyint NOT NULL DEFAULT (0), 
		TaxableAmt pDecimal NULL DEFAULT (0), 
		NontaxableAmt pDecimal NULL DEFAULT (0), 
		TaxCollected pDecimal NULL DEFAULT (0), 
		TaxCalculated pDecimal NULL DEFAULT (0)
	)

	INSERT INTO #tmpSoDailyTax (TaxLocId, TaxClass, TaxableAmt, NontaxableAmt, TaxCollected, TaxCalculated) 
	SELECT t.TaxLocID, t.TaxClass
		, SUM(SIGN(TransType) * Taxable) AS TaxableAmt
		, SUM(SIGN(TransType) * NonTaxable) AS NontaxableAmt
		, SUM(SIGN(TransType) * TaxAmt) AS TaxCollected
		, SUM(SIGN(TransType) * TaxAmt) AS TaxCalculated 
	FROM #tmpTransactionList m INNER JOIN dbo.tblSoTransHeader h ON m.TransId = h.TransId
			INNER JOIN dbo.tblSoTransTax t ON h.TransId = t.TransId
			INNER JOIN #tmpTaxLocactionList l ON t.TaxLocID = l.TaxLocID
	WHERE (h.TransType = 1 OR h.TransType = -1 OR h.TransType = 4) AND h.VoidYn = 0 
		AND (t.Taxable <> 0 OR t.NonTaxable <> 0) 
		AND (h.OrderState = 0 OR h.OrderState & 4 = 4 )
	GROUP BY t.TaxLocID, t.TaxClass

	INSERT INTO #tmpSoDailyTax (TaxLocId, TaxClass, TaxableAmt, NontaxableAmt, TaxCollected, TaxCalculated) 
	SELECT h.TaxLocAdj, h.TaxClassAdj, 0 AS TaxableAmt, 0 AS NontaxableAmt
		, SIGN(TransType) * TaxAmtAdj AS TaxCollected, 0 AS TaxCalculated 
	FROM #tmpTransactionList m INNER JOIN dbo.tblSoTransHeader h ON m.TransId = h.TransId
		INNER JOIN #tmpTaxLocactionList l ON h.TaxLocAdj = l.TaxLocID
	WHERE h.TaxLocAdj IS NOT NULL AND (h.TransType = 1 OR h.TransType = -1 OR h.TransType = 4) AND h.VoidYn = 0 
		AND h.TaxAmtAdj <> 0 AND (h.OrderState = 0 OR h.OrderState & 4 = 4 ) 

	SELECT t.TaxLocId, t.[Name], t.TaxAuthority, t.TaxId, t.GLAcct
		, CAST(t.TaxOnFreight AS tinyint) AS TaxOnFreight, CAST(t.TaxOnMisc AS tinyint) AS TaxOnMisc
		, c.TaxClassCode, c.[Desc], d.SalesTaxPct
		, SUM(x.TaxableAmt) AS TaxableAmt
		, SUM(x.NontaxableAmt) AS NontaxableAmt
		, SUM(x.TaxCollected) AS TaxCollected
		, SUM(x.TaxCalculated) AS TaxCalculated 
	FROM dbo.tblSmTaxLoc t INNER JOIN dbo.tblSmTaxLocDetail d ON t.TaxLocId = d.TaxLocId 
		INNER JOIN #tmpSoDailyTax x ON d.TaxLocId = x.TaxLocID AND d.TaxClassCode = x.TaxClass
		INNER JOIN dbo.tblSmTaxClass c ON d.TaxClassCode = c.TaxClassCode
	GROUP BY t.TaxLocId, t.[Name], t.TaxAuthority, t.TaxId, t.GLAcct, CAST(t.TaxOnFreight AS tinyint)
		, CAST(t.TaxOnMisc AS tinyint), c.TaxClassCode, c.[Desc], d.SalesTaxPct 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoDailySalesTaxJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoDailySalesTaxJournal_proc';

