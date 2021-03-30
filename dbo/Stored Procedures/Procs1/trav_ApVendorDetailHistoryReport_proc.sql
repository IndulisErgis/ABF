
CREATE PROCEDURE [dbo].[trav_ApVendorDetailHistoryReport_proc]
	@FiscalPeriodFrom smallint = 1,
	@FiscalPeriodThru smallint = 12,
	@FiscalYearFrom smallint = 1900,
	@FiscalYearThru smallint = 2010,
	@PrintAllInBase bit = 1,
	@ReportCurrency pCurrency = 'USD'    
AS
BEGIN TRY

	CREATE TABLE #tmpDtl 
	   ( 
			PostRun pPostRun NOT NULL, 
			TransId pTransID NOT NULL, 
			InvoiceNum pInvoiceNum, 
			EntryNum int, 
			WhseId pLocID NULL, 
			PartId pItemID NULL, 
			[Desc] pDescription, 
			PhaseId nvarchar(255), 
			CostType nvarchar(255), 
			AddnlDesc nvarchar(max),
			Qty pDecimal default 0, 
			QtyBase pDecimal default 0, 
			Units pUom NULL, 
			UnitsBase pUom NULL, 
			UnitCost pDecimal default 0, 
			UnitCostFgn pDecimal default 0,
			ExtCost pDecimal default 0,
			ExtCostFgn pDecimal default 0,
			GlAcct pGlAcct,
			PrintLineType bit,
			LottedYN bit, 
			PartType tinyint 
		)   
	   
    INSERT INTO #tmpDtl ( PostRun, TransId, InvoiceNum, EntryNum, WhseId, PartId, [Desc], PhaseId, 
		CostType, AddnlDesc, Qty, QtyBase, Units, UnitsBase, UnitCost, UnitCostFgn, ExtCost, 
		ExtCostFgn,	GlAcct,	PrintLineType,	LottedYN, PartType )   
			SELECT d.PostRun, d.TransId, d.InvoiceNum -- get initial detail line item (omit extcost and acctid if allocated)
				, d.EntryNum, d.WhseId, d.PartId, d.[Desc], d.PhaseId, d.CostType, d.AddnlDesc
				, d.Qty, d.QtyBase, d.Units, d.UnitsBase, d.UnitCost, d.UnitCostFgn
				, CASE WHEN a.EntryNum IS NULL THEN d.ExtCost ELSE 0 END AS ExtCost
				, CASE WHEN a.EntryNum IS NULL THEN d.ExtCostFgn ELSE 0 END AS ExtCostFgn
				, CASE WHEN a.EntryNum IS NULL THEN d.GlAcct ELSE NULL END AS GlAcct
				, CASE WHEN a.EntryNum IS NULL THEN 0 ELSE 1 END AS PrintLineType
				, d.LottedYN, d.PartType 
			FROM dbo.tblApHistHeader h 
				INNER JOIN dbo.tblApHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum 
				INNER JOIN #tmpVendorList tmp ON  tmp.VendorId = h.VendorId			
					AND tmp.PostRun = h.PostRun AND tmp.TransID = h.TransId AND tmp.InvoiceNum = h.InvoiceNum 
					AND tmp.EntryNum = d.EntryNum
				LEFT JOIN ( SELECT PostRun, TransId, InvoiceNum, EntryNum 
						    FROM dbo.tblApHistAlloc GROUP BY PostRun, TransId, InvoiceNum, EntryNum 
						  ) AS a ON d.PostRun = a.PostRun AND d.TransId = a.TransId 
								AND d.InvoiceNum = a.InvoiceNum AND d.EntryNum = a.EntryNum
			WHERE tmp.LineType = 0

			UNION ALL -- add allocation detail records

			SELECT d.PostRun, d.TransId, d.InvoiceNum, d.EntryNum, d.WhseId, d.PartId, d.[Desc], d.PhaseId, d.CostType, d.AddnlDesc
				, 0.0 Qty, 0.0 QtyBase, NULL, NULL, 0.0, 0.0, a.Amount AS ExtCost
				, a.AmountFgn AS ExtCostFgn, a.AcctId AS GlAcct, 2 PrintLineType, d.LottedYN, d.PartType 
			FROM dbo.tblApHistHeader h 
				INNER JOIN dbo.tblApHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum 
				INNER JOIN dbo.tblApHistAlloc a ON d.PostRun = a.PostRun AND d.TransId = a.TransId AND d.InvoiceNum = a.InvoiceNum 
					AND d.EntryNum = a.EntryNum  
				INNER JOIN #tmpVendorList tmp ON  tmp.VendorId = h.VendorId			
					AND tmp.PostRun = h.PostRun AND tmp.TransID = h.TransId AND tmp.InvoiceNum = h.InvoiceNum 
					AND tmp.EntryNum = d.EntryNum AND tmp.[Counter] = a.[Counter] 
			WHERE tmp.LineType = 1
			
	SELECT h.PostRun, h.TransId, dtl.EntryNum, h.VendorId, v.[Name], dtl.WhseId, h.InvoiceNum
		, h.InvoiceDate, h.PONum, h.GLPeriod, h.FiscalYear, dtl.PartId, dtl.[Desc] AS Descr, dtl.GlAcct
		, CASE WHEN dtl.Qty IS NULL THEN '' ELSE CAST((dtl.Qty * SIGN(TransType)) AS float) END AS Qty
		, CASE WHEN dtl.QtyBase IS NULL THEN '' ELSE CAST((dtl.QtyBase * SIGN(TransType)) AS float) END AS QtyBase
		, ISNULL(dtl.Units, '') AS Units, ISNULL(dtl.UnitsBase, '') AS UnitsBase, dtl.AddnlDesc
		, CAST(CASE WHEN @PrintAllInBase = 1 THEN (UnitCost * SIGN(TransType)) ELSE (UnitCostFgn * SIGN(TransType)) END AS float) AS UnitCost
		, CAST(CASE WHEN (QtyBase = 0 OR Qty = 0) THEN 0 ELSE (CASE WHEN @PrintAllInBase = 1 THEN (UnitCost * SIGN(TransType) / (QtyBase / Qty)) 
				ELSE ((UnitCostFgn * SIGN(TransType)) / (QtyBase / Qty)) END) END AS float) AS UnitCostBase
		, CAST(CASE WHEN @PrintAllInBase = 1 THEN (ExtCost * SIGN(TransType)) ELSE (ExtCostFgn * SIGN(TransType)) END AS float) AS ExtCost
		, h.CurrencyId, h.FiscalYear * 100 + h.GLPeriod AS FiscalYearPeriod, dtl.PrintLineType, dtl.LottedYN, dtl.PartType 
	FROM dbo.tblApHistHeader AS h 
		INNER JOIN #tmpDtl dtl ON h.PostRun = dtl.PostRun AND h.TransID = dtl.TransID AND h.InvoiceNum = dtl.InvoiceNum 
		LEFT JOIN dbo.tblApVendor v ON h.VendorID = v.VendorID 	
	WHERE h.FiscalYear * 1000 + h.GlPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom 
		AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
		AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)
		AND dtl.EntryNum >= 0
		
	-- Lot
	SELECT PostRun, TransId, InvoiceNum, EntryNum, LotNum, QtyFilled
	, CASE WHEN @PrintAllInBase = 1 THEN CostUnit ELSE CostUnitFgn END AS UnitCost
	, CASE WHEN @PrintAllInBase = 1 THEN CostUnit ELSE CostUnitFgn END * QtyFilled AS ExtCost
	FROM dbo.tblApHistLot 
	--WHERE EntryNum = 1
	ORDER BY LotNum	
	
	-- Serial
	SELECT PostRun, TransId, InvoiceNum, EntryNum
	, CASE WHEN LotNum = '################' THEN NULL ELSE LotNum END AS LotNum, SerNum
	, CASE WHEN @PrintAllInBase = 1 THEN CostUnit ELSE CostUnitFgn END AS UnitCost
	, CASE WHEN @PrintAllInBase = 1 THEN PriceUnit ELSE PriceUnitFgn END AS UnitPrice
	FROM dbo.tblApHistSer
	--WHERE EntryNum = 1

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorDetailHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorDetailHistoryReport_proc';

