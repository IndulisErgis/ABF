
CREATE PROCEDURE trav_SvWorkOrderPost_SalesHistory_proc
AS
BEGIN TRY

	DECLARE @PostRun pPostRun, @WksDate datetime, @CommByLineItemYn bit, @PrecUnitCost tinyint, @PrecUnitPrice tinyint, @PrecCurr tinyint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CommByLineItemYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CommByLineItemYn'
	SELECT @PrecUnitCost = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecUnitCost'
	SELECT @PrecUnitPrice = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecUnitPrice'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	
	IF @PostRun IS NULL OR @WksDate IS NULL	OR @CommByLineItemYn IS NULL OR @PrecUnitCost IS NULL OR @PrecUnitPrice IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	

	INSERT INTO dbo.tblArHistAddress (PostRun, CustId, [Name]
		, Contact, Attn, Address1, Address2, City, Region, Country, PostalCode, 
		Phone, Fax, Email, Internet)
	SELECT @PostRun, c.CustId, c.CustName
		, c.Contact, c.Attn, c.Addr1, c.Addr2, c.City, c.Region, c.Country, c.PostalCode
		, c.Phone, c.Fax, c.Email, c.Internet
	FROM dbo.tblArCust c
	INNER JOIN (SELECT h.BillToID From dbo.tblSvInvoiceHeader h INNER JOIN #PostTransList l
					 ON h.TransId = l.TransId  WHERE h.PrintStatus <>3 GROUP BY h.BillToID) t on c.CustId = t.BillToID
	LEFT JOIN (SELECT CustId From dbo.tblArHistAddress WHERE PostRun = @PostRun) a on c.CustId = a.CustId
	WHERE a.CustId IS NULL 
	
	--append headers
	INSERT INTO dbo.tblArHistHeader (PostRun, TransId, TransType, BatchId, CustId,
		ShipToID, ShipToName, ShipToAttn,ShipToAddr1, ShipToAddr2, ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode, ShipToPhone, 
		ShipVia, TermsCode, TaxableYN, InvcNum, CredMemNum, WhseId, OrderDate, ShipNum, ShipDate, InvcDate, 
		Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, TaxOnFreight, TaxClassFreight, TaxClassMisc, 
		PostDate, GLPeriod, FiscalYear, TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax, Freight, Misc, TotCost, 
		TaxSubtotalFgn, NonTaxSubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, TotCostFgn, PrintStatus, CustPONum, 
		DistCode, CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt, DiscAmtFgn, SumHistPeriod, TaxAmtAdj, 
		TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj,  SoldToId, Source, SourceInfo, SourceId, 
		ReturnDirectToStockYn, GLAcctReceivables, GLAcctSalesTax, GLAcctFreight, GLAcctMisc,  VoidYn, 
		 CF) 
	SELECT @PostRun, h.TransId, SIGN(TransType), BatchId, h.BillToID,
		w.SiteID,s.ShiptoName, w.Attention, w.Address1, w.Address2, w.City, w.Region,W.Country, w.PostalCode, w.Phone1,
		NULL, TermsCode, TaxableYN, InvoiceNumber, NULL, NULL, h.OrderDate, NULL, NULL, 
		InvoiceDate, h.Rep1Id, h.Rep1Pct, h.Rep1CommRate, h.Rep2Id, h.Rep2Pct, h.Rep2CommRate, 0, 0, 0, @WksDate, FiscalPeriod, FiscalYear, 
		TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax + TaxAmtAdj, 0, 0, TotCost, TaxSubtotalFgn, NonTaxSubtotalFgn, 
		SalesTaxFgn + TaxAmtAdjFgn, 0, 0, TotCostFgn, NULL, h.CustomerPoNumber, h.DistCode, h.CurrencyID, ExchRate, DiscDueDate, 
		NetDueDate, DiscAmt, DiscAmtFgn, FiscalPeriod, TaxAmtAdj, TaxAmtAdjFgn, NULL, TaxLocAdj, TaxClassAdj,  
		h.CustId, 2, NULL, SourceId , 0, dc.GLAcctReceivables, NULL, dc.GLAcctFreight, dc.GLAcctMisc, 
		h.VoidYn, h.CF
	FROM #PostTransList l INNER JOIN dbo.tblSvInvoiceHeader h ON l.TransId = h.TransId
		INNER JOIN tblSvWorkOrder w ON h.WorkOrderID =w.ID
		LEFT JOIN tblArShipTo s ON h.BillToID =s.CustId AND w.SiteID =s.ShiptoId
		LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
		WHERE h.PrintStatus <>3
		

	--sales tax (-1)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -1, 0, NULL, 0, 0, NULL, 1, 1, 1, 1
		, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj
		, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn
		, NULL, NULL, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM #PostTransList l INNER JOIN dbo.tblSvInvoiceHeader h ON l.TransId = h.TransId
	WHERE ((SalesTax + TaxAmtAdj) <> 0 OR (SalesTaxFgn + TaxAmtAdjFgn) <> 0) AND h.PrintStatus <>3
	
	--Freight
	INSERT INTO dbo.tblArHistDetail (PostRun, TransID, EntryNum, WhseId, PartId, ItemJob
		, JobId, PhaseId, [Desc], PartType, InItemYN, LottedYN, AddnlDesc, CatId, TransHistId
		, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyOrdSell, UnitsSell, UnitsBase
		, QtyShipBase, QtyShipSell, QtyBackordSell, PriceID, UnitPriceSell, UnitCostSell, UnitPriceSellFgn, UnitCostSellFgn
		, ExtFinalInc, ExtFinalIncFgn, ExtOrigInc,  PriceExt, PriceExtFgn, CostExt, CostExtFgn
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, UnitCommBasis, UnitCommBasisFgn
		, UnitPriceSellBasis, UnitPriceSellBasisFgn, 
		TotQtyOrdSell, TotQtyShipSell, LineSeq, ConversionFactor, CF,[Status]) 
	SELECT @PostRun, d.TransID, d.EntryNum, d.LocID, d.ResourceID, NULL,
		 NULL, NULL, d.[Description], 0, 0, 0, d.AdditionalDescription, CatID, a.Id, 
		 d.TaxClass, h.DistCode, dc.GLAcctFreight, GLAcctDebit, GLAcctCredit, QtyEstimated, Unit, ISNULL(i.UomBase,d.Unit),
		 d.QtyUsed * ISNULL(u.ConvFactor,1) , d.QtyUsed, 0, NULL, UnitPrice, UnitCost, UnitPriceFgn, 
		 CASE WHEN d.QtyUsed = 0 THEN d.CostExtFgn ELSE ROUND(d.CostExtFgn / d.QtyUsed, @PrecUnitCost) END, 
		d.PriceExt, d.PriceExtFgn, 0, d.PriceExt, d.PriceExtFgn, d.CostExt, d.CostExtFgn, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Id ELSE d.Rep1Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Pct ELSE d.Rep1Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1CommRate ELSE d.Rep1CommRate END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Id ELSE d.Rep2Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Pct ELSE d.Rep2Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2CommRate ELSE d.Rep2CommRate END, 
		ISNULL(d.UnitCommBasis,d.UnitCost), 
		ISNULL(d.UnitCommBasisFgn, CASE WHEN d.QtyUsed = 0 THEN d.CostExtFgn ELSE ROUND(d.CostExtFgn / d.QtyUsed, @PrecUnitCost) END), 
		UnitPrice, UnitPriceFgn,
		d.QtyEstimated, d.QtyUsed, d.LineSeq, ISNULL(u.ConvFactor, 1), d.CF, ISNULL(w.CancelledYN,0)
	FROM #PostTransList l INNER JOIN dbo.tblSvInvoiceHeader h ON l.TransId = h.TransId
		INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransId = d.TransID 
		LEFT JOIN dbo.tblInItem i ON d.[WorkOrderTransType] = 1 AND d.ResourceId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON d.[WorkOrderTransType] = 1 AND d.ResourceId = u.ItemId AND d.Unit = u.Uom
		LEFT JOIN dbo.tblSvWorkOrderDispatch w ON  d.DispatchID =w.ID
		LEFT JOIN dbo.tblPcActivity a ON d.WorkOrderTransID =a.SourceReference AND a.Source =13
		LEFT JOIN dbo.tblArDistCode dc ON  h.DistCode = dc.DistCode
		WHERE h.PrintStatus <>3 AND WorkOrderTransType =2 

		-- Misc
	INSERT INTO dbo.tblArHistDetail (PostRun, TransID, EntryNum, WhseId, PartId, ItemJob
		, JobId, PhaseId, [Desc], PartType, InItemYN, LottedYN, AddnlDesc, CatId, TransHistId
		, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyOrdSell, UnitsSell, UnitsBase
		, QtyShipBase, QtyShipSell, QtyBackordSell, PriceID, UnitPriceSell, UnitCostSell, UnitPriceSellFgn, UnitCostSellFgn
		, ExtFinalInc, ExtFinalIncFgn, ExtOrigInc,  PriceExt, PriceExtFgn, CostExt, CostExtFgn
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, UnitCommBasis, UnitCommBasisFgn
		, UnitPriceSellBasis, UnitPriceSellBasisFgn, 
		TotQtyOrdSell, TotQtyShipSell, LineSeq, ConversionFactor, CF,[Status]) 
	SELECT @PostRun, d.TransID, d.EntryNum, d.LocID, d.ResourceID, NULL,
		 NULL, NULL, d.[Description], 0, 0, 0, d.AdditionalDescription, CatID, a.Id, 
		 d.TaxClass, h.DistCode, dc.GLAcctMisc, GLAcctDebit, GLAcctCredit, QtyEstimated, Unit, ISNULL(i.UomBase,d.Unit),
		 d.QtyUsed * ISNULL(u.ConvFactor,1) , d.QtyUsed, 0, NULL, UnitPrice, UnitCost, UnitPriceFgn, 
		 CASE WHEN d.QtyUsed = 0 THEN d.CostExtFgn ELSE ROUND(d.CostExtFgn / d.QtyUsed, @PrecUnitCost) END, 
		d.PriceExt, d.PriceExtFgn, 0, d.PriceExt, d.PriceExtFgn, d.CostExt, d.CostExtFgn, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Id ELSE d.Rep1Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Pct ELSE d.Rep1Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1CommRate ELSE d.Rep1CommRate END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Id ELSE d.Rep2Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Pct ELSE d.Rep2Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2CommRate ELSE d.Rep2CommRate END, 
		ISNULL(d.UnitCommBasis,d.UnitCost), 
		ISNULL(d.UnitCommBasisFgn, CASE WHEN d.QtyUsed = 0 THEN d.CostExtFgn ELSE ROUND(d.CostExtFgn / d.QtyUsed, @PrecUnitCost) END), 
		UnitPrice, UnitPriceFgn,
		d.QtyEstimated, d.QtyUsed, d.LineSeq, ISNULL(u.ConvFactor, 1), d.CF, ISNULL(w.CancelledYN,0)
	FROM #PostTransList l INNER JOIN dbo.tblSvInvoiceHeader h ON l.TransId = h.TransId
		INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransId = d.TransID 
		LEFT JOIN dbo.tblInItem i ON d.[WorkOrderTransType] = 1 AND d.ResourceId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON d.[WorkOrderTransType] = 1 AND d.ResourceId = u.ItemId AND d.Unit = u.Uom
		LEFT JOIN dbo.tblSvWorkOrderDispatch w ON  d.DispatchID =w.ID
		LEFT JOIN dbo.tblPcActivity a ON d.WorkOrderTransID =a.SourceReference AND a.Source =13
		LEFT JOIN dbo.tblArDistCode dc ON  h.DistCode = dc.DistCode
		WHERE h.PrintStatus <>3 AND WorkOrderTransType =3
	
	--append detail 
	INSERT INTO dbo.tblArHistDetail (PostRun, TransID, EntryNum, WhseId, PartId, ItemJob
		, JobId, PhaseId, [Desc], PartType, InItemYN, LottedYN, AddnlDesc, CatId, TransHistId
		, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyOrdSell, UnitsSell, UnitsBase
		, QtyShipBase, QtyShipSell, QtyBackordSell, PriceID, UnitPriceSell, UnitCostSell, UnitPriceSellFgn, UnitCostSellFgn
		, ExtFinalInc, ExtFinalIncFgn, ExtOrigInc,  PriceExt, PriceExtFgn, CostExt, CostExtFgn
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, UnitCommBasis, UnitCommBasisFgn
		, UnitPriceSellBasis, UnitPriceSellBasisFgn, 
		TotQtyOrdSell, TotQtyShipSell, LineSeq, ConversionFactor, CF,[Status]) 
	SELECT @PostRun, d.TransID, d.EntryNum, d.LocID, d.ResourceID, NULL,
		 NULL, NULL, d.[Description], 0, 0, 0, d.AdditionalDescription, CatID, a.Id, 
		 d.TaxClass, h.DistCode, GLAcctSales, GLAcctDebit, GLAcctCredit, QtyEstimated, Unit, ISNULL(i.UomBase,d.Unit),
		 d.QtyUsed * ISNULL(u.ConvFactor,1) , d.QtyUsed, 0, NULL, UnitPrice, UnitCost, UnitPriceFgn, 
		 CASE WHEN d.QtyUsed = 0 THEN d.CostExtFgn ELSE ROUND(d.CostExtFgn / d.QtyUsed, @PrecUnitCost) END, 
		d.PriceExt, d.PriceExtFgn, 0, d.PriceExt, d.PriceExtFgn, d.CostExt, d.CostExtFgn, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Id ELSE d.Rep1Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Pct ELSE d.Rep1Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1CommRate ELSE d.Rep1CommRate END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Id ELSE d.Rep2Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Pct ELSE d.Rep2Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2CommRate ELSE d.Rep2CommRate END, 
		ISNULL(d.UnitCommBasis,d.UnitCost), 
		ISNULL(d.UnitCommBasisFgn, CASE WHEN d.QtyUsed = 0 THEN d.CostExtFgn ELSE ROUND(d.CostExtFgn / d.QtyUsed, @PrecUnitCost) END), 
		UnitPrice, UnitPriceFgn,
		d.QtyEstimated, d.QtyUsed, d.LineSeq, ISNULL(u.ConvFactor, 1), d.CF, ISNULL(w.CancelledYN,0)
	FROM #PostTransList l INNER JOIN dbo.tblSvInvoiceHeader h ON l.TransId = h.TransId
		INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransId = d.TransID 
		LEFT JOIN dbo.tblInItem i ON d.[WorkOrderTransType] = 1 AND d.ResourceId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON d.[WorkOrderTransType] = 1 AND d.ResourceId = u.ItemId AND d.Unit = u.Uom
		LEFT JOIN dbo.tblSvWorkOrderDispatch w ON  d.DispatchID =w.ID
		LEFT JOIN dbo.tblPcActivity a ON d.WorkOrderTransID =a.SourceReference AND a.Source =13
		WHERE h.PrintStatus <>3 AND WorkOrderTransType <>2 AND  WorkOrderTransType <>3

	--append lot history
	INSERT INTO dbo.tblArHistLot (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, CF) 

	SELECT @PostRun, h.TransId, EntryNum, e.ID, d.ResourceID, d.LocID, LotNum, e.QtyEstimated, e.QtyUsed, 0,
	  e.UnitCost, ROUND(e.UnitCost * h.ExchRate,c.CurrDecPlaces) CostUnitFgn, HistSeqNum, Cmnt, d.CF 
	FROM  dbo.tblSvInvoiceHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransId = d.TransID 
	INNER JOIN dbo.tblSvWorkOrderTransExt e  ON d.WorkOrderTransID = e.TransID
	INNER JOIN #tmpCurrencyList c ON c.CurrencyId =h.CurrencyID
	WHERE h.PrintStatus <>3

	--append serial numbers
	INSERT INTO dbo.tblArHistSer (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
		, SerNum, CostUnit, PriceUnit, CostUnitFgn, PriceUnitFgn, HistSeqNum, Cmnt, CF) 

	SELECT @PostRun, h.TransId, EntryNum, s.ID, d.ResourceID, LocId, LotNum	, SerNum, s.UnitCost
		, s.UnitPrice, ROUND(s.UnitCost * h.ExchRate,c.CurrDecPlaces) CostUnitFgn
		, ROUND(s.UnitPrice * h.ExchRate,c.CurrDecPlaces)  PriceUnitFgn, HistSeqNum, Cmnt, s.CF 
	FROM  dbo.tblSvInvoiceHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransId = d.TransID 
	INNER JOIN dbo.tblSvWorkOrderTransSer s ON d.WorkOrderTransID = s.TransId 
	INNER JOIN #tmpCurrencyList c ON c.CurrencyId =h.CurrencyID
	WHERE h.PrintStatus <>3

	--append tax information
	INSERT INTO dbo.tblArHistTax (PostRun, TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, CF) 
	SELECT @PostRun, h.TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, t.CF 
	FROM #PostTransList l INNER JOIN dbo.tblSvInvoiceHeader h ON l.TransId = h.TransId
	INNER JOIN dbo.tblSvInvoiceTax t ON h.TransId = t.TransId 
	WHERE h.PrintStatus <>3

	


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_SalesHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_SalesHistory_proc';

