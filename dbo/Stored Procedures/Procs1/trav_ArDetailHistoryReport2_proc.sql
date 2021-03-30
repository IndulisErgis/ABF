﻿
CREATE PROCEDURE dbo.trav_ArDetailHistoryReport2_proc
@FiscalPeriodFrom smallint, 
@FiscalPeriodThru smallint, 
@FiscalYearFrom smallint, 
@FiscalYearThru smallint, 
@TransactionDateFrom datetime, 
@TransactionDateThru datetime, 
@IncludeHistoryWithoutCustomer bit, 
@ViewDetailType tinyint, -- 0 = Invoice Line Items, 1 = Payments, 2 = Finance Charges, 3 = All
@SortBy tinyint, -- 0 = Customer ID, 1 = Sales Rep ID, 2 = Item ID, 3 = Sales Category
@IncludeTransactionType tinyint, -- 0 = Transactions, 1 = Voids, 2 = Both
@ReportUnit tinyint, -- 0 = Base, 1 = Selling
@PrintAllInBase bit, 
@ReportCurrency pCurrency --base currency WHEN @PrintAllInBase = 1

AS
BEGIN TRY
	SET NOCOUNT ON

	-- process expects the list of customer to process to be provided via the following temporary table
	-- Create Table #tmpCustomerList (CustId pCustId, CustName nvarchar(30))

	--CREATE TABLE #tmpCustomerList( CustId pCustId NOT NULL, CustName nvarchar(255) NULL, AcctType tinyint NULL PRIMARY KEY CLUSTERED ([CustId]))
	--INSERT INTO #tmpCustomerList (CustId,CustName,AcctType) SELECT CustId,CustName,AcctType FROM dbo.tblArCust

	-- build a temporary table of report detail values to process
	CREATE TABLE #ReportDetail 
	(
		GrpId1 nvarchar(255), 
		GrpId1Desc nvarchar(255), 
		RecType tinyint, 
		PostRun pPostRun, 
		TransId pTransID, 
		EntryNum int, 
		CustId pCustID NULL, 
		InvcNum pInvoiceNum NULL, 
		CredMemNum pInvoiceNum NULL, 
		InvcDate datetime, 
		TaxGrpId pTaxLoc NULL, 
		Rep1Id pSalesRep NULL, 
		Rep2Id pSalesRep NULL, 
		PartId pItemID NULL, 
		PartDescr nvarchar(510), 
		CatId nvarchar(255), 
		Units pUom NULL, 
		Qty pDecimal, 
		Cost pDecimal, 
		Sales pDecimal, 
		SalesTax pDecimal, 
		Freight pDecimal, 
		Misc pDecimal, 
		Disc pDecimal, 
		PmtAmt pDecimal, 
		VoidYn bit
	)

	-- build a temporary table for identifying finance charges
	CREATE TABLE #FinchInfo 
	(
		CustId pCustID, 
		FinchDate datetime, 
		FinchAmt pDecimal, 
		GLPeriod smallint
	)

	CREATE TABLE #FinchCount 
	(
		CustId pCustId, 
		FinchCount int
	)

	DECLARE @FiscalFrom int, @FiscalThru int
	SELECT @FiscalFrom = (ISNULL(@FiscalYearFrom, 0) * 1000) + ISNULL(@FiscalPeriodFrom, 0)
			, @FiscalThru = (ISNULL(@FiscalYearThru, 0) * 1000) + ISNULL(@FiscalPeriodThru, 0)

	-- capture hist detail entries (line items, tax, freight, misc)
	INSERT INTO #ReportDetail(GrpId1, GrpId1Desc, RecType, PostRun, TransId, EntryNum
		, CustId, InvcDate, InvcNum, CredMemNum, TaxGrpId, Rep1Id, Rep2Id
		, PartId, PartDescr, CatId, Cost, Sales, SalesTax, Freight, Misc, Disc, PmtAmt, Units, Qty, VoidYn) 
	SELECT CASE @SortBy 
			WHEN 0 THEN h.CustId 
			WHEN 1 THEN d.Rep1Id 
			WHEN 2 THEN d.PartId 
			WHEN 3 THEN d.CatId 
			END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN l.CustName 
			WHEN 1 THEN r.[Name] 
			WHEN 2 THEN d.[Desc] 
			WHEN 3 THEN s.Descr 
			END AS GrpId1Desc
		, 1 AS RecType, h.PostRun, h.TransId, d.EntryNum, h.CustId, h.InvcDate, h.InvcNum, h.CredMemNum, h.TaxGrpId
		, d.Rep1Id, d.Rep2Id, d.PartId, d.[Desc] AS PartDescr, d.CatId
		, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum < 0 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN d.CostExt ELSE d.CostExtFgn END END, 0) AS Cost -- line item
		, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum < 0 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END END, 0) AS Sales -- line item
		, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -1 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS SalesTax -- sales tax
		, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -2 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS Freight -- freight
		, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -3 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS Misc -- misc
		, 0 AS Disc, 0 AS PmtAmt
		, CASE WHEN d.EntryNum < 0 THEN NULL ELSE CASE WHEN @ReportUnit = 0 THEN d.UnitsBase ELSE d.UnitsSell END END AS Units -- line item
		, ISNULL(CASE WHEN d.EntryNum < 0 THEN 0 
			ELSE CASE WHEN @ReportUnit = 0 -- use order qty for credits / ship qty for invoices
				THEN CASE WHEN [TransType] < 0 
					THEN -(d.QtyOrdSell * d.ConversionFactor) 
					ELSE d.QtyShipBase 
					END 
				ELSE CASE WHEN [TransType] < 0 
					THEN -d.QtyOrdSell 
					ELSE d.QtyShipSell 
					END	
				END 
			END, 0) AS Qty
		, h.VoidYn 
	FROM #tmpCustomerList l 
		INNER JOIN dbo.tblArHistHeader h ON l.CustId = h.CustId 
		LEFT JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransID 
		LEFT JOIN dbo.tblArSalesRep r ON d.Rep1Id = r.SalesRepID 
		LEFT JOIN dbo.tblInSalesCat s ON d.CatId = s.SalesCat 
	WHERE (@ViewDetailType = 0 OR @ViewDetailType = 3) -- including invoice detail
		AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND h.CurrencyID = @ReportCurrency)) 
		AND ((h.VoidYn = 0 AND @IncludeTransactionType = 0) OR (h.VoidYn = 1 AND @IncludeTransactionType = 1) 
			OR (@IncludeTransactionType = 2)) -- conditionally process voids
		AND d.[Status] = 0 -- open line items
		AND d.[GrpId] IS NULL -- exclude kit components
		AND (h.FiscalYear * 1000) + h.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru 
		AND h.InvcDate BETWEEN @TransactionDateFrom AND @TransactionDateThru

	IF @IncludeHistoryWithoutCustomer = 1
	BEGIN
		INSERT INTO #ReportDetail(GrpId1, GrpId1Desc, RecType, PostRun, TransId, EntryNum
			, CustId, InvcDate, InvcNum, CredMemNum, TaxGrpId, Rep1Id, Rep2Id
			, PartId, PartDescr, CatId, Cost, Sales, SalesTax, Freight, Misc, Disc, PmtAmt, Units, Qty, VoidYn) 
		SELECT CASE @SortBy 
				WHEN 0 THEN NULL 
				WHEN 1 THEN d.Rep1Id 
				WHEN 2 THEN d.PartId 
				WHEN 3 THEN d.CatId 
				END AS GrpId1
			, CASE @SortBy 
				WHEN 0 THEN NULL 
				WHEN 1 THEN r.[Name] 
				WHEN 2 THEN d.[Desc] 
				WHEN 3 THEN s.Descr 
				END AS GrpId1Desc
			, 1 AS RecType, h.PostRun, h.TransId, d.EntryNum, h.CustId, h.InvcDate, h.InvcNum, h.CredMemNum, h.TaxGrpId
			, d.Rep1Id, d.Rep2Id, d.PartId, d.[Desc] AS PartDescr, d.CatId
			, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum < 0 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN d.CostExt ELSE d.CostExtFgn END END, 0) AS Cost -- line item 
			, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum < 0 THEN 0 ELSE CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END END, 0) AS Sales -- line item
			, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -1 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS SalesTax -- sales tax
			, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -2 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS Freight -- freight
			, ISNULL(SIGN(h.TransType) * CASE WHEN d.EntryNum = -3 THEN CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END ELSE 0 END, 0) AS Misc -- misc
			, 0 AS Disc, 0 AS PmtAmt
			, CASE WHEN d.EntryNum < 0 THEN NULL ELSE CASE WHEN @ReportUnit = 0 THEN d.UnitsBase ELSE d.UnitsSell END END AS Units -- line item
			, ISNULL(CASE WHEN d.EntryNum < 0 THEN 0 
				ELSE CASE WHEN @ReportUnit = 0 -- use order qty for credits / ship qty for invoices
					THEN CASE WHEN [TransType] < 0 
						THEN -(d.QtyOrdSell * d.ConversionFactor) 
						ELSE d.QtyShipBase 
						END
					ELSE CASE WHEN [TransType] < 0 
						THEN -d.QtyOrdSell 
						ELSE d.QtyShipSell 
						END	
					END
				END, 0) AS Qty
			, h.VoidYn
		FROM dbo.tblArHistHeader h 
			LEFT JOIN dbo.tblArHistDetail d on h.PostRun = d.PostRun AND h.TransId = d.TransID 
			LEFT JOIN dbo.tblArSalesRep r on d.Rep1Id = r.SalesRepID 
			LEFT JOIN dbo.tblInSalesCat s ON d.CatId = s.SalesCat 
		WHERE (@ViewDetailType = 0 OR @ViewDetailType = 3) -- including invoice detail
			AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND h.CurrencyID = @ReportCurrency)) 
			AND ((h.VoidYn = 0 AND @IncludeTransactionType = 0) OR (h.VoidYn = 1 AND @IncludeTransactionType = 1) 
				OR (@IncludeTransactionType = 2)) -- conditionally process voids
			AND d.[Status] = 0 -- open line items
			AND d.[GrpId] IS NULL -- exclude kit components
			AND (h.FiscalYear * 1000) + h.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru 
			AND h.InvcDate BETWEEN @TransactionDateFrom AND @TransactionDateThru 
			AND h.CustId IS NULL
	END

	-- capture payment detail
	INSERT INTO #ReportDetail(GrpId1, GrpId1Desc, RecType, PostRun, TransId, EntryNum
		, CustId, InvcDate, InvcNum, CredMemNum, TaxGrpId, Rep1Id, Rep2Id
		, PartId, PartDescr, CatId, Cost, Sales, SalesTax, Freight, Misc, Units, Qty, Disc, PmtAmt, VoidYn) 
	SELECT CASE @SortBy 
			WHEN 0 THEN p.CustId 
			WHEN 1 THEN p.Rep1Id 
			WHEN 2 THEN NULL 
			WHEN 3 THEN NULL 
			END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN l.CustName 
			WHEN 1 THEN r.[Name] 
			WHEN 2 THEN NULL 
			WHEN 3 THEN NULL 
			END AS GrpId1Desc
		, 2 AS RecType, p.PostRun, p.TransId, p.[Counter] AS EntryNum, p.CustId, p.PmtDate AS InvcDate, p.InvcNum, NULL AS CredMemNum
		, NULL AS TaxGrpId, p.Rep1Id, p.Rep2Id, NULL AS PartId, NULL AS PartDescr, NULL AS CatId
		, 0 AS Cost, 0 AS Sales, 0 AS SalesTax, 0 AS Freight, 0 AS Misc, NULL AS Units, 0 AS Qty
		, CASE WHEN @PrintAllInBase = 1 THEN p.DiffDisc ELSE p.DiffDiscFgn END AS Disc
		, CASE WHEN @PrintAllInBase = 1 THEN p.PmtAmt ELSE p.PmtAmtFgn END AS PmtAmt
		, p.VoidYn 
	FROM #tmpCustomerList l 
		INNER JOIN dbo.tblArHistPmt p on l.CustId = p.CustId 
		LEFT JOIN dbo.tblArSalesRep r on p.Rep1Id = r.SalesRepID 
	WHERE (@ViewDetailType = 1 OR @ViewDetailType = 3) -- including payments
		AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND p.CurrencyId = @ReportCurrency)) 
		AND ((p.VoidYn = 0 AND @IncludeTransactionType = 0) OR (p.VoidYn = 1 AND @IncludeTransactionType = 1) 
			OR (@IncludeTransactionType = 2)) -- conditionally process voids
		AND (p.FiscalYear * 1000) + p.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru 
		AND p.PmtDate BETWEEN @TransactionDateFrom AND @TransactionDateThru

	IF @IncludeHistoryWithoutCustomer = 1
	BEGIN
		INSERT INTO #ReportDetail(GrpId1, GrpId1Desc, RecType, PostRun, TransId, EntryNum
			, CustId, InvcDate, InvcNum, CredMemNum, TaxGrpId, Rep1Id, Rep2Id
			, PartId, PartDescr, CatId, Cost, Sales, SalesTax, Freight, Misc, Units, Qty, Disc, PmtAmt, VoidYn) 
		SELECT CASE @SortBy 
				WHEN 0 THEN p.CustId 
				WHEN 1 THEN p.Rep1Id 
				WHEN 2 THEN NULL 
				WHEN 3 THEN NULL 
				END AS GrpId1
			, CASE @SortBy 
				WHEN 0 THEN NULL 
				WHEN 1 THEN r.[Name] 
				WHEN 2 THEN NULL 
				WHEN 3 THEN NULL 
				END AS GrpId1Desc
			, 2 AS RecType, p.PostRun, p.TransId, p.[Counter] AS EntryNum, p.CustId, p.PmtDate AS InvcDate, p.InvcNum, NULL AS CredMemNum
			, NULL AS TaxGrpId, p.Rep1Id, p.Rep2Id, NULL AS PartId, NULL AS PartDescr, NULL AS CatId
			, 0 AS Cost, 0 AS Sales, 0 AS SalesTax, 0 AS Freight, 0 AS Misc, NULL AS Units, 0 AS Qty
			, CASE WHEN @PrintAllInBase = 1 THEN p.DiffDisc ELSE p.DiffDiscFgn END AS Disc
			, CASE WHEN @PrintAllInBase = 1 THEN p.PmtAmt ELSE p.PmtAmtFgn END AS PmtAmt
			, p.VoidYn 
		FROM dbo.tblArHistPmt p 
			LEFT JOIN dbo.tblArSalesRep r on p.Rep1Id = r.SalesRepID 
		WHERE (@ViewDetailType = 1 OR @ViewDetailType = 3) -- including payments
			AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND p.CurrencyId = @ReportCurrency)) 
			AND ((p.VoidYn = 0 AND @IncludeTransactionType = 0) OR (p.VoidYn = 1 AND @IncludeTransactionType = 1) 
				OR (@IncludeTransactionType = 2)) -- conditionally process voids
			AND (p.FiscalYear * 1000) + p.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru 
			AND p.PmtDate BETWEEN @TransactionDateFrom AND @TransactionDateThru 
			AND p.CustId IS NULL
	END

	-- capture finance charge info
	INSERT INTO #FinchInfo (CustId, FinchDate, FinchAmt, GLPeriod) 
	SELECT l.CustId, h.FinchDate, h.FinchAmt, h.GLPeriod 
	FROM #tmpCustomerList l 
		INNER JOIN dbo.tblArHistFinch h on l.CustId = h.CustId 
	WHERE @PrintAllInBase = 1 -- only valid when printing in base
		AND (@ViewDetailType = 2 OR @ViewDetailType = 3) -- including finance charges
		AND (h.FiscalYear * 1000) + h.GLPeriod BETWEEN @FiscalFrom AND @FiscalThru 
		AND h.FinchDate BETWEEN @TransactionDateFrom AND @TransactionDateThru

	-- identify the Finance charge counts per customer
	INSERT INTO #FinchCount (CustId, FinchCount) 
	SELECT CustId, COUNT(CustId) FROM #FinchInfo GROUP BY CustId

	-- retrieve the main dataset for the report
	--SELECT PostRun, TransId, GrpId1 FROM(
	SELECT d.GrpId1, d.GrpId1Desc
		, d.RecType, d.PostRun, d.TransId, d.CustId, d.InvcNum
		, d.CredMemNum, d.InvcDate, d.TaxGrpID, c.CustName
		, CASE WHEN @SortBy = 1 THEN d.Rep1Id ELSE NULL END AS Rep1Id
		, CASE WHEN @SortBy = 1 THEN d.Rep2Id ELSE NULL END AS Rep2Id
		, CASE WHEN @SortBy = 2 THEN d.PartId ELSE NULL END AS PartId
		, CASE WHEN @SortBy = 2 THEN d.Units ELSE NULL END AS Units
		, CASE WHEN @SortBy = 3 THEN d.CatId ELSE NULL END AS CatId
		, SUM(ISNULL(SalesTax, 0)) AS SalesTax
		, SUM(ISNULL(Freight, 0)) AS Freight
		, SUM(ISNULL(Misc, 0)) AS Misc
		, SUM(ISNULL(Qty, 0)) AS Qty
		, SUM(ISNULL(Cost, 0)) AS Cost
		, SUM(ISNULL(Sales, 0)) AS Sales
		, SUM(ISNULL(Sales, 0)) - SUM(ISNULL(Cost, 0)) AS Profit
		, SUM(ISNULL(Disc, 0)) AS Disc
		, SUM(ISNULL(PmtAmt, 0)) AS PmtAmt 
		, MAX(ISNULL(f.FinchCount, 0)) AS CustomerFinchCount
		, CAST(1 AS bit) AS HasDetail-- column included for backwards compatibility
		, d.VoidYn 
	FROM #ReportDetail d 
		LEFT JOIN #tmpCustomerList c on d.CustId = c.CustId 
		LEFT JOIN #FinchCount f ON d.CustId = f.CustId 
	GROUP BY d.GrpId1, d.GrpId1Desc
		, d.RecType, d.PostRun, d.TransId, d.CustId, d.InvcNum
		, d.CredMemNum, d.InvcDate, d.TaxGrpID, c.CustName
		, CASE WHEN @SortBy = 1 THEN d.Rep1Id ELSE NULL END
		, CASE WHEN @SortBy = 1 THEN d.Rep2Id ELSE NULL END
		, CASE WHEN @SortBy = 2 THEN d.PartId ELSE NULL END
		, CASE WHEN @SortBy = 2 THEN d.Units ELSE NULL END
		, CASE WHEN @SortBy = 3 THEN d.CatId ELSE NULL END
		, d.VoidYn--) temp ORDER BY PostRun, TransId, GrpId1

	-- retrieve the payment detail dataset (link to parent via GrpId1, PostRun and TransId)
	--SELECT PostRun, TransId, GrpId1 FROM(
	SELECT d.GrpId1, d.GrpId1Desc, d.PostRun, d.TransId, d.EntryNum, d.CustId
		, p.PmtDate, p.Rep1Id, p.Rep2Id, p.CheckNum, p.InvcNum
		, CASE WHEN @PrintAllInBase = 1 THEN p.DiffDisc ELSE p.DiffDiscFgn END AS Disc
		, CASE WHEN @PrintAllInBase = 1 THEN p.PmtAmt ELSE p.PmtAmtFgn END AS PmtAmt
		, d.VoidYn 
	FROM #ReportDetail d 
		INNER JOIN dbo.tblArHistPmt p on d.PostRun = p.PostRun AND d.TransId = p.TransId AND d.EntryNum = p.[Counter] 
	WHERE d.RecType = 2--) temp ORDER BY PostRun, TransId, GrpId1 -- payment details

	-- retrieve the invoice line item detail dataset (link to parent via GrpId1, PostRun and TransId)
	SELECT d.GrpId1, d.GrpId1Desc, d.PostRun, d.TransId, d.EntryNum, d.PartId, LottedYN, PartType
		, e.WhseId, d.PartDescr AS [Desc], e.AddnlDesc, d.CatId
		, d.Units, d.Qty, ISNULL(d.Cost, 0) AS Cost, ISNULL(d.Sales, 0) AS Sales, e.LineSeq
		, ISNULL(d.Sales, 0) - ISNULL(d.Cost, 0) AS Profit 
	FROM #ReportDetail d 
		INNER JOIN dbo.tblArHistDetail e on d.PostRun = e.PostRun and d.TransId = e.TransID and d.EntryNum = e.EntryNum 
	WHERE d.RecType = 1 AND ISNULL(d.EntryNum, -1) >= 0 -- invoice detail / line item values

	-- retrieve Lot number details (link to invoice line detail via PostRun, TransId and EntryNum)
	SELECT d.PostRun, d.TransId, d.EntryNum, e.SeqNum
		, e.ItemId, e.LocId, e.LotNum, e.QtyFilled
		, CASE WHEN @PrintAllInBase = 1 THEN e.CostUnit ELSE e.CostUnitFgn END CostUnit
		, e.QtyFilled * CASE WHEN @PrintAllInBase = 1 THEN e.CostUnit ELSE e.CostUnitFgn END AS ExtCost 
	FROM #ReportDetail d 
		INNER JOIN dbo.tblArHistLot e on d.PostRun = e.PostRun and d.TransId = e.TransID and d.EntryNum = e.EntryNum 
	WHERE d.RecType = 1 AND ISNULL(d.EntryNum, -1) >= 0 -- invoice detail / line item values

	-- retrieve Serial number details (link to invoice line detail via PostRun, TransId and EntryNum)
	SELECT d.PostRun, d.TransId, d.EntryNum, e.SeqNum
		, e.ItemId, e.LocId, e.LotNum, e.SerNum
		, CASE WHEN @PrintAllInBase = 1 THEN e.CostUnit ELSE e.CostUnitFgn END CostUnit
		, CASE WHEN @PrintAllInBase = 1 THEN e.PriceUnit ELSE e.PriceUnitFgn END PriceUnit 
	FROM #ReportDetail d 
		INNER JOIN dbo.tblArHistSer e on d.PostRun = e.PostRun and d.TransId = e.TransID and d.EntryNum = e.EntryNum 
	WHERE d.RecType = 1 AND ISNULL(d.EntryNum, -1) >= 0 -- invoice detail / line item values

	-- retrieve any finance charges for the selected range (link to parent via CustId)
	SELECT f.CustId, f.FinchDate, f.FinchAmt, f.GLPeriod 
	FROM #FinchInfo f

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDetailHistoryReport2_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDetailHistoryReport2_proc';

