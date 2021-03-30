
CREATE PROCEDURE dbo.trav_ArCreditJournal_proc
@SortBy tinyint = 1,
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@PrintDetail bit = 1

AS
SET NOCOUNT ON
BEGIN TRY

IF @PrintDetail = 1
BEGIN
	SELECT 0 AS RecType
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.GlPeriod)), 3) 
			WHEN 4 THEN d.PartId END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN d.GLAcctSales 
			WHEN 4 THEN d.PartId END AS GrpId2
		, h.BatchId, h.TransId, h.TransType, h.CustId, c.CustName, h.ShipToID, h.TermsCode, h.InvcNum, h.OrgInvcNum
		, h.CustPONum, h.OrderDate, h.ShipDate, h.InvcDate, h.Rep1Id, h.Rep1Pct, h.Rep2Id, h.Rep2Pct, h.TaxClassFreight
		, h.GLPeriod, h.FiscalYear, h.TaxGrpID AS TaxLocId, h.ExchRate
		, 0 AS TaxSubtotal, 0 AS NonTaxSubtotal, 0 AS SalesTax, 0 AS Freight, 0 AS Misc, 0 AS PmtAmt
		, d.EntryNum, d.PartType, d.PartId, d.WhseId, d.[Desc], d.AddnlDesc, d.LottedYn, d.TaxClass
		, d.GLAcctSales, d.GLAcctCOGS, d.GLAcctInv, d.UnitsSell, d.UnitsBase, d.QtyOrdSell, d.QtyShipSell
		, CASE WHEN @PrintAllInBase = 1 THEN UnitPriceSell ELSE UnitPriceSellFgn END AS UnitPriceSell
		, CASE WHEN @PrintAllInBase = 1 THEN PriceExt ELSE PriceExtFgn END AS ExtPrice
		, CASE WHEN @PrintAllInBase = 1 THEN UnitCostSell ELSE UnitCostSellFgn END AS UnitCostSell
		, CASE WHEN @PrintAllInBase = 1 THEN CostExt ELSE CostExtFgn END AS ExtCost 
	FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId 
		INNER JOIN #tmpCustomerList c ON h.CustId = c.CustId
		LEFT JOIN dbo.tblArTransDetail d ON h.TransId = d.TransID
	WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)
	UNION ALL
	SELECT 1 AS RecType
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.GlPeriod)), 3) 
			WHEN 4 THEN NULL END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN NULL 
			WHEN 4 THEN NULL END AS GrpId2
		, h.BatchId, h.TransId, h.TransType, h.CustId, NULL AS CustName
		, h.ShipToID, h.TermsCode, h.InvcNum, h.OrgInvcNum, h.CustPONum, h.OrderDate, h.ShipDate, h.InvcDate
		, h.Rep1Id, h.Rep1Pct, h.Rep2Id, h.Rep2Pct, h.TaxClassFreight, h.GLPeriod, h.FiscalYear
		, h.TaxGrpID AS TaxLocId, h.ExchRate
		, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS TaxSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS NonTaxSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN SalesTax ELSE SalesTaxFgn END AS SalesTax
		, CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END AS Freight
		, CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END AS Misc
		, CASE WHEN @PrintAllInBase = 1 THEN ISNULL(pmt.UnpostedPaymentTotal, 0) ELSE ISNULL(pmt.UnpostedPaymentTotalFgn, 0) END AS PmtAmt
		, 0 AS EntryNum, 0 AS PartType, NULL AS PartId, NULL AS WhseId, NULL AS [Desc], NULL AS AddnlDesc, 0 AS LottedYn
		, 0 AS TaxClass, NULL AS GLAcctSales, NULL AS GLAcctCOGS, NULL AS GLAcctInv, NULL AS UnitsSell, NULL AS UnitsBase
		, 0 AS QtyOrdSell, 0 AS QtyShipSell, 0 AS UnitPriceSell, 0 AS ExtPrice, 0 AS UnitCostSell, 0 AS ExtCost
	FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId
	INNER JOIN #tmpCustomerList c ON h.CustId = c.CustId
	LEFT JOIN (SELECT l.TransID
		, SUM(p.PmtAmt - p.CalcGainLoss) UnpostedPaymentTotal
		, SUM(p.PmtAmtFgn) UnpostedPaymentTotalFgn
		FROM #tmpTransactionList l INNER JOIN dbo.tblArTransPmt p ON l.TransId = p.TransId
		WHERE p.PostedYn = 0 --unposted only
		GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)
	
	--Lot
	SELECT l.TransId, l.EntryNum, l.SeqNum, l.ItemId, l.LocId, l.LotNum, l.QtyOrder, l.QtyFilled, l.QtyBkord, l.CostUnit, 
		l.CostUnitFgn, l.HistSeqNum, l.Cmnt, l.QtySeqNum
	FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId 
		INNER JOIN #tmpCustomerList c ON h.CustId = c.CustId 
		INNER JOIN dbo.tblArTransLot l ON t.TransId = l.TransId
	WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)
	ORDER BY LotNum

	--Ser
	SELECT s.TransId, s.EntryNum, s.SerNum, s.LotNum, 
		CASE WHEN @PrintAllInBase = 1 THEN CostUnit ELSE CostUnitFgn END AS CostUnit, 
		CASE WHEN @PrintAllInBase = 1 THEN PriceUnit ELSE PriceUnitFgn END AS PriceUnit 
	FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId 
		INNER JOIN #tmpCustomerList c ON h.CustId = c.CustId
		INNER JOIN dbo.tblArTransSer s ON t.TransId = s.TransId
	WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)
	ORDER BY LotNum, SerNum

