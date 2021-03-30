
CREATE PROCEDURE dbo.trav_ArTransactionJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@PrintSalesJournal bit = 1,
@PrintDetail bit = 1,
@SortBy tinyint = 0 -- 0, Batch/Transaction Number; 1, Customer ID; 2, Invoice Number; 3 Fiscal Year/Fiscal Period/Sales Account; 4, Item ID
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpSales
	(
		TransId pTransID NOT NULL
	)

	INSERT INTO #tmpSales (TransId) 
	SELECT h.TransId 
	FROM #tmpCustomerList c INNER JOIN dbo.tblArTransHeader h ON c.CustId = h.CustId 
		INNER JOIN #tmpTransactionList b ON h.TransId = b.TransId 
	WHERE (@PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency) 
		AND h.TransType = CASE WHEN @PrintSalesJournal = 0 THEN -1 ELSE 1 END 
		AND h.VoidYn = 0

	SELECT 0 AS RecType
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.GlPeriod)), 3) AS nvarchar) 
		WHEN 4 THEN CAST(d.PartId AS nvarchar) END AS GrpId1
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(d.GLAcctSales AS nvarchar) 
		WHEN 4 THEN CAST(d.PartId AS nvarchar) END AS GrpId2
	, h.BatchId, h.TransId, h.TransType, h.CustId, c.CustName, h.ShipToID, h.TermsCode, h.InvcNum, h.OrgInvcNum
	, h.CustPONum, h.OrderDate, h.ShipDate, h.InvcDate, h.Rep1Id, h.Rep1Pct, h.Rep2Id, h.Rep2Pct
	, h.TaxClassFreight, h.GLPeriod, h.FiscalYear, h.TaxGrpID AS TaxLocId, h.ExchRate
	, 0 AS TaxSubtotal, 0 AS NonTaxSubtotal, 0 AS Freight, 0 AS Misc, 0 AS SalesTax, 0 AS PmtAmt, 0 AS InvTotal
	, d.EntryNum, d.PartType, d.PartId, d.WhseId, d.[Desc], d.AddnlDesc, d.LottedYn, d.TaxClass
	, d.GLAcctSales, d.GLAcctCOGS, d.GLAcctInv, d.UnitsSell, d.UnitsBase, d.QtyOrdSell, d.QtyShipSell
	, CASE WHEN @PrintAllInBase = 1 THEN UnitPriceSell ELSE UnitPriceSellFgn END AS UnitPriceSell
	, CASE WHEN @PrintAllInBase = 1 THEN PriceExt ELSE PriceExtFgn END AS ExtPrice
	, CASE WHEN @PrintAllInBase = 1 THEN UnitCostSell ELSE UnitCostSellFgn END AS UnitCostSell
	, CASE WHEN @PrintAllInBase = 1 THEN CostExt ELSE CostExtFgn END AS ExtCost, d.LineSeq 
	FROM dbo.tblArCust AS c INNER JOIN dbo.tblArTransHeader AS h ON c.CustId = h.CustId 
		INNER JOIN #tmpSales t ON h.TransId = t.TransId
		LEFT JOIN dbo.tblArTransDetail AS d ON h.TransId = d.TransID
	UNION ALL
	SELECT 1 AS RecType
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.GlPeriod)), 3) AS nvarchar) 
		WHEN 4 THEN CAST(NULL AS nvarchar) END AS GrpId1
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(NULL AS nvarchar) 
		WHEN 4 THEN CAST(NULL AS nvarchar) END AS GrpId2
	, h.BatchId, h.TransId, h.TransType, h.CustId, NULL AS CustName
	, h.ShipToID, h.TermsCode, h.InvcNum, h.OrgInvcNum, h.CustPONum, h.OrderDate, h.ShipDate, h.InvcDate
	, h.Rep1Id, h.Rep1Pct, h.Rep2Id, h.Rep2Pct, h.TaxClassFreight, h.GLPeriod, h.FiscalYear
	, h.TaxGrpID AS TaxLocId, h.ExchRate
	, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS TaxSubtotal --PET:http://webfront:801/view.php?id=225293
	, CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS NonTaxSubtotal
	, CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END AS Freight
	, CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END AS Misc
	, CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END AS SalesTax
	, CASE WHEN @PrintAllInBase = 1 THEN ISNULL(pmt.UnpostedPaymentTotal, 0) ELSE ISNULL(pmt.UnpostedPaymentTotalFgn, 0) END AS PmtAmt
	, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal + NonTaxSubtotal + Freight + Misc + SalesTax + TaxAmtAdj
		ELSE TaxSubtotalFgn + NonTaxSubtotalFgn + FreightFgn + MiscFgn + SalesTaxFgn + TaxAmtAdjFgn END AS InvTotal
	, 0 AS EntryNum, 0 AS PartType, NULL AS PartId, NULL AS WhseId, NULL AS [Desc], NULL AS AddnlDesc, 0 AS LottedYn
	, 0 AS TaxClass, NULL AS GLAcctSales, NULL AS GLAcctCOGS, NULL AS GLAcctInv, NULL AS UnitsSell, NULL AS UnitsBase
	, 0 AS QtyOrdSell, 0 AS QtyShipSell, 0 AS UnitPriceSell, 0 AS ExtPrice, 0 AS UnitCostSell, 0 AS ExtCost, NULL AS LineSeq 
	FROM dbo.tblArTransHeader h 
	INNER JOIN #tmpSales t ON h.TransId = t.TransId
	LEFT JOIN (SELECT l.TransID
		, SUM(p.PmtAmt - p.CalcGainLoss) UnpostedPaymentTotal
		, SUM(p.PmtAmtFgn) UnpostedPaymentTotalFgn
		FROM #tmpSales l INNER JOIN dbo.tblArTransPmt p ON l.TransId = p.TransId
		WHERE p.PostedYn = 0 --unposted only
		GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId

	IF @PrintDetail = 1 
	BEGIN
		--lot
		SELECT l.TransId, l.EntryNum, l.LotNum, l.QtyFilled 
		FROM dbo.tblArTransLot l INNER JOIN #tmpSales t ON l.TransId = t.TransId
		ORDER BY LotNum

		--ser
		SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum, 
			CASE WHEN @PrintAllInBase = 1 THEN CostUnit ELSE CostUnitFgn END AS CostUnit, 
			CASE WHEN @PrintAllInBase = 1 THEN PriceUnit ELSE PriceUnitFgn END AS PriceUnit 
		FROM dbo.tblArTransSer s INNER JOIN #tmpSales t ON s.TransId = t.TransId
		ORDER BY LotNum, SerNum	

		--Gains/Losses
		SELECT p.CurrencyId,h.InvcNum,h.TransId AS InvcTransId,h.CustId,
			p.PmtDate,p.PmtAmt,p.PmtAmtFgn,p.PmtAmt - p.CalcGainLoss AS InvcAmt,
			h.ExchRate AS InvcExchRate,p.CalcGainLoss,p.ExchRate,h.BatchId
		FROM #tmpSales t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId 
			INNER JOIN dbo.tblArTransPmt p ON h.TransId = p.TransId 
		WHERE p.PostedYn = 0 AND p.CalcGainLoss <> 0 --prepayment
		UNION ALL
		SELECT h.CurrencyId, CASE WHEN ISNULL(h.OrgInvcNum, '') = '' THEN h.InvcNum ELSE h.OrgInvcNum END, 
			o.TransId AS InvcTransID, h.CustId, h.InvcDate AS PmtDate,
			(h.TaxSubtotal+h.NonTaxSubtotal+h.SalesTax+h.Freight+h.Misc) AS PmtAmt, 
			(h.TaxSubtotalFgn+h.NonTaxSubtotalFgn+h.SalesTaxFgn+h.FreightFgn+h.MiscFgn) PmtAmtFgn, 
			(h.TaxSubtotal+h.NonTaxSubtotal+h.SalesTax+h.Freight+h.Misc) - (-h.CalcGainLoss) AS InvcAmt , 
			h.OrgInvcExchRate AS InvcExchRate, -h.CalcGainLoss AS CalcGainLoss, h.ExchRate, h.BatchID --flip sign of CalcGainLoss to offset TransType of -1
		FROM #tmpSales t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.trav_ArOrgInvcInfo_view l ON h.CustId = l.CustId AND h.OrgInvcNum = l.InvcNum --limit to most current invoice
			INNER JOIN dbo.tblArOpenInvoice o ON l.Counter = o.Counter
		WHERE @PrintSalesJournal = 0 AND h.CalcGainLoss <> 0 --credit memos
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransactionJournal_proc';

