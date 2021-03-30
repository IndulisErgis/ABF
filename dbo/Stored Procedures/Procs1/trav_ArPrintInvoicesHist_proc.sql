
Create PROCEDURE dbo.trav_ArPrintInvoicesHist_proc
--Add condition WHERE (@KitYN = 1 OR d.GrpId IS NULL)  --exclude kit components when not selected for printing for serial info
@ProjectInvoices bit = 0,  --set when printing project costing invoices (batch mode)
@PostRun pPostRun = null,
@TransId pTransId = null, --set for printing online or from history
@PrintAdditionalDescription bit = 0, --set for printing additional descriptions
@PrintAllInBase bit = 1,
@BaseCurrencyId pCurrency = null,
@KitYN bit = 0

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #TaxSummary
	(
		TransId pTransId,
        PostRun pPostRun,
		TaxLoc1 pTaxLoc null,
		TaxAmt1 pDecimal, 
		TaxLoc2 pTaxLoc null,
		TaxAmt2 pDecimal, 
		TaxLoc3 pTaxLoc null,
		TaxAmt3 pDecimal, 
		TaxLoc4 pTaxLoc null,
		TaxAmt4 pDecimal, 
		TaxLoc5 pTaxLoc null,
		TaxAmt5 pDecimal, 
		PRIMARY KEY CLUSTERED ([TransId], PostRun)
	)

	CREATE TABLE #Temp
	( 
		TransId pTransId NOT NULL,
        PostRun pPostRun NOT NULL
		PRIMARY KEY CLUSTERED ([TransId], PostRun)
	)	
	
		INSERT INTO #Temp (TransId, PostRun) 
		SELECT h.TransId, h.PostRun
		FROM dbo.tblArHistHeader h 
		WHERE h.TransId = @TransId and h.PostRun = @PostRun
			AND h.VoidYn = 0 --exclude voids
			AND ((@ProjectInvoices = 0 AND (h.ProjItem <> 'PR' Or h.ProjItem Is Null)) OR (@ProjectInvoices = 1 AND (h.ProjItem = 'PR')))



	--summarize and cross-tab the taxes by level 
	--	note: TaxLocId cannot be duplicated for multiple tax levels
	declare @reportmethod int = 0
	select @reportmethod = ReportMethod from dbo.tblSmTaxGroup where TaxGrpID = (select TaxGrpID from dbo.tblArHistHeader h where h.TransId = @TransId and h.PostRun = @PostRun)
	if @reportmethod<>0
	begin
	INSERT INTO #TaxSummary (TransId, PostRun
		, TaxLoc1, TaxAmt1, TaxLoc2, TaxAmt2, TaxLoc3, TaxAmt3, TaxLoc4, TaxAmt4, TaxLoc5, TaxAmt5)
	SELECT TransId, PostRun, Max(TaxLoc1), Sum(TaxAmt1), Max(TaxLoc2), Sum(TaxAmt2)
		, Max(TaxLoc3), Sum(TaxAmt3), Max(TaxLoc4), Sum(TaxAmt4), Max(TaxLoc5), Sum(TaxAmt5)
	FROM (SELECT x.TransId, x.PostRun
			, CASE WHEN x.[Level] = 1 THEN x.TaxLocId ELSE NULL END TaxLoc1
			, CASE WHEN x.[Level] = 1 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt1
			, CASE WHEN x.[Level] = 2 THEN x.TaxLocId ELSE NULL END TaxLoc2
			, CASE WHEN x.[Level] = 2 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt2
			, CASE WHEN x.[Level] = 3 THEN x.TaxLocId ELSE NULL END TaxLoc3
			, CASE WHEN x.[Level] = 3 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt3
			, CASE WHEN x.[Level] = 4 THEN x.TaxLocId ELSE NULL END TaxLoc4
			, CASE WHEN x.[Level] = 4 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt4
			, CASE WHEN x.[Level] = 5 THEN x.TaxLocId ELSE NULL END TaxLoc5
			, CASE WHEN x.[Level] = 5 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt5
		FROM #Temp l
		INNER JOIN dbo.tblArHistTax x ON l.TransId = x.TransId and l.PostRun = x.PostRun where x.TransId = @TransId and x.PostRun = @PostRun) ctab
	GROUP BY TransId, PostRun

	--Add the tax adjustment to the appropriate tax location
	UPDATE #TaxSummary 
		Set TaxAmt1 = TaxAmt1 + CASE WHEN [TaxLoc1] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt2 = TaxAmt2 + CASE WHEN [TaxLoc2] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt3 = TaxAmt3 + CASE WHEN [TaxLoc3] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt4 = TaxAmt4 + CASE WHEN [TaxLoc4] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt5 = TaxAmt5 + CASE WHEN [TaxLoc5] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
	FROM dbo.tblArHistHeader h 
		WHERE h.TaxAmtAdjFgn <> 0 AND h.TransId = @TransId and h.PostRun = @PostRun
	end



	--retrieve the datasets
	-- header info
	SELECT c.CustId, c.Attn, c.Contact, c.CustName, c.Addr1, c.Addr2, c.City, c.Region
		, c.Country, c.PostalCode, b.CustId AS BillCustId, c.Phone, c.Fax, c.Email, c.Internet, b.CustName AS BillCustName
		, b.Addr1 AS BillAddr1, b.Addr2 AS BillAddr2, b.City AS BillCity, b.Region AS BillRegion
		, b.Country AS BillCountry, b.PostalCode AS BillPostalCode, b.IntlPrefix BillIntlPrefix, b.Phone as BillPhone, b.Fax as BillFax
		, b.Attn AS BillAttn, b.Contact AS BillContact, h.ShipToID, h.ShipToName, h.ShipToAddr1, h.ShipToAddr2, h.ShipToCity
		, h.ShipToCountry, h.ShipToRegion, h.ShipToPostalCode, h.ShipVia, h.ShipToAttn
		, t.[Desc] AS TermsDescription, h.TransType, h.OrderDate
		, h.ReqShipDate AS [RequestedShipDate], h.ShipDate, h.ShipNum AS ShipNo, h.InvcDate AS InvoiceDate, h.Rep1Id, h.Rep2Id
		, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS TaxableSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS NontaxableSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN SalesTax ELSE SalesTaxFgn END AS SalesTax
		, CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END AS Freight
		, CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END AS Misc
		, CASE WHEN @PrintAllInBase = 1 Then CASE WHEN h.TotPmtAmtFgn = ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) ELSE ISNULL(h.TotPmtAmt - h.TotPmtGainLoss, 0) END ELSE ISNULL(h.TotPmtAmtFgn, 0) END AS TotalPayment
		, h.CustPONum AS CustomerPoNo, h.CurrencyID AS CurrencyId
		, h.InvcNum AS InvoiceNo, h.CredMemNum AS OriginalInvoiceNo, h.TransId, h.ExchRate
		, Source AS [Source]
		, CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) 
			ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) 
			END AS InvoiceTotal
		, 0 AS PriorInvoiceAmount --placeholder for values returned by SO Invoicing
		, 0 AS PriorPaymentAmount --placeholder for values returned by SO Invoicing
		, CASE WHEN h.TransType < 0 --return 0 for TotalDue on Credit Transactions
			THEN 0
			ELSE
				CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN h.TotPmtAmtFgn = ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) THEN 0 ELSE ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) 
					+ ISNULL(Freight, 0) + ISNULL(Misc, 0) - ISNULL((h.TotPmtAmt - h.TotPmtGainLoss), 0) + ISNULL(CalcGainLoss, 0) END
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) 
					+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) - ISNULL(h.TotPmtAmtFgn, 0)
			END
			END AS TotalDue
		, x.TaxLoc1 AS TaxLocation1, ISNULL(x.TaxAmt1, 0) AS TaxAmount1
		, x.TaxLoc2 AS TaxLocation2, ISNULL(x.TaxAmt2, 0) AS TaxAmount2
		, x.TaxLoc3 AS TaxLocation3, ISNULL(x.TaxAmt3, 0) AS TaxAmount3
		, x.TaxLoc4 AS TaxLocation4, ISNULL(x.TaxAmt4, 0) AS TaxAmount4
		, x.TaxLoc5 AS TaxLocation5, ISNULL(x.TaxAmt5, 0) AS TaxAmount5
		, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, WhseId AS TransLocation, BatchId, c.TaxExemptId, h.Notes
		, h.WhseId AS LocationId
		, h.PickNum AS [PickingSlipNo], h.PackNum AS [PackingSlipNo]
		, CASE WHEN @PrintAllInBase = 1 THEN (c.CreditLimit - c.CurAmtDue) / h.ExchRate ELSE (c.CreditLimit - c.CurAmtDue) END AS RemainingCredit
	FROM dbo.tblArHistHeader h 
	INNER JOIN #Temp l  on h.PostRun = l.PostRun and h.TransId = l.TransId
	LEFT JOIN  dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
	LEFT JOIN  dbo.tblArCust c ON h.SoldToId = c.CustId
    LEFT JOIN dbo.tblArCust b ON h.CustId = b.CustId
	LEFT JOIN dbo.tblArShipTo Ship ON h.CustID = Ship.CustID AND h.ShipToID = Ship.ShipToID 
	LEFT JOIN #TaxSummary x on h.TransId = x.TransId and h.PostRun = x.PostRun
	where h.TransId = @TransId and h.PostRun = @PostRun

	-- detail info
		SELECT d.PartId AS ItemId, d.EntryNum
		, d.WhseId AS LocationId
		, d.[Desc] AS [Description]
		, CASE WHEN @PrintAdditionalDescription = 1 THEN d.AddnlDesc ELSE NULL END AS AddnlDescription
		, d.TaxClass, d.QtyOrdSell AS QtyOrdered, d.UnitsSell AS Units, d.QtyShipSell AS QtyShipped
		, CASE WHEN @PrintAllInBase = 1 THEN  UnitPriceSellBasis ELSE UnitPriceSellBasisFgn END AS UnitPrice
		, CASE WHEN (h.TransType > 0 AND d.QtyShipSell = 0) OR (h.TransType < 0 AND d.QtyOrdSell = 0) THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt + d.PriceAdjAmt ELSE PriceExtFgn + d.PriceAdjAmtFgn END END AS ExtPrice --ignore PriceAdj when no qtys processed for current status
		, d.TransId, d.PartType AS ItemType, d.LottedYn
		, d.PriceAdjType, d.PriceAdjPct
		, CASE WHEN (h.TransType > 0 AND d.QtyShipSell = 0) OR (h.TransType < 0 AND d.QtyOrdSell = 0) THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN -d.PriceAdjAmt ELSE -d.PriceAdjAmtFgn END END AS PriceAdjAmt --ignore PriceAdj when no qtys processed for current status
		, d.Kit AS Kit,  CASE WHEN d.GrpId IS NULL THEN d.LineSeq ELSE k.LineSeq END LineSeq --map back to the parent kit line seq for component sorting
		, d.GrpId AS GrpId, d.BOLNum
		, d.ReqShipDate AS [RequestedShipDate], d.ActShipDate AS [ActualShipDate]
		, d.BinNum AS [BinNo], d.QtyBackordSell AS [QtyBackordered], d.Rep1Id, d.Rep2Id, d.CustomerPartNumber 
	FROM dbo.tblArHistHeader h 
	INNER JOIN #Temp l  on h.PostRun = l.PostRun and h.TransId = l.TransId
	INNER JOIN dbo.tblArHistDetail d ON h.TransId = d.TransID and  h.PostRun = d.PostRun
	LEFT JOIN (SELECT PostRun, TransId, EntryNum, LineSeq 
		FROM dbo.tblArHistDetail
		WHERE PostRun=@PostRun and TransID=@TransId and [Kit] = 1) k 
	ON d.PostRun = k.PostRun And d.TransID = k.TransID and d.GrpId = k.EntryNum --lookup the lineseq of the parent kit for component sorting
	WHERE h.TransId = @TransId and h.PostRun = @PostRun and d.EntryNum > 0 
		AND ((ISNULL(d.GrpId, 0) = 0 and @KitYN = 0)  or @KitYN = 1) 
		AND d.[Status] = 0 --only active line items
	ORDER BY d.TransId,
	-- d.PostRun, d.EntryNum, d.LineSeq 
	    CASE WHEN d.GrpId IS NULL THEN d.LineSeq ELSE k.LineSeq END
		, CASE WHEN d.GrpId IS NULL THEN '' ELSE 'C' END --kit components sort after the parent
		, d.LineSeq, d.EntryNum
		

		-- lot info
	SELECT l.TransId, l.EntryNum, l.LotNum AS LotNo, l.QtyFilled AS Qty 
	FROM #Temp t
	INNER JOIN dbo.tblArHistDetail d ON t.PostRun = d.PostRun AND t.TransId = d.TransID 
	INNER JOIN dbo.tblArHistLot l ON d.PostRun  = l.PostRun AND d.TransId = l.TransId AND d.EntryNum = l.EntryNum 
	WHERE d.PostRun=@PostRun and d.TransID=@TransId and (@KitYN = 1 OR d.GrpId IS NULL)  --exclude kit components when not selected for printing
	And d.[Status] = 0 --only active line items
	ORDER BY LotNum



	-- serial info
	SELECT s.TransId, s.EntryNum, s.SeqNum, s.LotNum AS LotNo, s.SerNum AS SerNo
		, CASE WHEN @PrintAllInBase = 1 THEN s.PriceUnit ELSE s.PriceUnitFgn END AS UnitPrice
		, 1 AS Qty 
	FROM #Temp t
	INNER JOIN dbo.tblArHistDetail d ON t.PostRun = d.PostRun AND t.TransId = d.TransID 
	INNER JOIN dbo.tblArHistSer s ON d.PostRun = s.PostRun AND d.TransId = s.TransId AND d.EntryNum = s.EntryNum 
	WHERE d.PostRun=@PostRun and d.TransID=@TransId and (@KitYN = 1 OR d.GrpId IS NULL)  --exclude kit components when not selected for printing
	and d.[Status] = 0 --only active line items
	ORDER BY LotNum, SerNum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrintInvoicesHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrintInvoicesHist_proc';