END
ELSE
BEGIN
	SELECT 0 AS RecType
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.GlPeriod)), 3) 
			WHEN 4 THEN d.PartId END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN d.GLAcctSales 
			WHEN 4 THEN d.PartId END AS GrpId2
		, h.BatchId, h.TransId, h.CustId, h.InvcNum, h.GLPeriod, h.FiscalYear
		, 0 AS TaxSubtotal, 0 AS NonTaxSubtotal, 0 AS SalesTax, 0 AS Freight, 0 AS Misc
		, d.EntryNum, d.PartId, d.GLAcctSales
		, CASE WHEN @PrintAllInBase = 1 THEN PriceExt ELSE PriceExtFgn END AS ExtPrice
		, CASE WHEN @PrintAllInBase = 1 THEN CostExt ELSE CostExtFgn END AS ExtCost 
	FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId 
		INNER JOIN #tmpCustomerList c ON h.CustId = c.CustId
		LEFT JOIN dbo.tblArTransDetail d ON h.TransId = d.TransID
	WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)
	UNION ALL
	SELECT 1 AS RecType
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.GlPeriod)), 3) 
			WHEN 4 THEN NULL END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.CustId 
			WHEN 2 THEN ISNULL(h.InvcNum, '') 
			WHEN 3 THEN NULL 
			WHEN 4 THEN NULL END AS GrpId2
		, h.BatchId, h.TransId, h.CustId, h.InvcNum, h.GLPeriod, h.FiscalYear
		, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS TaxSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS NonTaxSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN SalesTax ELSE SalesTaxFgn END AS SalesTax
		, CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END AS Freight
		, CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END AS Misc
		, 0 AS EntryNum, NULL AS PartId, NULL AS GLAcctSales, 0 AS ExtPrice, 0 AS ExtCost
	FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId 
		INNER JOIN #tmpCustomerList c ON h.CustId = c.CustId
	WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)

END

--Gains/Losses, prepayment
SELECT p.CurrencyId,h.InvcNum,h.TransId AS InvcTransId,h.CustId,
	p.PmtDate,p.PmtAmt,p.PmtAmtFgn,p.PmtAmt - p.CalcGainLoss AS InvcAmt,
	h.ExchRate AS InvcExchRate,p.CalcGainLoss,p.ExchRate,h.BatchId
FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId 
	INNER JOIN #tmpCustomerList m ON h.CustId = m.CustId
	INNER JOIN dbo.tblArTransPmt p ON h.TransId = p.TransId 
WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) AND p.CalcGainLoss <> 0 AND p.PostedYn = 0
UNION ALL -- Credit Memo
SELECT h.CurrencyId, CASE WHEN ISNULL(h.OrgInvcNum, '') = '' THEN h.InvcNum ELSE h.OrgInvcNum END, 
	o.TransId AS InvcTransID, h.CustId, h.InvcDate AS PmtDate,
	(h.TaxSubtotal+h.NonTaxSubtotal+h.SalesTax+h.Freight+h.Misc) AS PmtAmt, 
	(h.TaxSubtotalFgn+h.NonTaxSubtotalFgn+h.SalesTaxFgn+h.FreightFgn+h.MiscFgn) PmtAmtFgn, 
	(h.TaxSubtotal+h.NonTaxSubtotal+h.SalesTax+h.Freight+h.Misc) - (-h.CalcGainLoss) AS InvcAmt , 
	h.OrgInvcExchRate AS InvcExchRate, -h.CalcGainLoss AS CalcGainLoss, h.ExchRate, h.BatchID --flip sign of CalcGainLoss to offset TransType of -1
FROM #tmpTransactionList t INNER JOIN dbo.tblArTransHeader h ON t.TransId = h.TransId
	INNER JOIN #tmpCustomerList c ON h.CustId = c.CustId
	INNER JOIN dbo.trav_ArOrgInvcInfo_view l ON h.CustId = l.CustId AND h.OrgInvcNum = l.InvcNum --limit to most current invoice
	INNER JOIN dbo.tblArOpenInvoice o ON l.Counter = o.Counter
WHERE h.TransType = -1 AND h.VoidYn = 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) AND h.CalcGainLoss <> 0 --credit memos

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditJournal_proc';

