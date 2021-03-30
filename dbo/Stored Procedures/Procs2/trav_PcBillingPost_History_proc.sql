
CREATE PROCEDURE dbo.trav_PcBillingPost_History_proc
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
	INNER JOIN (SELECT h.CustId From dbo.tblPcInvoiceHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId GROUP BY h.CustId) t on c.CustId = t.CustId
	LEFT JOIN (SELECT CustId From dbo.tblArHistAddress WHERE PostRun = @PostRun) a on c.CustId = a.CustId
	WHERE a.CustId IS NULL
	
	--append headers
	INSERT INTO dbo.tblArHistHeader (PostRun, TransId, TransType, BatchId, CustId, ShipToID, ShipToName, 
		ShipToAddr1, ShipToAddr2, ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode, ShipToPhone, 
		ShipVia, TermsCode, TaxableYN, InvcNum, CredMemNum, WhseId, OrderDate, ShipNum, ShipDate, InvcDate, 
		Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, TaxOnFreight, TaxClassFreight, TaxClassMisc, 
		PostDate, GLPeriod, FiscalYear, TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax, Freight, Misc, TotCost, 
		TaxSubtotalFgn, NonTaxSubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, TotCostFgn, PrintStatus, CustPONum, 
		DistCode, CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt, DiscAmtFgn, SumHistPeriod, TaxAmtAdj, 
		TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj, CalcGainLoss, SoldToId, Source, SourceInfo, SourceId, 
		ReturnDirectToStockYn, GLAcctReceivables, GLAcctSalesTax, GLAcctFreight, GLAcctMisc, GlAcctGainLoss, VoidYn, 
		TotPmtAmt, TotPmtAmtFgn, TotPmtGainLoss, CF, PrintOption,ShipToAttn) 
	SELECT @PostRun, h.TransId, SIGN(TransType), BatchId, h.CustId, s.SiteID,s.Name,s.Address1,s.Address2,s.City,s.Region,s.Country,s.PostalCode,s.Phone,NULL, 
		TermsCode, TaxableYN, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), OrgInvcNum, h.LocId, h.OrderDate, NULL, NULL, 
		InvcDate, h.Rep1Id, h.Rep1Pct, h.Rep1CommRate, h.Rep2Id, h.Rep2Pct, h.Rep2CommRate, 0, 0, 0, @WksDate, FiscalPeriod, FiscalYear, 
		TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax + TaxAmtAdj, 0, 0, TotCost, TaxSubtotalFgn, NonTaxSubtotalFgn, 
		SalesTaxFgn + TaxAmtAdjFgn, 0, 0, TotCostFgn, PrintStatus, h.CustPONum, h.DistCode, h.CurrencyID, ExchRate, DiscDueDate, 
		NetDueDate, DiscAmt, DiscAmtFgn, FiscalPeriod, TaxAmtAdj, TaxAmtAdjFgn, NULL, TaxLocAdj, TaxClassAdj, CalcGainLoss, 
		h.CustId, 3, NULL, SourceId , 0, dc.GLAcctReceivables, NULL, dc.GLAcctFreight, dc.GLAcctMisc, 
		CASE WHEN h.TransType < 0 AND -h.CalcGainLoss <> 0 THEN --applies only to Credit Memos with an amount 
			CASE WHEN -h.CalcGainLoss > 0 -- sign is flipped for proper account retrieval
			THEN t.RealGainAcct ELSE t.RealLossAcct END	ELSE NULL --no gain/loss account for Invoices
			END  GlAcctGainLoss, h.VoidYn, ISNULL(pmt.DepositTotal, 0), ISNULL(pmt.DepositTotalFgn, 0), 0, h.CF, h.PrintOption,s.Attention
	FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId		
		LEFT JOIN 
		(	SELECT d.TransId, MIN(p.ProjectDetailId) ProjectDetailId
			FROM dbo.tblPcInvoiceDetail d INNER JOIN dbo.tblPcProjectDetail pd ON d.ProjectDetailId = pd.Id
			INNER JOIN dbo.trav_PcProject_view p ON pd.ProjectId = p.Id 
			GROUP BY d.TransId 
		) pd ON h.TransId = pd.TransId
		LEFT JOIN  dbo.tblPcProjectDetailSiteInfo s ON pd.ProjectDetailId = s.ProjectDetailID
		LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode
		LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
		LEFT JOIN (SELECT l.TransID, SUM(p.DepositAmtApply) DepositTotal, 
			SUM(ROUND(p.DepositAmtApply * h.ExchRate, ISNULL(c.CurrDecPlaces, @PrecCurr))) DepositTotalFgn 
			FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId 
			INNER JOIN dbo.tblPcInvoiceDeposit p ON h.TransId = p.TransId 
			LEFT JOIN #tmpCurrencyList c ON h.CurrencyID = c.CurrencyId  
			GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId	

	--sales tax (-1)
	INSERT INTO dbo.tblArHistDetail (PostRun, TransId, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcctSales
		, ConversionFactor, QtyShipSell, QtyShipBase, TotQtyShipSell
		, UnitPriceSell, UnitPriceSellBasis, PriceExt, UnitPriceSellFgn, UnitPriceSellBasisFgn, PriceExtFgn
		, ReqShipDate, ActShipDate, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate)
	SELECT @PostRun, h.TransID, -1, 0, LocId, 0, 0, NULL, 1, 1, 1, 1
		, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj, SalesTax + TaxAmtAdj
		, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn, SalesTaxFgn + TaxAmtAdjFgn
		, NULL, NULL, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId
	WHERE (SalesTax + TaxAmtAdj) <> 0 OR (SalesTaxFgn + TaxAmtAdjFgn) <> 0
	
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
		, NULL, NULL, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate
	FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId
		LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
	WHERE h.TransType < 0 AND h.CalcGainLoss <> 0 --applies only to Credit Memos with an amount 
	
	--append detail 
	INSERT INTO dbo.tblArHistDetail (PostRun, TransID, EntryNum, WhseId, PartId, ItemJob
		, JobId, PhaseId, [Desc], PartType, InItemYN, LottedYN, AddnlDesc, CatId, TransHistId
		, TaxClass, AcctCode, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyOrdSell, UnitsSell, UnitsBase
		, QtyShipBase, QtyShipSell, QtyBackordSell, PriceID, UnitPriceSell, UnitCostSell, UnitPriceSellFgn, UnitCostSellFgn
		, ExtFinalInc, ExtFinalIncFgn, ExtOrigInc, ProjName, PhaseName, TaskName, PriceExt, PriceExtFgn, CostExt, CostExtFgn
		, Rep1Id, Rep1Pct, Rep1CommRate, Rep2Id, Rep2Pct, Rep2CommRate, UnitCommBasis, UnitCommBasisFgn
		, UnitPriceSellBasis, UnitPriceSellBasisFgn, TaskId, ZeroPrint
		, TotQtyOrdSell, TotQtyShipSell, LineSeq, ConversionFactor, CF, ActShipDate, ActivityType) 
	SELECT @PostRun, d.TransID, d.EntryNum, a.LocId, a.ResourceId, 1, p.ProjectName, t.PhaseId, d.Descr, 0, 0, 0, 
		d.AddnlDesc, CASE WHEN ISNULL(d.CatId, '') = '' THEN NULL ELSE d.CatId END, d.ActivityId, d.TaxClass, 
		a.DistCode, CASE a.[Type] WHEN 6 THEN a.GLAcctFixedFeeBilling ELSE a.GLAcctIncome END GLAcctSales, 
		CASE a.[Type] WHEN 6 THEN a.GLAcctFixedFeeBilling ELSE a.GLAcctCost END GLAcctCOGS, 
		CASE a.[Type] WHEN 6 THEN a.GLAcctFixedFeeBilling  WHEN 0 THEN a.GLAcctPayrollClearing ELSE a.GLAcct END GLAcctInv, 
		d.Qty, a.Uom, ISNULL(i.UomBase,a.Uom), d.Qty * ISNULL(u.ConvFactor,1) , d.Qty, 0, NULL, 
		CASE WHEN d.Qty = 0 THEN d.ExtPrice ELSE ROUND(d.ExtPrice / d.Qty, @PrecUnitPrice) END,
		CASE WHEN d.Qty = 0 THEN d.ExtCost ELSE ROUND(d.ExtCost / d.Qty, @PrecUnitCost) END, 
		CASE WHEN d.Qty = 0 THEN d.ExtPrice ELSE ROUND(d.ExtPriceFgn / d.Qty, @PrecUnitPrice) END, 
		CASE WHEN d.Qty = 0 THEN d.ExtCostFgn ELSE ROUND(d.ExtCostFgn / d.Qty, @PrecUnitCost) END, 
		d.ExtPrice, d.ExtPriceFgn, 0, o.[Description], s.[Description], k.[Description], d.ExtPrice,
		d.ExtPriceFgn, d.ExtCost, d.ExtCostFgn, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Id ELSE d.Rep1Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1Pct ELSE d.Rep1Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep1Id IS NULL THEN h.Rep1CommRate ELSE d.Rep1CommRate END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Id ELSE d.Rep2Id END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2Pct ELSE d.Rep2Pct END, 
		CASE WHEN @CommByLineItemYn = 0 OR d.Rep2Id IS NULL THEN h.Rep2CommRate ELSE d.Rep2CommRate END, 
		ISNULL(d.UnitCommBasis, CASE WHEN d.Qty = 0 THEN d.ExtCost ELSE ROUND(d.ExtCost / d.Qty, @PrecUnitCost) END), 
		ISNULL(d.UnitCommBasisFgn, CASE WHEN d.Qty = 0 THEN d.ExtCostFgn ELSE ROUND(d.ExtCostFgn / d.Qty, @PrecUnitCost) END), 
		CASE WHEN d.Qty = 0 THEN d.ExtPrice ELSE ROUND(d.ExtPrice / d.Qty, @PrecUnitPrice) END, 
		CASE WHEN d.Qty = 0 THEN d.ExtPrice ELSE ROUND(d.ExtPriceFgn / d.Qty, @PrecUnitPrice) END, 
		t.TaskId, d.ZeroPrint, d.Qty, d.Qty, d.LineSeq, ISNULL(u.ConvFactor, 1), d.CF, a.ActivityDate, a.[Type]
	FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId
		INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransID 
		INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id 
		INNER JOIN dbo.tblPcProjectDetail t ON a.ProjectDetailId = t.Id
		INNER JOIN dbo.tblPcProject p ON t.ProjectId = p.Id 
		LEFT JOIN dbo.tblInItem i ON a.[Type] = 1 AND a.ResourceId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON a.[Type] = 1 AND a.ResourceId = u.ItemId AND a.Uom = u.Uom
		LEFT JOIN dbo.trav_PcProject_view o ON t.ProjectId = o.Id
		LEFT JOIN dbo.tblPcPhase s ON t.PhaseId = s.PhaseId 
		LEFT JOIN dbo.tblPcTask k ON t.TaskId = k.TaskId

	--append tax information
	INSERT INTO dbo.tblArHistTax (PostRun, TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, CF) 
	SELECT @PostRun, h.TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn
		, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct, t.CF 
	FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId
	INNER JOIN dbo.tblPcInvoiceTax t ON h.TransId = t.TransId 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_History_proc';

