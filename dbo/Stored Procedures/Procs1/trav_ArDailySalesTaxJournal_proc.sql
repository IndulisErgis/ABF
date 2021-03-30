
CREATE PROCEDURE dbo.trav_ArDailySalesTaxJournal_proc
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpArDailyTax
	(
		TaxLocId pTaxLoc NOT NULL, 
		TaxClass tinyint NOT NULL DEFAULT (0), 
		TaxableAmt pDecimal NULL DEFAULT (0), 
		NontaxableAmt pDecimal NULL DEFAULT (0), 
		TaxCollected pDecimal NULL DEFAULT (0), 
		TaxCalculated pDecimal NULL DEFAULT (0)
	)

	INSERT INTO #tmpArDailyTax (TaxLocId, TaxClass, TaxableAmt, NontaxableAmt, TaxCollected, TaxCalculated) 
	SELECT t.TaxLocID, t.TaxClass
		, SUM(SIGN(TransType) * Taxable) AS TaxableAmt
		, SUM(SIGN(TransType) * NonTaxable) AS NontaxableAmt
		, SUM(SIGN(TransType) * TaxAmt) AS TaxCollected
		, SUM(SIGN(TransType) * TaxAmt) AS TaxCalculated 
	FROM #tmpTransactionList m INNER JOIN dbo.tblArTransHeader h ON m.TransId = h.TransId
		INNER JOIN dbo.tblArTransTax t ON h.TransId = t.TransId
		INNER JOIN #tmpTaxLocactionList l ON t.TaxLocID = l.TaxLocID 
	WHERE h.VoidYn = 0 AND (t.Taxable <> 0 OR t.NonTaxable <> 0)
	GROUP BY t.TaxLocID, t.TaxClass

	INSERT INTO #tmpArDailyTax (TaxLocId, TaxClass, TaxableAmt, NontaxableAmt, TaxCollected, TaxCalculated) 
	SELECT h.TaxLocAdj, h.TaxClassAdj, 0 AS TaxableAmt, 0 AS NontaxableAmt
		, SIGN(TransType) * TaxAmtAdj AS TaxCollected, 0 AS TaxCalculated 
	FROM #tmpTransactionList m INNER JOIN dbo.tblArTransHeader h ON m.TransId = h.TransId
		INNER JOIN #tmpTaxLocactionList l ON h.TaxLocAdj = l.TaxLocID
	WHERE h.VoidYn = 0 AND h.TaxAmtAdj <> 0

	SELECT t.TaxLocId, t.[Name], t.TaxAuthority, t.TaxId, t.GLAcct
		, CAST(t.TaxOnFreight AS tinyint) AS TaxOnFreight, CAST(t.TaxOnMisc AS tinyint) AS TaxOnMisc
		, c.TaxClassCode, c.[Desc], d.SalesTaxPct
		, CAST(SUM(x.TaxableAmt) AS float) AS TaxableAmt
		, CAST(SUM(x.NontaxableAmt) AS float) AS NontaxableAmt
		, CAST(SUM(x.TaxCollected) AS float) AS TaxCollected
		, CAST(SUM(x.TaxCalculated) AS float) AS TaxCalculated 
	FROM dbo.tblSmTaxLoc t 
		INNER JOIN (dbo.tblSmTaxClass c 
			INNER JOIN (dbo.tblSmTaxLocDetail d 
			INNER JOIN #tmpArDailyTax x ON (d.TaxClassCode = x.TaxClass) 
				AND (d.TaxLocId = x.TaxLocID)) 
				ON c.TaxClassCode = d.TaxClassCode) 
			ON t.TaxLocId = d.TaxLocId 
	GROUP BY t.TaxLocId, t.[Name], t.TaxAuthority, t.TaxId, t.GLAcct, CAST(t.TaxOnFreight AS tinyint)
		, CAST(t.TaxOnMisc AS tinyint), c.TaxClassCode, c.[Desc], d.SalesTaxPct 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDailySalesTaxJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDailySalesTaxJournal_proc';

