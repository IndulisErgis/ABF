
CREATE PROCEDURE dbo.trav_PsLayawayPost_SalesHistory_proc
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @PostRun pPostRun, @WrkStnDate datetime, @FiscalYear smallint, @FiscalPeriod smallint,
		@PrecUCost tinyint, @PrecUPrice tinyint, @PrecQty tinyint, @CurrBase pCurrency

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @PrecUCost = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecUCost'
	SELECT @PrecUPrice = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecUPrice'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @PostRun IS NULL OR @WrkStnDate IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL OR @PrecUCost IS NULL 
		OR @PrecUPrice IS NULL OR @PrecQty IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--append customer addresses
	INSERT INTO dbo.tblArHistAddress (PostRun, CustId, [Name], Contact, Attn, Address1, Address2, City, Region, 
		Country, PostalCode, Phone, Fax, Email, Internet)
	SELECT @PostRun, c.CustId, c.CustName, c.Contact, c.Attn, c.Addr1, c.Addr2, c.City, c.Region, c.Country, 
		c.PostalCode, c.Phone, c.Fax, c.Email, c.Internet
	FROM dbo.tblArCust c INNER JOIN (SELECT h.BillToID FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		WHERE h.BillToID IS NOT NULL AND h.VoidDate IS NULL GROUP BY h.BillToID) t ON c.CustId = t.BillToID 
		LEFT JOIN dbo.tblArHistAddress a ON c.CustId = a.CustId AND a.PostRun = @PostRun
	WHERE a.PostRun IS NULL

	--append headers
	INSERT INTO dbo.tblArHistHeader (PostRun, TransId, TransType, BatchId, CustId, ShipToID, ShipToName,ShipToAttn , ShipToAddr1, 
		ShipToAddr2, ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode, ShipToPhone, ShipVia, TermsCode, TaxableYN, 
		InvcNum, CredMemNum, WhseId, OrderDate, ShipNum, ShipDate, InvcDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, 
		Rep2CommRate, TaxOnFreight, TaxClassFreight, TaxClassMisc, PostDate, GLPeriod, FiscalYear, TaxGrpID, TaxSubtotal, 
		NonTaxSubtotal, SalesTax, Freight, Misc, TotCost, TaxSubtotalFgn, NonTaxSubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, 
		TotCostFgn, PrintStatus, CustPONum, DistCode, CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt, DiscAmtFgn, 
		SumHistPeriod, TaxAmtAdj, TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj, CalcGainLoss, SoldToId, CustLevel, PODate, 
		ReqShipDate, PickNum, PackNum, BlanketRef, [Source], SourceInfo, SourceId, ReturnDirectToStockYn, GLAcctReceivables, 
		GLAcctSalesTax, GLAcctFreight, GLAcctMisc, GlAcctGainLoss, VoidYn, Notes, TotPmtAmt, TotPmtAmtFgn, TotPmtGainLoss, CF) 
	SELECT @PostRun, t.TransID, 1, NULL, h.BillToID, h.ShipToID, c.Name, c.Attn , c.Address1, c.Address2, c.City, c.Region, 
		c.Country, c.PostalCode, c.Phone, h.ShipVia, u.TermsCode, h.TaxableYN, t.InvoiceNum, NULL,t.LocID, h.TransDate, h.ShipNum, h.CompletedDate, h.CompletedDate, 
		h.SalesRepID, 100, r.CommRate, NULL, 0, 0, 1, 0, 0, @WrkStnDate, @FiscalPeriod, @FiscalYear, h.TaxGroupID, x.Taxable, x.NonTaxable, ISNULL(d.Tax,0), 0, 0, 
		ISNULL(d.ExtCost,0), x.Taxable, x.NonTaxable, ISNULL(d.Tax,0), 0, 0, ISNULL(d.ExtCost,0), 2, h.PONumber, t.DistCode, h.CurrencyID, 1, NULL, h.DueDate, 0, 0, @FiscalPeriod, 
		0, 0, NULL, NULL, NULL, 0, h.SoldToID, CustLevel, h.PODate, ISNULL(h.ReqShipDate, h.TransDate), NULL, NULL, NULL, 4, NULL, h.SourceId, 1, o.GLAcctReceivables, NULL, o.GLAcctFreight, 
		o.GLAcctMisc, NULL, CASE WHEN h.VoidDate IS NULL THEN 0 ELSE 1 END, h.Notes, ISNULL(d.Payment, 0), ISNULL(d.Payment, 0), 0, h.CF
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		LEFT JOIN (SELECT d.HeaderID, SUM(CASE WHEN d.LineType = -1 THEN d.ExtPrice ELSE 0 END) AS Payment, SUM(CASE WHEN d.LineType = 2 THEN d.ExtPrice ELSE 0 END) AS Tax,
				SUM(i.ExtCost) AS ExtCost
			FROM dbo.tblPsTransDetail d LEFT JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID
			GROUP BY d.HeaderID) d ON h.ID = d.HeaderID 
		LEFT JOIN (SELECT HeaderID, SUM(Taxable) Taxable, SUM(NonTaxable) NonTaxable
			FROM dbo.tblPsTransTax GROUP BY HeaderID) x ON h.ID = x.HeaderID 
		LEFT JOIN dbo.tblArCust u ON h.BillToID = u.CustId 
		LEFT JOIN dbo.tblArDistCode o ON t.DistCode = o.DistCode
		LEFT JOIN dbo.tblArSalesRep r ON h.SalesRepID = r.SalesRepID
		LEFT JOIN (SELECT HeaderID, Name, Address1, Address2, City, Region, Country, PostalCode, Phone, Attn 
			FROM dbo.tblPsTransContact WHERE [Type] = 2) c ON h.ID = c.HeaderID
	WHERE h.VoidDate IS NULL

	--Sales tax;
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales, ConversionFactor, QtyShipSell, 
		QtyShipBase, TotQtyShipSell, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn, ReqShipDate, 
		ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, t.TransID, -1, 0, t.LocID, 0, 0, NULL, 1, 1, 1, 1, d.ExtPrice, d.ExtPrice, d.ExtPrice, d.ExtPrice, 
		d.ExtPrice, d.ExtPrice, h.TransDate, h.TransDate, h.SalesRepID, 100, r.CommRate, NULL, 0, 0
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN (SELECT HeaderID, SUM(ExtPrice) AS ExtPrice FROM dbo.tblPsTransDetail 
			WHERE LineType = 2 GROUP BY HeaderID HAVING SUM(ExtPrice) <> 0) d ON h.ID = d.HeaderID
		LEFT JOIN dbo.tblArSalesRep r ON h.SalesRepID = r.SalesRepID
	WHERE h.VoidDate IS NULL

	--Freight; Misc
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales, ConversionFactor, QtyShipSell, 
		QtyShipBase, TotQtyShipSell, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn, ReqShipDate, 
		ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, [Desc], AddnlDesc)
	SELECT @PostRun, t.TransID, CASE d.LineType WHEN 3 THEN -2 WHEN 4 THEN -3 END, 0, t.LocID, 0, d.TaxClass, 
		CASE d.LineType WHEN 3 THEN c.GLAcctFreight WHEN 4 THEN c.GLAcctMisc END, 1, 1, 1, 1, d.ExtPrice, d.ExtPrice, d.ExtPrice, d.ExtPrice, d.ExtPrice, 
		d.ExtPrice, h.TransDate, h.TransDate, h.SalesRepID, 100, r.CommRate, NULL, 0, 0, CASE d.LineType WHEN 3 THEN 'Freight' WHEN 4 THEN 'Misc' END, NULL
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN (SELECT HeaderID, TaxClass, LineType, SUM(ExtPrice) AS ExtPrice FROM dbo.tblPsTransDetail 
			WHERE LineType IN (3,4) AND ExtPrice <> 0 GROUP BY HeaderID, TaxClass, LineType) d ON h.ID = d.HeaderID
		LEFT JOIN dbo.tblArDistCode c ON t.DistCode = c.DistCode 
		LEFT JOIN dbo.tblArSalesRep r ON h.SalesRepID = r.SalesRepID
	WHERE h.VoidDate IS NULL

	--Line item 
	INSERT INTO dbo.tblArHistDetail (PostRun, TransID, EntryNum, ItemJob, WhseId, PartId, JobId, PhaseId, JobCompleteYN, [Desc], PartType, InItemYN, 
		LottedYN, AddnlDesc, CatId, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyOrdSell, UnitsSell, UnitsBase, QtyShipBase, QtyShipSell, 
		QtyBackordSell, PriceID, UnitPriceSell, UnitCostSell, UnitPriceSellFgn, UnitCostSellFgn, HistSeqNum, ReqShipDate, ActShipDate, PriceExt, 
		PriceExtFgn, CostExt, CostExtFgn, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, UnitCommBasis, UnitCommBasisFgn, PriceAdjType, 
		PriceAdjPct, PriceAdjAmt, PriceAdjAmtFgn, UnitPriceSellBasis, UnitPriceSellBasisFgn, TotQtyOrdSell, TotQtyShipSell, LineSeq, BOLNum, Kit, 
		GrpId, KitQty, OriCompQty, ResCode, DropShipYn, ConversionFactor, PromoID, EffectiveRate, OrigOrderQty, BlanketDtlRef, CF) 
	SELECT @PostRun, t.TransID, d.EntryNum, d.LineSeq, d.LocId, d.ItemId, NULL, NULL, NULL, d.[Descr], CASE WHEN i.ItemId IS NULL THEN 0 ELSE i.ItemType END, 
		CASE WHEN i.ItemId IS NULL THEN 0 ELSE 1 END, CASE WHEN i.ItemId IS NULL THEN 0 ELSE i.LottedYN END, d.Notes, i.SalesCat, d.TaxClass, 
		l.GLAcctCode, CASE WHEN i.ItemId IS NULL THEN c.GLAcctSales ELSE g.GLAcctSales END, CASE WHEN i.ItemId IS NULL THEN c.GLAcctCOGS ELSE g.GLAcctCOGS END, 
		CASE WHEN i.ItemId IS NULL THEN c.GLAcctInv ELSE g.GLAcctInv END, d.Qty, d.Unit, i.UomBase, ROUND(ISNULL(u.ConvFactor, 1) * d.Qty, @PrecQty), d.Qty, 0
		, NULL, CASE d.Qty WHEN 0 THEN d.ExtPrice - ISNULL(p.ExtPrice,0) ELSE ROUND((d.ExtPrice - ISNULL(p.ExtPrice,0)) / d.Qty, @PrecUPrice) END, 
		CASE d.Qty WHEN 0 THEN ISNULL(n.ExtCost,0) ELSE ROUND(ISNULL(n.ExtCost,0) / d.Qty, @PrecUCost) END, 
		CASE d.Qty WHEN 0 THEN d.ExtPrice - ISNULL(p.ExtPrice,0) ELSE ROUND((d.ExtPrice - ISNULL(p.ExtPrice,0)) / d.Qty, @PrecUPrice) END, 
		CASE d.Qty WHEN 0 THEN ISNULL(n.ExtCost,0) ELSE ROUND(ISNULL(n.ExtCost,0) / d.Qty, @PrecUCost) END, n.HistSeqNum, NULL, NULL, 
		d.ExtPrice - ISNULL(p.ExtPrice,0), d.ExtPrice - ISNULL(p.ExtPrice,0), ISNULL(n.ExtCost,0), ISNULL(n.ExtCost,0), d.SalesRepID, 100, r.CommRate, NULL, 0, 0, 
		CASE d.Qty WHEN 0 THEN ISNULL(n.ExtCost,0) ELSE ROUND(ISNULL(n.ExtCost,0) / d.Qty, @PrecUCost) END, 
		CASE d.Qty WHEN 0 THEN ISNULL(n.ExtCost,0) ELSE ROUND(ISNULL(n.ExtCost,0) / d.Qty, @PrecUCost) END, NULL, NULL, NULL, NULL, 
		CASE d.Qty WHEN 0 THEN d.ExtPrice - ISNULL(p.ExtPrice,0) ELSE ROUND((d.ExtPrice - ISNULL(p.ExtPrice,0)) / d.Qty, @PrecUPrice) END, 
		CASE d.Qty WHEN 0 THEN d.ExtPrice - ISNULL(p.ExtPrice,0) ELSE ROUND((d.ExtPrice - ISNULL(p.ExtPrice,0)) / d.Qty, @PrecUPrice) END, d.Qty, d.Qty, d.LineSeq, 
		NULL, 0, NULL, NULL, NULL, NULL, 0, ISNULL(u.ConvFactor, 1), d.PromoID, NULL, d.Qty, NULL, d.CF
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		LEFT JOIN (SELECT ParentID, SUM(ExtPrice) ExtPrice FROM dbo.tblPsTransDetail 
			WHERE ParentID IS NOT NULL GROUP BY ParentID) p ON d.ID = p.ParentID --Line item Discount/Coupon
		LEFT JOIN dbo.tblPsTransDetailIN n ON d.ID = n.DetailID
		LEFT JOIN dbo.tblInItem i ON d.ItemID = i.ItemId 
		LEFT JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId AND d.LocId = l.LocId 
		LEFT JOIN dbo.tblInItemUom u ON d.ItemID = u.ItemId AND d.Unit = u.Uom
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
		LEFT JOIN dbo.tblPsDistCode c ON t.DistCode = c.DistCode 
		LEFT JOIN dbo.tblArSalesRep r ON h.SalesRepID = r.SalesRepID 
	WHERE h.VoidDate IS NULL AND d.LineType = 1

	--Coupon and Discount of transaction;
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, t.TransID, d.EntryNum, d.LineSeq, t.LocID, 0, d.TaxClass, CASE WHEN h.VoidDate IS NULL THEN NULL ELSE CASE d.LineType WHEN -2 THEN c.GLAcctCoupon 
		WHEN -3 THEN c.GLAcctDiscount WHEN -4 THEN c.GLAcctRounding END END, 1, 1, 1, 1, -d.ExtPrice, -d.ExtPrice, -d.ExtPrice, -d.ExtPrice, -d.ExtPrice, -d.ExtPrice, 
		h.TransDate, h.TransDate, h.SalesRepID, 100, r.CommRate, NULL, 0, 0
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN tblPsTransDetail d ON h.ID = d.HeaderID
		LEFT JOIN dbo.tblPsDistCode c ON t.DistCode = c.DistCode 
		LEFT JOIN dbo.tblArSalesRep r ON h.SalesRepID = r.SalesRepID
	WHERE h.VoidDate IS NULL AND d.LineType IN (-2,-3) AND d.ParentID IS NULL AND d.ExtPrice <> 0

	--Lot history
	INSERT INTO dbo.tblArHistLot (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, 
		HistSeqNum, Cmnt, CF) 
	SELECT @PostRun, t.TransID, d.EntryNum, 0, d.ItemId, d.LocId, d.LotNum, d.Qty, d.Qty, 0, CASE d.Qty WHEN 0 THEN 0 ELSE ROUND(i.ExtCost / d.Qty, @PrecUCost) END, 
		CASE d.Qty WHEN 0 THEN 0 ELSE ROUND(i.ExtCost / d.Qty, @PrecUCost) END, i.HistSeqNum, NULL, d.CF --TODO, cmnt
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		INNER JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID
	WHERE h.VoidDate IS NULL AND d.LotNum IS NOT NULL

	--Serial history
	INSERT INTO dbo.tblArHistSer (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum, SerNum, CostUnit, PriceUnit, CostUnitFgn, 
		PriceUnitFgn, HistSeqNum, Cmnt, CF, ExtLocAID, ExtLocBID) 
	SELECT @PostRun, t.TransID, d.EntryNum, 0, d.ItemId, d.LocId, d.LotNum, SerNum, i.ExtCost, d.ExtPrice, i.ExtCost, d.ExtPrice, 
		i.HistSeqNumSer, NULL, d.CF, NULL, NULL
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		INNER JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID
	WHERE h.VoidDate IS NULL AND d.SerNum IS NOT NULL
		
	--Tax history
	INSERT INTO dbo.tblArHistTax (PostRun, TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, CF) 
	SELECT @PostRun, t.TransID, x.TaxLocID, x.TaxClass, x.TaxLevel, x.TaxAmt, x.TaxAmt
		, Taxable, Taxable, NonTaxable, NonTaxable, l.GLAcct, x.CF 
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransTax x ON h.ID = x.HeaderID
		LEFT JOIN dbo.tblSmTaxLoc l ON x.TaxLocID = l.TaxLocId
	WHERE h.VoidDate IS NULL

	--Payment history
	--append payment of completed layaway that does not have rounding adjustment
	--or non-cash payment of completed layaway
	INSERT dbo.tblArHistPmt (PostRun, PostDate, RecType, CustId, TransId, DepNum, InvcNum, CheckNum, CcNum, CcHolder, CcAuth, CcExpire, BankID, BankName, 
		BankRoutingCode, BankAcctNum, PmtMethodId, CurrencyId, ExchRate, PmtDate, PmtAmt, DiffDisc, PmtAmtFgn, DiffDiscFgn, PmtType, SumHistPeriod, GLPeriod, 
		FiscalYear, GLRecvAcct, GlAcctGainLoss, GlAcctDebit, Rep1Id, Rep2Id, DistCode, CalcGainLoss, Note, SourceId, VoidYn, CF) 
	SELECT @PostRun, @WrkStnDate, 0, h.BillToID, t.TransID, NULL, i.InvoiceNum, p.CheckNum, p.CcNum, p.CcHolder, p.CcAuth, p.CcExpire, m.BankId, p.BankName,
		p.BankRoutingCode, p.BankAcctNum, p.PmtMethodID, @CurrBase, 1, p.PmtDate, p.AmountBase, 0, p.AmountBase, 0, m.PmtType, @FiscalPeriod, @FiscalPeriod, --Standard: only supports base currency external transactions
		@FiscalYear, c.GLAcctReceivables, NULL, CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE m.GLAcctDebit END, --Use the bank gl account for Cash, Check and Direct Debit 
		h.SalesRepID, NULL, i.DistCode, 0, p.Notes, h.SourceID, CASE WHEN p.VoidDate IS NULL THEN 0 ELSE 1 END, p.CF
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN #PsCompletedLayawayList i ON p.HeaderID = i.ID 
		INNER JOIN dbo.tblPsTransHeader h ON i.ID = h.ID
		LEFT JOIN dbo.tblArDistCode c ON i.DistCode = c.DistCode
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID 
		LEFT JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId 
		LEFT JOIN (SELECT t.ID FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransDetail d ON t.ID = d.HeaderID WHERE LineType = -4 AND ExtPrice <> 0 GROUP BY t.ID) r 
			ON h.ID = r.ID
	WHERE p.VoidDate IS NULL AND (p.PmtType <> 1 OR r.ID IS NULL)  

	--append cash payment of completed layaway that has rounding adjustment
	--adjust DiffDisc amount for last cash payment using rounding adjustment
	INSERT dbo.tblArHistPmt (PostRun, PostDate, RecType, CustId, TransId, DepNum, InvcNum, CheckNum, CcNum, CcHolder, CcAuth, CcExpire, BankID, BankName, 
		BankRoutingCode, BankAcctNum, PmtMethodId, CurrencyId, ExchRate, PmtDate, PmtAmt, DiffDisc, PmtAmtFgn, DiffDiscFgn, PmtType, SumHistPeriod, GLPeriod, 
		FiscalYear, GLRecvAcct, GlAcctGainLoss, GlAcctDebit, Rep1Id, Rep2Id, DistCode, CalcGainLoss, Note, SourceId, VoidYn, CF) 
	SELECT @PostRun, @WrkStnDate, 0, h.BillToID, t.TransID, NULL, i.InvoiceNum, p.CheckNum, p.CcNum, p.CcHolder, p.CcAuth, p.CcExpire, m.BankId, p.BankName,
		p.BankRoutingCode, p.BankAcctNum, p.PmtMethodID, @CurrBase, 1, p.PmtDate, p.AmountBase, CASE WHEN x.ID IS NULL THEN 0 ELSE r.RoudingAdj END, --Standard: only supports base currency external transactions
		p.AmountBase, CASE WHEN x.ID IS NULL THEN 0 ELSE r.RoudingAdj END, m.PmtType, @FiscalPeriod, @FiscalPeriod,
		@FiscalYear, c.GLAcctReceivables, NULL, CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE m.GLAcctDebit END, --Use the bank gl account for Cash, Check and Direct Debit 
		h.SalesRepID, NULL, i.DistCode, 0, p.Notes, h.SourceID, CASE WHEN p.VoidDate IS NULL THEN 0 ELSE 1 END, p.CF
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN #PsCompletedLayawayList i ON p.HeaderID = i.ID 
		INNER JOIN dbo.tblPsTransHeader h ON i.ID = h.ID
		INNER JOIN (SELECT t.ID, SUM(ExtPrice) AS RoudingAdj FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransDetail d ON t.ID = d.HeaderID WHERE LineType = -4 AND ExtPrice <> 0 GROUP BY t.ID) r 
			ON h.ID = r.ID 
		LEFT JOIN (SELECT l.ID, MAX(p.EntryDate) LastPmtDate FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID --Last cash payment
			INNER JOIN #PsCompletedLayawayList l ON p.HeaderID = l.ID 
			WHERE p.PmtType = 1
			GROUP BY l.ID) x ON h.ID = x.ID AND p.EntryDate = x.LastPmtDate
		LEFT JOIN dbo.tblArDistCode c ON i.DistCode = c.DistCode
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID 
		LEFT JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId 
	WHERE p.VoidDate IS NULL AND p.PmtType = 1

	--payment of incomplete layaway
	INSERT dbo.tblArHistPmt (PostRun, PostDate, RecType, CustId, TransId, DepNum, InvcNum, CheckNum, CcNum, CcHolder, CcAuth, CcExpire, BankID, BankName, 
		BankRoutingCode, BankAcctNum, PmtMethodId, CurrencyId, ExchRate, PmtDate, PmtAmt, DiffDisc, PmtAmtFgn, DiffDiscFgn, PmtType, SumHistPeriod, GLPeriod, 
		FiscalYear, GLRecvAcct, GlAcctGainLoss, GlAcctDebit, Rep1Id, Rep2Id, DistCode, CalcGainLoss, Note, SourceId, VoidYn, CF) 
	SELECT @PostRun, @WrkStnDate, 0, h.BillToID, t.TransID, NULL, i.InvoiceNum, p.CheckNum, p.CcNum, p.CcHolder, p.CcAuth, p.CcExpire, m.BankId, p.BankName,
		p.BankRoutingCode, p.BankAcctNum, p.PmtMethodID, @CurrBase, 1, p.PmtDate, p.AmountBase, 0, p.AmountBase, 0, m.PmtType, @FiscalPeriod, @FiscalPeriod,--Standard: only supports base currency external transactions
		@FiscalYear, c.GLAcctReceivables, NULL, CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE m.GLAcctDebit END, --Use the bank gl account for Cash, Check and Direct Debit 
		h.SalesRepID, NULL, i.DistCode, 0, p.Notes, h.SourceID, CASE WHEN p.VoidDate IS NULL THEN 0 ELSE 1 END, p.CF
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN #PsIncompleteLayawayList i ON p.HeaderID = i.ID 
		INNER JOIN dbo.tblPsTransHeader h ON i.ID = h.ID
		LEFT JOIN dbo.tblArDistCode c ON i.DistCode = c.DistCode
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID 
		LEFT JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId 
	WHERE p.VoidDate IS NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_SalesHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_SalesHistory_proc';

