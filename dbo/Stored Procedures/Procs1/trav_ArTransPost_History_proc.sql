
CREATE PROCEDURE dbo.trav_ArTransPost_History_proc
AS
BEGIN TRY
	
	DECLARE @PostRun pPostRun, @WrkStnDate datetime, @CommByLineItemYn bit

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CommByLineItemYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CommByLineItemYn'

	IF @PostRun IS NULL OR @WrkStnDate IS NULL OR @CommByLineItemYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--append customer addresses
	INSERT INTO dbo.tblArHistAddress (PostRun, CustId, [Name]
		, Contact, Attn, Address1, Address2, City, Region, Country, PostalCode, 
		Phone, Fax, Email, Internet)
	SELECT @PostRun, c.CustId, c.CustName
		, c.Contact, c.Attn, c.Addr1, c.Addr2, c.City, c.Region, c.Country, c.PostalCode
		, c.Phone, c.Fax, c.Email, c.Internet
	FROM dbo.tblArCust c
	INNER JOIN (SELECT h.CustId From dbo.tblArTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId GROUP BY h.CustId) t on c.CustId = t.CustId
	LEFT JOIN (SELECT CustId From dbo.tblArHistAddress WHERE PostRun = @PostRun) a on c.CustId = a.CustId
	WHERE a.CustId IS NULL


	--append headers
	INSERT INTO dbo.tblArHistHeader (PostRun, TransId, TransType, BatchId, CustId
		, ShipToID, ShipToName, ShipToAttn, ShipToAddr1, ShipToAddr2, ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode, ShipToPhone
		, ShipMethod,ShipVia, TermsCode, TaxableYN, InvcNum
		, CredMemNum, WhseId, OrderDate, ShipNum, ShipDate, InvcDate
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
		, TaxOnFreight, TaxClassFreight, TaxClassMisc, PostDate, GLPeriod, FiscalYear
		, TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax, Freight, Misc, TotCost
		, TaxSubtotalFgn, NonTaxSubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, TotCostFgn
		, PrintStatus, CustPONum, DistCode, CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt, DiscAmtFgn
		, SumHistPeriod, TaxAmtAdj, TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj, BillingPeriodFrom
		, PMTransType, ProjItem, BillingPeriodThru, BillingFormat, CalcGainLoss, SoldToId
		, Source, SourceInfo, SourceId, ReturnDirectToStockYn
		, GLAcctReceivables, GLAcctSalesTax, GLAcctFreight, GLAcctMisc, GlAcctGainLoss, VoidYn
		, TotPmtAmt, TotPmtAmtFgn, TotPmtGainLoss, CF) 
	SELECT @PostRun, h.TransId, TransType, BatchId, CustId
		, ShipToID, ShipToName, ShipToAttn, ShipToAddr1, ShipToAddr2, ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode, NULL
		, ShipMethod, ShipVia, TermsCode, TaxableYN, ISNULL(h.InvcNum, l.DefaultInvoiceNumber)
		, OrgInvcNum, WhseId, OrderDate, ShipNum, ShipDate, InvcDate
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
		, TaxOnFreight, TaxClassFreight, TaxClassMisc, @WrkStnDate, GLPeriod, FiscalYear
		, TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax + TaxAmtAdj, Freight, Misc, TotCost
		, TaxSubtotalFgn, NonTaxSubtotalFgn, SalesTaxFgn + TaxAmtAdjFgn, FreightFgn, MiscFgn, TotCostFgn
		, PrintStatus, CustPONum, h.DistCode, h.CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt, DiscAmtFgn
		, SumHistPeriod, TaxAmtAdj, TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj, BillingPeriodFrom
		, PMTransType, ProjItem, BillingPeriodThru, BillingFormat, CalcGainLoss, CustId
		, 0, NULL, h.SourceId , 0 --PET:225114
		, dc.GLAcctReceivables, NULL, dc.GLAcctFreight, dc.GLAcctMisc
		, CASE WHEN h.TransType < 0 AND -h.CalcGainLoss <> 0 THEN --applies only to Credit Memos with an amount 
			CASE WHEN -h.CalcGainLoss > 0 -- sign is flipped for proper account retrieval
				THEN t.RealGainAcct 
				ELSE t.RealLossAcct 
				END
			ELSE NULL --no gain/loss account for Invoices
			END  GlAcctGainLoss
		, h.VoidYn, ISNULL(pmt.TotPmtAmt, 0), ISNULL(pmt.TotPmtAmtFgn, 0)
		, CASE WHEN pmt.TotPmtAmtFgn = ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) THEN pmt.TotPmtAmt - (ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0)) ELSE ISNULL(pmt.TotPmtGainLoss, 0) END, h.CF
	FROM dbo.tblArTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
	LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
	LEFT JOIN (SELECT p.TransId, SUM(p.PmtAmt) TotPmtAmt, SUM(p.PmtAmtFgn) TotPmtAmtFgn, SUM(p.CalcGainLoss) TotPmtGainLoss
		FROM #PostTransList l
		INNER JOIN dbo.tblArTransPmt p ON l.TransId = p.TransId
		GROUP BY p.TransId) pmt ON h.TransId = pmt.TransId --rollup applied payments as of posting (posted and unposted)

	
	--sales tax (-1)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt
		, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -1, 0, WhseId, 0, 0, NULL, 1, 1, 1, 1
		, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj
		, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn
		, ShipDate, ShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblArTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE (SalesTax + TaxAmtAdj) <> 0 OR (SalesTaxFgn + TaxAmtAdjFgn) <> 0


	--Freight (-2)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -2, 0, WhseId, 0, TaxClassFreight, dc.GLAcctFreight, 1, 1, 1, 1
		, Freight, Freight, Freight, FreightFgn, FreightFgn, FreightFgn
		, ShipDate, ShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblArTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
	WHERE Freight <> 0 OR FreightFgn <> 0


	--Misc (-3)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -3, 0, WhseId, 0, TaxClassMisc, dc.GLAcctMisc, 1, 1, 1, 1
		, Misc, Misc, Misc, MiscFgn, MiscFgn, MiscFgn
		, ShipDate, ShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblArTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
	WHERE Misc <> 0 OR MiscFgn <> 0

	--GainLoss (-4)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -4, 0, WhseId, 0, 0
		, CASE WHEN -h.CalcGainLoss > 0 -- sign is flipped for proper account retrieval
			THEN t.RealGainAcct 
			ELSE t.RealLossAcct 
			END
		, 1, 1, 1, 1
		, CalcGainLoss, CalcGainLoss, CalcGainLoss, 0, 0, 0
		, ShipDate, ShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblArTransHeader h 
	LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE h.TransType < 0 AND h.CalcGainLoss <> 0 --applies only to Credit Memos with an amount 


	--append detail 
	INSERT INTO dbo.tblArHistDetail (PostRun, TransID, EntryNum, ItemJob, WhseId, PartId
		, JobId, PhaseId, JobCompleteYN, [Desc], PartType, InItemYN, LottedYN, AddnlDesc, CatId
		, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyOrdSell, UnitsSell, UnitsBase
		, QtyShipBase, QtyShipSell, QtyBackordSell, PriceID, UnitPriceSell, UnitCostSell, UnitPriceSellFgn, UnitCostSellFgn
		, HistSeqNum, ExtFinalInc, ExtFinalIncFgn, ExtOrigInc, TransHistID, ProjName, PhaseName, TaskName, ReqShipDate
		, PriceExt, PriceExtFgn, CostExt, CostExtFgn
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, UnitCommBasis, UnitCommBasisFgn
		, PriceAdjType, PriceAdjPct, PriceAdjAmt, PriceAdjAmtFgn, UnitPriceSellBasis, UnitPriceSellBasisFgn, TaskId, ZeroPrint
		, TotQtyOrdSell, TotQtyShipSell, LineSeq, ConversionFactor,CustomerPartNumber, CF) 
	SELECT @PostRun, d.TransID, d.EntryNum, d.ItemJob, d.WhseId, d.PartId
		, d.JobId, d.PhaseId, d.JobCompleteYN, d.[Desc], d.PartType, CASE WHEN d.PartType = 0 THEN 0 ELSE 1 END
		, d.LottedYn, d.AddnlDesc
		, CASE WHEN ISNULL(d.CatId, '') = '' THEN NULL ELSE d.CatId END, d.TaxClass
		, d.AcctCode, d.GLAcctSales, d.GLAcctCOGS, d.GLAcctInv, d.QtyOrdSell, d.UnitsSell, d.UnitsBase
		, d.QtyShipBase, d.QtyShipSell, d.QtyBackordSell
		, CASE WHEN ISNULL(d.PriceCode, '') = '' THEN NULL ELSE d.PriceCode END
		, d.UnitPriceSell, d.UnitCostSell, d.UnitPriceSellFgn, d.UnitCostSellFgn
		, d.HistSeqNum, d.ExtFinalInc, d.ExtFinalIncFgn, d.ExtOrigInc, d.TransHistID, d.ProjName, d.PhaseName, d.TaskName, d.ReqShipDate
		, d.PriceExt, d.PriceExtFgn, d.CostExt, d.CostExtFgn
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Id ELSE d.Rep1Id END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Pct ELSE d.Rep1Pct END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1CommRate ELSE d.Rep1CommRate END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Id ELSE d.Rep2Id END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Pct ELSE d.Rep2Pct END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2CommRate ELSE d.Rep2CommRate END
		, ISNULL(d.UnitCommBasis, d.UnitCostSell)
		, ISNULL(d.UnitCommBasisFgn, d.UnitCostSellFgn)
		, d.PriceAdjType, d.PriceAdjPct, d.PriceAdjAmt, d.PriceAdjAmtFgn, d.UnitPriceSellBasis, d.UnitPriceSellBasisFgn, d.TaskId, d.ZeroPrint 
		, d.QtyOrdSell, d.QtyShipSell, d.LineSeq, ISNULL(u.ConvFactor, 1),d.CustomerPartNumber, d.CF
	FROM dbo.tblArTransHeader h 
	INNER JOIN dbo.tblArTransDetail d ON h.TransId = d.TransID 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblInItemUom u on d.PartId = u.ItemId AND d.UnitsSell = u.Uom


	--append lot history
	INSERT INTO dbo.tblArHistLot (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, CF) 
	SELECT @PostRun, h.TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, d.CF 
	FROM dbo.tblArTransHeader h 
	INNER JOIN dbo.tblArTransLot d ON h.TransId = d.TransId 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId


	--append serial numbers
	INSERT INTO dbo.tblArHistSer (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, SerNum, CostUnit, PriceUnit, CostUnitFgn, PriceUnitFgn, HistSeqNum, Cmnt, CF) 
	SELECT @PostRun, h.TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, SerNum, CostUnit, PriceUnit, CostUnitFgn, PriceUnitFgn, HistSeqNum, Cmnt, s.CF 
	FROM dbo.tblArTransHeader h 
	INNER JOIN dbo.tblArTransSer s ON h.TransId = s.TransId 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId

		
	--append tax information
	INSERT INTO dbo.tblArHistTax (PostRun, TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, CF) 
	SELECT @PostRun, h.TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, t.CF 
	FROM dbo.tblArTransHeader h 
	INNER JOIN dbo.tblArTransTax t ON h.TransId = t.TransId 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId

	
	--update the PostRun for recurring entries in tblArHistRecur 
	UPDATE dbo.tblArHistRecur SET PostRun = @PostRun 
	FROM dbo.tblArTransHeader h
		INNER JOIN dbo.tblArHistRecur ON h.TransID = dbo.tblArHistRecur.TransID 
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE dbo.tblArHistRecur.Source = 0 AND dbo.tblArHistRecur.PostRun IS NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_History_proc';

