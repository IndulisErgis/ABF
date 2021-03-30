
CREATE PROCEDURE dbo.trav_SoTransPost_History_proc
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @PostRun pPostRun, @WrkStnDate datetime, @ReturnDirectToStock bit, @CommByLineItemYn bit

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @ReturnDirectToStock = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ReturnDirectToStock'
	SELECT @CommByLineItemYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CommByLineItemYn'
	
	IF @PostRun IS NULL OR @WrkStnDate IS NULL OR @ReturnDirectToStock IS NULL OR @CommByLineItemYn IS NULL
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
	INNER JOIN (SELECT h.CustId From dbo.tblSoTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId GROUP BY h.CustId) t on c.CustId = t.CustId
	LEFT JOIN (SELECT CustId From dbo.tblArHistAddress WHERE PostRun = @PostRun) a on c.CustId = a.CustId
	WHERE a.CustId IS NULL


	--append headers
	INSERT INTO dbo.tblArHistHeader (PostRun, TransId, TransType, BatchId, CustId
		, ShipToID, ShipToName, ShipToAddr1, ShipToAddr2, ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode, ShipToPhone
		, ShipVia, TermsCode, TaxableYN, InvcNum
		, CredMemNum, WhseId, OrderDate, ShipNum, ShipDate, InvcDate
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
		, TaxOnFreight, TaxClassFreight, TaxClassMisc, PostDate, GLPeriod, FiscalYear
		, TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax, Freight, Misc, TotCost
		, TaxSubtotalFgn, NonTaxSubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, TotCostFgn
		, PrintStatus, CustPONum, DistCode, CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt, DiscAmtFgn
		, SumHistPeriod, TaxAmtAdj, TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj
		, CalcGainLoss, SoldToId, CustLevel, PODate, ReqShipDate, PickNum, PackNum, BlanketRef
		, [Source], SourceInfo, SourceId, ReturnDirectToStockYn
		, GLAcctReceivables, GLAcctSalesTax, GLAcctFreight, GLAcctMisc, GlAcctGainLoss
		, VoidYn, Notes, TotPmtAmt, TotPmtAmtFgn, TotPmtGainLoss, CF, ShipToAttn, ShipMethod) 
	SELECT @PostRun, h.TransId, (CASE WHEN h.TransType > 0 THEN 1 ELSE -1 END), BatchId, CustId
		, ShipToID, ShipToName, ShipToAddr1, ShipToAddr2, ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode, ShipToPhone
		, ShipVia, TermsCode, TaxableYN, l.DefaultInvoiceNumber
		, OrgInvcNum, LocId, TransDate, ShipNum, ActShipDate, InvcDate
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
		, TaxOnFreight, TaxClassFreight, TaxClassMisc, @WrkStnDate, GLPeriod, FiscalYear
		, TaxGrpID, TaxableSales, NonTaxableSales, SalesTax + TaxAmtAdj, Freight, Misc, TotCost
		, TaxableSalesFgn, NonTaxableSalesFgn, SalesTaxFgn + TaxAmtAdjFgn, FreightFgn, MiscFgn, TotCostFgn
		, Case When isnull(PrintAcknowStatus, 0) <> 0 Then 1 Else 0 End
		  + Case When isnull(PrintInvcStatus, 0) <> 0 Then 2 Else 0 End
		  + Case When isnull(PrintPackStatus, 0) <> 0 Then 4 Else 0 End
		  + Case When isnull(PrintPickStatus, 0) <> 0 Then 8 Else 0 End PrintStatus --bitmask the flags 
		, CustPONum, h.DistCode, h.CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt, DiscAmtFgn
		, SumHistPeriod, TaxAmtAdj, TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj
		, CalcGainLoss, SoldToId, CustLevel, PODate, ReqShipDate, PickNum, PackNum, BlanketRef
		, 1, NULL, h.SourceId, @ReturnDirectToStock
		, dc.GLAcctReceivables, NULL, dc.GLAcctFreight, dc.GLAcctMisc
		, CASE WHEN h.TransType < 0 AND -h.CalcGainLoss <> 0 THEN --applies only to Credit Memos with an amount 
			CASE WHEN -h.CalcGainLoss > 0 -- sign is flipped for proper account retrieval
				THEN t.RealGainAcct 
				ELSE t.RealLossAcct 
				END
			ELSE NULL --no gain/loss account for Invoices
			END  GlAcctGainLoss
		, h.VoidYn, h.Notes , ISNULL(pmt.TotPmtAmt, 0), ISNULL(pmt.TotPmtAmtFgn, 0)
		, CASE WHEN ISNULL(pmt.TotPmtAmtFgn, 0) = ISNULL(h.TaxableSalesFgn, 0) + ISNULL(NonTaxableSalesFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) + ISNULL(hist.PostedInvoiceTotalFgn,0) THEN ISNULL(pmt.TotPmtAmt, 0) - (ISNULL(TaxableSales, 0) + ISNULL(NonTaxableSales, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) + ISNULL(hist.PostedInvoiceTotal, 0)) ELSE ISNULL(pmt.TotPmtGainLoss, 0) END, h.CF
		, h.ShipToAttn, h.ShipMethod
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
	LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
	LEFT JOIN (SELECT p.TransId, SUM(p.PmtAmt) TotPmtAmt, SUM(p.PmtAmtFgn) TotPmtAmtFgn, SUM(p.CalcGainLoss) TotPmtGainLoss
		FROM #PostTransList l
		INNER JOIN dbo.tblSoTransPmt p ON l.TransId = p.TransId
		GROUP BY p.TransId) pmt ON h.TransId = pmt.TransId --rollup applied payments as of posting (posted and unposted)
	LEFT JOIN (SELECT r.SourceId
		, SUM(h.TaxSubtotal + h.NonTaxSubtotal + h.SalesTax + h.Freight + h.Misc + h.CalcGainLoss) AS PostedInvoiceTotal
		, SUM(h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.FreightFgn + h.MiscFgn) AS PostedInvoiceTotalFgn 
		FROM dbo.tblSoTransHeader r INNER JOIN #PostTransList l ON r.TransId = l.TransId
			INNER JOIN dbo.tblArHistHeader h on r.SourceId = h.SourceId 
		WHERE h.[Source] = 1
		GROUP BY r.SourceId) hist on h.SourceId = hist.SourceId
	
	--sales tax (-1)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt
		, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -1, 0, LocId, 0, 0, NULL, 1, 1, 1, 1
		, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj
		, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE (SalesTax + TaxAmtAdj) <> 0 OR (SalesTaxFgn + TaxAmtAdjFgn) <> 0


	--Freight (-2)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -2, 0, LocId, 0, TaxClassFreight, dc.GLAcctFreight, 1, 1, 1, 1
		, Freight, Freight, Freight, FreightFgn, FreightFgn, FreightFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
	WHERE Freight <> 0 OR FreightFgn <> 0


	--Misc (-3)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -3, 0, LocId, 0, TaxClassMisc, dc.GLAcctMisc, 1, 1, 1, 1
		, Misc, Misc, Misc, MiscFgn, MiscFgn, MiscFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
	WHERE Misc <> 0 OR MiscFgn <> 0

	--GainLoss (-4)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -4, 0, LocId, 0, 0
		, CASE WHEN -h.CalcGainLoss > 0 -- sign is flipped for proper account retrieval
			THEN t.RealGainAcct 
			ELSE t.RealLossAcct 
			END
		, 1, 1, 1, 1
		, CalcGainLoss, CalcGainLoss, CalcGainLoss, 0, 0, 0
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM dbo.tblSoTransHeader h 
	LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE h.TransType < 0 AND h.CalcGainLoss <> 0 --applies only to Credit Memos with an amount 


	--append detail 
	INSERT INTO dbo.tblArHistDetail (PostRun, TransID, EntryNum, ItemJob, WhseId, PartId
		, JobId, PhaseId, JobCompleteYN, [Desc], PartType, InItemYN, LottedYN, AddnlDesc, CatId
		, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyOrdSell, UnitsSell, UnitsBase
		, QtyShipBase, QtyShipSell, QtyBackordSell, PriceID, UnitPriceSell, UnitCostSell, UnitPriceSellFgn, UnitCostSellFgn
		, HistSeqNum, ReqShipDate, ActShipDate
		, PriceExt, PriceExtFgn, CostExt, CostExtFgn
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, UnitCommBasis, UnitCommBasisFgn
		, PriceAdjType, PriceAdjPct, PriceAdjAmt, PriceAdjAmtFgn, UnitPriceSellBasis, UnitPriceSellBasisFgn
		, TotQtyOrdSell, TotQtyShipSell, LineSeq
		, BOLNum, Kit, GrpId, KitQty, OriCompQty, [Status], ResCode, DropShipYn, ConversionFactor
		, PromoID, EffectiveRate, OrigOrderQty, BlanketDtlRef, CF, CustomerPartNumber) 
	SELECT @PostRun, d.TransID, d.EntryNum, d.ItemJob, d.LocId, d.ItemId
		, d.JobId, d.PhaseId, d.JobCompleteYN, d.[Descr], d.ItemType, CASE WHEN d.ItemType = 0 THEN 0 ELSE 1 END
		, d.LottedYn, d.AddnlDescr
		, CASE WHEN ISNULL(d.CatId, '') = '' THEN NULL ELSE d.CatId END, d.TaxClass
		, d.AcctCode, d.GLAcctSales, d.GLAcctCOGS, d.GLAcctInv, d.QtyOrdSell, d.UnitsSell, d.UnitsBase
		, d.QtyShipBase, d.QtyShipSell, d.QtyBackordSell
		, CASE WHEN ISNULL(d.PriceId, '') = '' THEN NULL ELSE d.Priceid END
		, d.UnitPriceSell, d.UnitCostSell, d.UnitPriceSellFgn, d.UnitCostSellFgn
		, d.HistSeqNum, d.ReqShipDate, d.ActShipDate
		, d.PriceExt, d.PriceExtFgn, d.CostExt, d.CostExtFgn
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Id ELSE d.Rep1Id END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Pct ELSE d.Rep1Pct END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1CommRate ELSE d.Rep1CommRate END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Id ELSE d.Rep2Id END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Pct ELSE d.Rep2Pct END
		, CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2CommRate ELSE d.Rep2CommRate END
		, ISNULL(d.UnitCommBasis, d.UnitCostSell)
		, ISNULL(d.UnitCommBasisFgn, d.UnitCostSellFgn)
		, d.PriceAdjType, d.PriceAdjPct, d.PriceAdjAmt, d.PriceAdjAmtFgn, d.UnitPriceSellBasis, d.UnitPriceSellBasisFgn 
		, d.TotQtyOrdSell, d.TotQtyShipSell, d.LineSeq
		, d.BOLNum, d.Kit, d.GrpId, d.KitQty, d.OriCompQty, d.[Status], d.ResCode, isnull(k.DropShipYn, 0), d.ConversionFactor
		, d.PromoID, d.EffectiveRate, d.OrigOrderQty, d.BlanketDtlRef, d.CF, d.CustomerPartNumber
	FROM dbo.tblSoTransHeader h 
	INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID 
	LEFT JOIN dbo.tblSmTransLink k ON d.LinkSeqNum = k.SeqNum --capture the drop ship flag from trans link
	INNER JOIN #PostTransList l ON h.TransId = l.TransId


	--append lot history
	INSERT INTO dbo.tblArHistLot (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, CF) 
	SELECT @PostRun, h.TransId, e.EntryNum, e.SeqNum, d.ItemId, d.LocId, e.LotNum
		, e.QtyOrder, e.QtyFilled, CASE WHEN e.QtyFilled < e.QtyOrder THEN e.QtyFilled - e.QtyOrder ELSE 0 END
		, e.CostUnit, e.CostUnitFgn, e.HistSeqNum, e.Cmnt, e.CF 
	FROM dbo.tblSoTransHeader h 
	INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId 
	INNER JOIN dbo.tblSoTransDetailExt e on d.TransId = e.TransId and d.EntryNum = e.EntryNum
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE d.LottedYn = 1 AND e.LotNum IS NOT NULL


	--append serial numbers
	INSERT INTO dbo.tblArHistSer (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, SerNum, CostUnit, PriceUnit, CostUnitFgn, PriceUnitFgn, HistSeqNum, Cmnt, CF
		, ExtLocAID, ExtLocBID) 
	SELECT @PostRun, h.TransId, EntryNum, SeqNum, ItemId, s.LocId, LotNum
		, SerNum, CostUnit, PriceUnit, CostUnitFgn, PriceUnitFgn, HistSeqNum, Cmnt, s.CF 
		, a.ExtLocID, b.ExtLocID
	FROM dbo.tblSoTransHeader h 
	INNER JOIN dbo.tblSoTransSer s ON h.TransId = s.TransId 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	LEFT JOIN dbo.tblWmExtLoc a ON s.ExtLocA = a.Id
	LEFT JOIN dbo.tblWmExtLoc b ON s.ExtLocB = b.Id

		
	--append tax information
	INSERT INTO dbo.tblArHistTax (PostRun, TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, CF) 
	SELECT @PostRun, h.TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, t.CF 
	FROM dbo.tblSoTransHeader h 
	INNER JOIN dbo.tblSoTransTax t ON h.TransId = t.TransId 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId

	
	--update the PostRun for recurring entries in tblArHistRecur 
	UPDATE dbo.tblArHistRecur SET PostRun = @PostRun 
	FROM dbo.tblSoTransHeader h
		INNER JOIN dbo.tblArHistRecur ON h.TransID = dbo.tblArHistRecur.TransID 
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE dbo.tblArHistRecur.[Source] = 1 AND dbo.tblArHistRecur.PostRun IS NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_History_proc';

