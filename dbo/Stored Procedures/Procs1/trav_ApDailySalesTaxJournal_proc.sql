
CREATE PROCEDURE dbo.trav_ApDailySalesTaxJournal_proc
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpApDailyTax
	(
		TransId pTransID NOT NULL, 
		BatchId pBatchID NOT NULL DEFAULT ('######'), 
		TransType smallint NULL DEFAULT (1), 
		TaxLocId pTaxLoc NOT NULL, 
		TaxClass tinyint NOT NULL DEFAULT (0), 
		TaxableAmt pDecimal NULL DEFAULT (0), 
		NontaxableAmt pDecimal NULL DEFAULT (0), 
		TaxCalculated pDecimal NULL DEFAULT (0), 
		TaxPaid pDecimal NULL DEFAULT (0), 
		TaxRefundable pDecimal NULL DEFAULT (0)
	)

	INSERT INTO #tmpApDailyTax (TransId, BatchId, TransType, TaxLocId, TaxClass, TaxableAmt, NontaxableAmt
		, TaxCalculated, TaxPaid, TaxRefundable) 
	SELECT h.TransId, h.BatchId, h.TransType, t.TaxLocID, t.TaxClass
		, SIGN(TransType) * t.Taxable AS TaxableAmt
		, SIGN(TransType) * t.NonTaxable AS NontaxableAmt
		, SIGN(TransType) * TaxAmt AS TaxCalculated
		, CASE WHEN (TaxAdjLocID = t.TaxLocID AND TaxAdjClass = t.TaxClass) 
			THEN SIGN(TransType) * (TaxAmt + TaxAdjAmt) ELSE SIGN(TransType) * TaxAmt END AS TaxPaid
		, SIGN(TransType) * t.Refundable AS TaxRefundable 
	FROM #tmpTransactionList m INNER JOIN dbo.tblApTransHeader h ON m.TransId = h.TransId
		INNER JOIN dbo.tblApTransInvoiceTax t ON h.TransId = t.TransId
		INNER JOIN #tmpTaxLocactionList l ON t.TaxLocID = l.TaxLocID 
	WHERE t.Taxable <> 0 OR t.NonTaxable <> 0

	INSERT INTO #tmpApDailyTax (TransId, BatchId, TransType, TaxLocId, TaxClass, TaxableAmt, NontaxableAmt
		, TaxCalculated, TaxPaid, TaxRefundable) 
	SELECT h.TransId, h.BatchId, h.TransType, h.TaxAdjLocID, h.TaxAdjClass, 0 AS TaxableAmt, 0 AS NontaxableAmt
		, 0 AS TaxCalculated, SIGN(h.TransType) * h.TaxAdjAmt AS TaxPaid, 0 AS TaxRefundable 
	FROM #tmpTransactionList m INNER JOIN dbo.tblApTransHeader h ON m.TransId = h.TransId
		INNER JOIN #tmpTaxLocactionList l ON h.TaxAdjLocID = l.TaxLocID
		LEFT JOIN #tmpApDailyTax z ON (h.TaxAdjLocID = z.TaxLocID) AND (h.TaxAdjClass = z.TaxClass) AND (h.TransId = z.TransId) 
	WHERE z.TaxClass IS NULL AND h.TaxAdjAmt <> 0

	SELECT x.TaxLocId, x.TaxClass, CAST(SUM(x.TaxableAmt) AS float) AS TaxableAmt
		, CAST(SUM(x.NontaxableAmt) AS float) AS NontaxableAmt, CAST(SUM(x.TaxCalculated) AS float) AS TaxCalculated
		, CAST(SUM(x.TaxPaid) AS float) AS TaxPaid, CAST(SUM(x.TaxRefundable) AS float) AS TaxRefundable
		, d.PurchTaxPct AS PurchTaxPct, d.RefundPct AS RefundPct, t.Name AS TaxLocDesc
		, t.TaxAuthority AS TaxAuthority, t.TaxId AS TaxId, CAST(t.TaxOnFreight AS smallint) AS TaxOnFreight
		, CAST(t.TaxOnMisc AS smallint) AS TaxOnMisc, t.GLAcct AS LiabilityAcct, t.TaxRefAcct AS TaxRefAcct
		, c.[Desc] AS ClassDesc 
	FROM ((dbo.tblSmTaxLoc t INNER JOIN #tmpApDailyTax x ON t.TaxLocId = x.TaxLocId) 
		INNER JOIN dbo.tblSmTaxClass c ON x.TaxClass = c.TaxClassCode) 
		INNER JOIN dbo.tblSmTaxLocDetail d ON (x.TaxClass = d.TaxClassCode) AND (x.TaxLocId = d.TaxLocId) 
	GROUP BY x.TaxLocId, x.TaxClass, d.PurchTaxPct, d.RefundPct, t.Name, t.TaxAuthority, t.TaxId
		, CAST(t.TaxOnFreight AS smallint), CAST(t.TaxOnMisc AS smallint), t.GLAcct, t.GLAcct, t.TaxRefAcct, c.[Desc] 
	ORDER BY x.TaxLocId, x.TaxClass

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApDailySalesTaxJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApDailySalesTaxJournal_proc';

