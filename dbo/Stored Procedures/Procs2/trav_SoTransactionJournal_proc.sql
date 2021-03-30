CREATE PROCEDURE dbo.trav_SoTransactionJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@PrintSalesJournal bit = 1,
@PrintDetail bit = 1,
@PrintKitDetail bit = 0
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpSales
	(
		TransId pTransID NOT NULL
	)

	INSERT INTO #tmpSales (TransId) 
	SELECT h.TransId 
	FROM #tmpCustomerList c INNER JOIN dbo.tblSoTransHeader h ON c.CustId = h.CustId 
		INNER JOIN #tmpTransactionList b ON h.TransId = b.TransId 
	WHERE (@PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency) 
		AND ((@PrintSalesJournal = 0 AND h.TransType = -1) OR (@PrintSalesJournal = 1 AND h.TransType IN (1,4))) 
		AND h.Layaway = 0 AND VoidYn = 0
		AND (h.OrderState = 0 OR h.OrderState & 4 = 4 )

	SELECT 0 AS RecType
		, h.TransId, h.BatchId, h.TaxGrpID AS TaxLocId
		, CASE WHEN CustPONum IS NULL THEN TransDate ELSE PODate END AS TransDate
		, h.GLPeriod, h.FiscalYear, h.CustId, h.TermsCode, h.InvcNum, h.OrgInvcNum
		, CASE WHEN ISNUMERIC(InvcNum) <> 0  THEN SUBSTRING('000000000000000' + InvcNum, LEN('000000000000000' + InvcNum) -14, 15) 
			ELSE InvcNum END AS SortInvNum
		, h.ShipToID, h.InvcDate, h.ReqShipDate, h.ActShipDate, h.CustPONum, h.Rep1Id, h.Rep2Id
		, c.CustName
		, 0 AS TaxSubtotal
		, 0 AS NontaxSubtotal
		, 0 AS SalesTaxTotal
		, 0 AS FreightTotal
		, 0 AS MiscTotal
		, 0 AS TotalPmtAmt
		, d.EntryNum, d.ItemType, d.LocId, d.ItemId, d.LottedYn
		, d.Descr, d.AddnlDescr, d.TaxClass, d.GLAcctSales, d.GLAcctCOGS, d.QtyOrdSell
		, d.GLAcctInv, d.UnitsSell, d.QtyShipSell, d.QtyBackordSell, d.Kit
		, CASE WHEN @PrintAllInBase = 1 THEN UnitPriceSell ELSE UnitPriceSellFgn END AS UnitPriceSell
		, CASE WHEN @PrintAllInBase = 1 THEN UnitCostSell ELSE UnitCostSellFgn END AS UnitCostSell
		, CASE WHEN @PrintAllInBase = 1 THEN PriceExt ELSE PriceExtFgn END AS ExtPrice
		, CASE WHEN @PrintAllInBase = 1 THEN CostExt ELSE CostExtFgn END AS ExtCost
		, d.LineSeq, CASE WHEN d.EntryNum IS NULL THEN 0 ELSE 1 END AS HasDetail 
	FROM dbo.tblArCust AS c 
		INNER JOIN dbo.tblSoTransHeader AS h ON c.CustId = h.CustId 
		INNER JOIN #tmpSales t ON h.TransId = t.TransId
		LEFT JOIN dbo.tblSoTransDetail AS d ON h.TransId = d.TransID 
	WHERE d.GrpId IS NULL AND d.Status = 0
	UNION ALL
	SELECT 1 AS RecType
		, h.TransId, h.BatchId, h.TaxGrpID AS TaxLocId
		, CASE WHEN CustPONum IS NULL THEN TransDate ELSE PODate END AS TransDate
		, h.GLPeriod, h.FiscalYear, h.CustId, h.TermsCode, h.InvcNum, h.OrgInvcNum
		, CASE WHEN ISNUMERIC(InvcNum) <> 0  THEN SUBSTRING('000000000000000' + InvcNum, LEN('000000000000000' + InvcNum) -14, 15) 
			ELSE InvcNum END AS SortInvNum
		, h.ShipToID, h.InvcDate, h.ReqShipDate, h.ActShipDate, h.CustPONum, h.Rep1Id, h.Rep2Id
		, c.CustName
		, CASE WHEN @PrintAllInBase = 1 THEN TaxableSales ELSE TaxableSalesFgn END AS TaxSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN NonTaxableSales ELSE NonTaxableSalesFgn END AS NontaxSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END AS SalesTaxTotal
		, CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END AS FreightTotal
		, CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END AS MiscTotal
		, CASE WHEN @PrintAllInBase = 1 THEN ISNULL(pmt.UnpostedPaymentTotal, 0) ELSE ISNULL(pmt.UnpostedPaymentTotalFgn, 0) END AS TotalPmtAmt
		, 0 AS EntryNum, 0 AS ItemType, NULL AS LocId, NULL AS ItemId, 0 AS LottedYn
		, NULL AS Descr, NULL AS AddnlDescr, 0 AS TaxClass, NULL AS GLAcctSales, NULL AS GLAcctCOGS, 0 AS QtyOrdSell
		, NULL AS GLAcctInv, NULL AS UnitsSell, 0 AS QtyShipSell, 0 AS QtyBackordSell, 0 AS Kit
		, 0 AS UnitPriceSell
		, 0 AS UnitCostSell
		, 0  AS ExtPrice
		, 0 AS ExtCost
		, NULL AS LineSeq, CASE WHEN d.EntryNum IS NULL THEN 0 ELSE 1 END AS HasDetail 
	FROM dbo.tblArCust AS c INNER JOIN dbo.tblSoTransHeader AS h ON c.CustId = h.CustId 
		INNER JOIN #tmpSales t ON h.TransId = t.TransId
		LEFT JOIN (SELECT l.TransID
			, SUM(p.PmtAmt - p.CalcGainLoss) UnpostedPaymentTotal
			, SUM(p.PmtAmtFgn) UnpostedPaymentTotalFgn
			FROM #tmpSales l INNER JOIN dbo.tblSoTransPmt p ON l.TransId = p.TransId
			WHERE p.PostedYn = 0 --unposted only
			GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
		LEFT JOIN (SELECT TransId,MIN(EntryNum) AS EntryNum FROM dbo.tblSoTransDetail WHERE [Status] = 0 GROUP BY TransId) AS d ON h.TransId = d.TransID 

	IF @PrintDetail = 1 
	BEGIN
		--kit
		IF @PrintKitDetail = 1
		BEGIN
			SELECT d.TransId, d.EntryNum, d.LocId, d.ItemId, d.ItemType, d.GLAcctInv, d.UnitsSell, 
				d.QtyShipSell, d.LottedYN, d.InItemYN, d.GrpId, d.Kit, d.LineSeq, 
				CASE WHEN @PrintAllInBase = 1 THEN d.UnitCostSell ELSE d.UnitCostSellFgn END AS UnitCostSell
			FROM dbo.tblSoTransDetail d INNER JOIN #tmpSales t ON d.TransId = t.TransId
			WHERE GrpId IS NOT NULL

			--lot
			SELECT l.TransId, l.EntryNum, l.LotNum, l.QtyFilled 
			FROM dbo.tblSoTransDetailExt l INNER JOIN #tmpSales t ON l.TransId = t.TransId
			WHERE l.LotNum IS NOT NULL AND l.QtyFilled > 0
			ORDER BY LotNum

			--ser
			SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum, 
				CASE WHEN @PrintAllInBase = 1 THEN CostUnit ELSE CostUnitFgn END AS CostUnit, 
				CASE WHEN @PrintAllInBase = 1 THEN PriceUnit ELSE PriceUnitFgn END AS PriceUnit 
			FROM dbo.tblSoTransSer s INNER JOIN #tmpSales t ON s.TransId = t.TransId
			ORDER BY LotNum, SerNum	
		END		

		--lot
		SELECT l.TransId, l.EntryNum, l.LotNum, l.QtyFilled 
		FROM dbo.tblSoTransDetailExt l INNER JOIN #tmpSales t ON l.TransId = t.TransId 
		WHERE l.LotNum IS NOT NULL AND l.QtyFilled > 0
		ORDER BY LotNum

		--ser
		SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum, 
			CASE WHEN @PrintAllInBase = 1 THEN CostUnit ELSE CostUnitFgn END AS CostUnit, 
			CASE WHEN @PrintAllInBase = 1 THEN PriceUnit ELSE PriceUnitFgn END AS PriceUnit 
		FROM dbo.tblSoTransSer s INNER JOIN #tmpSales t ON s.TransId = t.TransId
		ORDER BY LotNum, SerNum	

		--Gains/Losses
		SELECT p.CurrencyId,h.InvcNum,h.TransId AS InvcTransId,h.CustId,
			p.PmtDate,p.PmtAmt,p.PmtAmtFgn,p.PmtAmt - p.CalcGainLoss AS InvcAmt,
			h.ExchRate AS InvcExchRate,p.CalcGainLoss,p.ExchRate,h.BatchId
		FROM #tmpSales t INNER JOIN dbo.tblSoTransHeader h ON t.TransId = h.TransId 
			INNER JOIN dbo.tblSoTransPmt p ON h.TransId = p.TransId 
		WHERE p.PostedYn = 0 AND p.CalcGainLoss <> 0 --prepayment
		UNION ALL
		SELECT h.CurrencyId, CASE WHEN ISNULL(h.OrgInvcNum, '') = '' THEN h.InvcNum ELSE h.OrgInvcNum END, 
			o.TransId AS InvcTransID, h.CustId, h.InvcDate AS PmtDate,
			(h.TaxableSales + h.NonTaxableSales + h.SalesTax + h.Freight + h.Misc) AS PmtAmt, 
			(h.TaxableSalesFgn + h.NonTaxableSalesFgn + h.SalesTaxFgn + h.FreightFgn + h.MiscFgn) PmtAmtFgn, 
			(h.TaxableSales + h.NonTaxableSales + h.SalesTax + h.Freight + h.Misc) - (-h.CalcGainLoss) AS InvcAmt , 
			h.OrgInvcExchRate AS InvcExchRate, -h.CalcGainLoss AS CalcGainLoss, h.ExchRate, h.BatchID --flip sign of CalcGainLoss to offset TransType of -1
		FROM #tmpSales t INNER JOIN dbo.tblSoTransHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.trav_ArOrgInvcInfo_view l ON h.CustId = l.CustId AND h.OrgInvcNum = l.InvcNum --limit to most current invoice
			INNER JOIN dbo.tblArOpenInvoice o ON l.Counter = o.Counter
		WHERE @PrintSalesJournal = 0 AND h.CalcGainLoss <> 0 --credit memos		

	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransactionJournal_proc';

