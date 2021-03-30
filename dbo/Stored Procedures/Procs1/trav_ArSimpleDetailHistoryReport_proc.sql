
CREATE PROCEDURE dbo.trav_ArSimpleDetailHistoryReport_proc
@PrintForUnit tinyint = 0, -- 0 = Base, 1 = Selling
@PrintType tinyint = 3, -- 0 = Invoice Detail, 1 = Payments, 2 = Finance Charges, 3 = All
@PrintSalesTax bit = 1, 
@PrintFreightCharges bit = 1, 
@PrintMiscCharges bit = 1, 
@SortBy tinyint = 0, -- 0 = Customer, 1 = Rep 1, 2 = Part Id, 3 = Sales Category
@ReportCurrency pCurrency = 'USD', -- base currency when @PrintAllInBase = 1
@PrintAllInBase bit = 1, 
@IncludeVoids tinyint = 2 -- 0 = Transactions, 1 = Voids, 2 = Both

AS
SET NOCOUNT ON
BEGIN TRY

/*
 RecType
  1 - Invoice Detail
  2 - Payments
  4 - Finance Charges
  8 - Sales Tax Charges
  16 - Freight Charges
  32 - Misc Charges
  64 - Gains / Losses
*/

	INSERT INTO #tmpDetailHist (RecType, PostRun, TransId, CustId, CustName, Rep1Id, Rep2Id, Rep1Name
		, VoidYn, InvcNum, InvcDate, PartId, Descr, PartDescr, CatId, CatDescr, AddnlDescr
		, Unit, Quantity, CostDiscount, SalesAmount, PmtAmount, Profit)
	SELECT CASE d.EntryNum 
			WHEN -1 THEN 8 
			WHEN -2 THEN 16 
			WHEN -3 THEN 32 
			WHEN -4 THEN 64 
			ELSE 1 END AS RecType
		, h.PostRun, h.TransId, h.CustId, c.CustName, d.Rep1Id, d.Rep2Id, r.Name AS Rep1Name
		, h.VoidYn, CASE WHEN h.TransType = 1 THEN h.InvcNum ELSE ISNULL(h.CredMemNum, h.InvcNum) END AS InvcNum, h.InvcDate
		, d.PartId, COALESCE(d.PartId, d.[Desc]) AS Descr, d.[Desc] AS PartDescr, d.CatId, s.Descr AS CatDescr
		, d.AddnlDesc AS AddnlDescr
		, CASE WHEN d.EntryNum < 0 THEN NULL 
			ELSE CASE WHEN @PrintForUnit = 0 THEN d.UnitsBase ELSE d.UnitsSell END END AS Unit
		, ISNULL(CASE WHEN d.EntryNum < 0 THEN 0 
			ELSE CASE WHEN @PrintForUnit = 0 -- use order qty for credits / ship qty for invoices
				THEN CASE WHEN TransType < 0 
					THEN -(d.QtyOrdSell * d.ConversionFactor) 
					ELSE d.QtyShipBase 
					END
				ELSE CASE WHEN TransType < 0 
					THEN -d.QtyOrdSell 
					ELSE d.QtyShipSell 
					END	
				END
			END, 0) AS Quantity
		, ISNULL(SIGN(h.TransType) * 
			CASE d.EntryNum 
				WHEN -1 THEN (CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END) 
				WHEN -2 THEN 0 
				WHEN -3 THEN 0 
				WHEN -4 THEN 0 
				ELSE (CASE WHEN @PrintAllInBase = 1 THEN d.CostExt ELSE d.CostExtFgn END) END, 0) AS CostDiscount
		, ISNULL(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END, 0) AS SalesAmount
		, 0 AS PmtAmount
		, (ISNULL(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END, 0)) 
			- (ISNULL(SIGN(h.TransType) * 
				CASE d.EntryNum 
					WHEN -1 THEN (CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END) 
					WHEN -2 THEN 0 
					WHEN -3 THEN 0 
					WHEN -4 THEN 0 
					ELSE (CASE WHEN @PrintAllInBase = 1 THEN d.CostExt ELSE d.CostExtFgn END) END, 0)) AS Profit 
	FROM dbo.tblArHistHeader h 
		LEFT JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransId 
		LEFT JOIN dbo.tblArSalesRep r ON d.Rep1Id = r.SalesRepID 
		LEFT JOIN dbo.tblInSalesCat s ON d.CatId = s.SalesCat 
		LEFT JOIN dbo.tblArCust c ON h.CustId = c.CustId
	WHERE 
		(
			(((@PrintType = 0 OR @PrintType = 3)) AND (d.EntryNum >= 0 OR d.EntryNum = -4)) 
				OR (@PrintSalesTax = 1 AND d.EntryNum = -1) 
				OR (@PrintFreightCharges = 1 AND d.EntryNum = -2) 
				OR (@PrintMiscCharges = 1 AND d.EntryNum = -3) 
		) -- including invoice detail 
		AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND h.CurrencyID = @ReportCurrency))
		AND ((h.VoidYn = 0 AND @IncludeVoids = 0) OR (h.VoidYn = 1 AND @IncludeVoids = 1) OR (@IncludeVoids = 2)) -- conditionally process voids
		AND d.Status = 0 -- open line items
		AND d.GrpId IS NULL -- exclude kit components

	IF (@PrintType = 1 OR @PrintType = 3) -- Payments
	BEGIN
		INSERT INTO #tmpDetailHist (RecType, PostRun, TransId, CustId, CustName, Rep1Id, Rep2Id, Rep1Name
			, VoidYn, InvcNum, InvcDate, PartId, Descr, PartDescr, CatId, CatDescr, AddnlDescr
			, Unit, Quantity, CostDiscount, SalesAmount, PmtAmount, Profit)
		SELECT 2 AS RecType
			, p.PostRun, p.TransId, p.CustId, c.CustName, p.Rep1Id, p.Rep2Id, r.Name AS Rep1Name
			, ISNULL(p.VoidYn, 0) VoidYn, p.CheckNum AS InvcNum, p.PmtDate AS InvcDate
			, NULL AS PartId, NULL AS Descr, NULL AS PartDescr, NULL CatId, NULL AS CatDescr
			, NULL AS AddnlDescr, NULL AS Unit, 0 AS Quantity
			, CASE WHEN @PrintAllInBase = 1 THEN -DiffDisc ELSE -DiffDiscFgn END AS CostDiscount
			, 0 AS SalesAmount
			, CASE WHEN @PrintAllInBase = 1 THEN -(p.PmtAmt - p.CalcGainLoss) ELSE -p.PmtAmtFgn END AS PmtAmount
			, 0 AS Profit 
		FROM dbo.tblArHistPmt p 
			LEFT JOIN dbo.tblArHistHeader h ON p.PostRun = h.PostRun AND p.TransId = h.TransId 
			LEFT JOIN dbo.tblArSalesRep r ON p.Rep1Id = r.SalesRepID 
			LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
		WHERE (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND p.CurrencyId = @ReportCurrency)) 
			AND ((p.VoidYn = 0 AND @IncludeVoids = 0) OR (p.VoidYn = 1 AND @IncludeVoids = 1) OR (@IncludeVoids = 2)) -- conditionally process voids
	END


	IF (@PrintType = 2 OR @PrintType = 3) -- Finance Charges
	BEGIN
		INSERT INTO #tmpDetailHist (RecType, PostRun, TransId, CustId, CustName, Rep1Id, Rep2Id, Rep1Name
			, VoidYn, InvcNum, InvcDate, PartId, Descr, PartDescr, CatId, CatDescr, AddnlDescr
			, Unit, Quantity, CostDiscount, SalesAmount, PmtAmount, Profit)
		SELECT 4 AS RecType
			, h.PostRun, NULL AS TransId, h.CustId, c.CustName, NULL AS Rep1Id, NULL AS Rep2Id, NULL AS Rep1Name
			, 0 AS VoidYn, NULL AS InvcNum, h.FinchDate AS InvcDate
			, NULL AS PartId, NULL AS Descr, NULL AS PartDescr, NULL CatId, NULL AS CatDescr
			, NULL AS AddnlDescr, NULL AS Unit, 0 AS Quantity
			, 0 AS CostDiscount
			, h.FinchAmt AS SalesAmount
			, 0 AS PmtAmount
			, h.FinchAmt AS Profit 
		FROM dbo.tblArHistFinch h 
			LEFT JOIN dbo.tblArCust c ON h.CustId = c.CustId 
		WHERE @PrintAllInBase = 1 -- only valid when printing in base
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSimpleDetailHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSimpleDetailHistoryReport_proc';

