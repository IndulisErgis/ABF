
CREATE PROCEDURE dbo.trav_InValuation_proc
@AsOfDate datetime = '20081231',
@AsOfDateOption tinyint = 0, --As Of Date option (0=BY date/1=BY gl period & fiscal year)
@AsOfGlPeriod smallint = 12,
@AsOfFiscalYear smallint = 2008,
@CurrencyPrecision tinyint = 2,
@QuantityPrecision tinyint = 4,
@CostingMethod tinyint = 0 -- 0, FIFO/LIFO; 1, Average; 2, Standard;
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #InValue
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		Qty pDecimal NOT NULL,
		ExtCost pDecimal NOT NULL
	)
	CREATE INDEX [IX_InValue] ON #InValue(ItemId, LocId)

	CREATE TABLE #InValueTotals
	(	
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyOnHand pDecimal default(0) NOT NULL,
		ExtCost pDecimal default(0) NOT NULL,
		PeriodBegBal pDecimal default(0) NOT NULL,
		YearBegBal pDecimal default(0) NOT NULL,
		HasValue bit default(0) NOT NULL,
		UOM pUom NOT NULL
	)
	CREATE INDEX [IX_InValueTotals] ON #InValueTotals(ItemId, LocId)

	CREATE TABLE #InValueHist 
	(
		ItemId pItemId NOT NULL,
		LocId pItemId NOT NULL,
		SumYear smallint NOT NULL,
		SumPeriod smallint NOT NULL,
		CostSold pDecimal default(0) NOT NULL,
		CostRetSold pDecimal default(0) NOT NULL,
		CostPurch pDecimal default(0) NOT NULL,
		CostRetPurch pDecimal default(0) NOT NULL,
		CostMatReq pDecimal default(0) NOT NULL,
		CostXferIn pDecimal default(0) NOT NULL,
		CostXferOut pDecimal default(0) NOT NULL,
		CostAdj pDecimal default(0) NOT NULL,
		CostBuilt pDecimal default(0) NOT NULL,
		CostConsumed pDecimal default(0) NOT NULL,
		CogsAdj pDecimal default(0) NOT NULL,
		PurchPriceVar pDecimal default(0) NOT NULL
	)
	CREATE INDEX [IX_InValueHist] ON #InValueHist(ItemId, LocId, SumYear, SumPeriod)

	--build a list of item/loc ids to process
	INSERT INTO #InValueTotals (ItemId, LocId, Uom)
	SELECT i.ItemId, l.LocId, i.UomBase
	FROM #tmpItemLocationList m INNER JOIN dbo.tblInItemLoc l ON m.ItemId = l.ItemId AND m.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
	WHERE i.KittedYN = 0 AND i.ItemType IN (1,2)

	--capture current serialized value
	INSERT INTO #InValue(ItemId, LocId, Qty, ExtCost)
	SELECT s.ItemId, s.LocId, SUM(s.QtyOnHand), 
		SUM(ROUND(CASE WHEN @CostingMethod = 1 AND i.CostMethodOverride = 2 THEN s.QtyOnHand * l.CostAvg 
			WHEN @CostingMethod = 2 AND i.CostMethodOverride = 2 THEN s.QtyOnHand * l.CostStd ELSE s.Cost END, @CurrencyPrecision))
	FROM dbo.trav_InItemOnHandSer_view s INNER JOIN #InValueTotals b ON s.ItemId = b.ItemId AND s.LocId = b.LocId 
		INNER JOIN dbo.tblInItemLoc l ON s.ItemId = l.ItemId AND s.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i ON s.ItemId = i.ItemId
	GROUP BY s.ItemId, s.LocId

	--capture current non-serialized value
	INSERT INTO #InValue(ItemId, LocId, Qty, ExtCost)
	SELECT s.ItemId, s.LocId, SUM(s.QtyOnHand), SUM(ROUND(CASE WHEN @CostingMethod = 1 THEN s.QtyOnHand * l.CostAvg 
		WHEN @CostingMethod = 2 THEN s.QtyOnHand * l.CostStd ELSE s.Cost END , @CurrencyPrecision))
	FROM dbo.trav_InItemOnHand_view s INNER JOIN #InValueTotals b ON s.ItemId = b.ItemId AND s.LocId = b.LocId
		INNER JOIN dbo.tblInItemLoc l ON s.ItemId = l.ItemId AND s.LocId = l.LocId 
	GROUP BY s.ItemId, s.LocId

	--back out transactions going INTO Inventory/add in transactions coming out of Inventory
	--	for dates later than the date being processed
	INSERT INTO #InValue(ItemId, LocId, Qty, ExtCost)
	SELECT ItemId, LocId, SUM(Qty), SUM(ExtCost) 
		FROM (
			--include value of all quantities
			SELECT d.ItemId, d.LocId
				, SUM(CASE WHEN Source < 70 THEN -ROUND(Qty * ConvFactor, @QuantityPrecision) ELSE ROUND(Qty * ConvFactor, @QuantityPrecision) End) Qty
				, SUM(CASE WHEN Source < 70 THEN -d.CostExt ELSE d.CostExt End) ExtCost
				FROM dbo.tblInHistDetail d INNER JOIN #InValueTotals b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
				WHERE ((@AsOfDateOption = 0 AND d.TransDate >= DATEADD(DAY, 1, @AsOfDate)) OR
					(@AsOfDateOption = 1 AND ((d.SumYear * 1000)+ d.GLPeriod > (@AsOfFiscalYear * 1000)+ @AsOfGlPeriod))) 
					AND d. Source NOT IN (200,201)
				GROUP BY d.ItemId, d.LocId
			UNION All
			--back out value of received quantities that have been invoiced (invoiced qty @ received cost)
			SELECT d.ItemId, d.LocId
				, SUM(CASE WHEN d.Source < 70 THEN ROUND(d.Qty * d.ConvFactor, @QuantityPrecision) ELSE -ROUND(d.Qty * d.ConvFactor, @QuantityPrecision) End) Qty
				, SUM(CASE WHEN d.Source < 70 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE -ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) End) ExtCost
			FROM dbo.tblInHistDetail d INNER JOIN #InValueTotals b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
				INNER JOIN dbo.tblInHistDetail r ON d.HistSeqNum_Rcpt = r.HistSeqNum
			WHERE (@AsOfDateOption = 0 AND d.TransDate >= DATEADD(DAY, 1, @AsOfDate)) OR
				(@AsOfDateOption = 1 AND ((d.SumYear * 1000)+ d.GLPeriod > (@AsOfFiscalYear * 1000)+ @AsOfGlPeriod))
			GROUP BY d.ItemId, d.LocId
			--include cogsadj and ppv
			UNION ALL
			SELECT d.ItemId, d.LocId
				, 0 Qty
				, SUM(d.CostExt) ExtCost
			FROM dbo.tblInHistDetail d INNER JOIN #InValueTotals b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
			WHERE d.Source IN (200, 201) AND ((@AsOfDateOption = 0 AND d.TransDate >= DATEADD(DAY, 1, @AsOfDate)) OR
				(@AsOfDateOption = 1 AND ((d.SumYear * 1000)+ d.GLPeriod > (@AsOfFiscalYear * 1000)+ @AsOfGlPeriod)))
			GROUP BY d.ItemId, d.LocId
		) tmp
		GROUP BY ItemId, LocId

	--capture cost values FROM history as of the given point in time
	INSERT INTO #InValueHist (ItemId, LocId, SumYear, SumPeriod
		, CostSold, CostRetSold, CostPurch, CostRetPurch, CostMatReq
		, CostXferIn, CostXferOut, CostAdj, CostBuilt, CostConsumed)
	SELECT ItemId, LocId, SumYear, SumPeriod
		, SUM(CostSold), SUM(CostRetSold), SUM(CostPurch), SUM(CostRetPurch), SUM(CostMatReq)
		, SUM(CostXferIn), SUM(CostXferOut), SUM(CostAdj), SUM(CostBuilt), SUM(CostConsumed)
	FROM (
		--include value of all quantities
		SELECT d.ItemId, d.LocId, d.SumYear, d.SumPeriod
			, SUM(CASE WHEN d.Source BETWEEN 80 AND 84 THEN d.CostExt ELSE 0 END) CostSold
			, SUM(CASE WHEN d.Source BETWEEN 30 AND 32 THEN d.CostExt ELSE 0 END) CostRetSold
			, SUM(CASE WHEN d.Source BETWEEN 10 AND 14 THEN d.CostExt ELSE 0 END) CostPurch
			, SUM(CASE WHEN d.Source BETWEEN 70 AND 72 THEN d.CostExt ELSE 0 END) CostRetPurch
			, SUM(CASE WHEN d.Source = 75 THEN -d.CostExt WHEN d.Source = 17 THEN d.CostExt ELSE 0 END) CostMatReq
			, SUM(CASE WHEN d.Source = 16 THEN d.CostExt ELSE 0 END) CostXferIn
			, SUM(CASE WHEN d.Source = 74 THEN d.CostExt ELSE 0 END) CostXferOut
			, SUM(CASE WHEN d.Source = 15 THEN d.CostExt WHEN d.Source = 73 THEN -d.CostExt ELSE 0 END) CostAdj
			, SUM(CASE WHEN d.Source IN (18,33,34) THEN d.CostExt ELSE 0 END) CostBuilt
			, SUM(CASE WHEN d.Source IN (76,85,86) THEN d.CostExt ELSE 0 END ) CostConsumed
		FROM dbo.tblInHistDetail d INNER JOIN #InValueTotals b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
		WHERE (@AsOfDateOption = 0 AND d.TransDate < DATEADD(DAY, 1, @AsOfDate)) OR
			(@AsOfDateOption = 1 AND ((d.SumYear * 1000)+ d.GLPeriod <= (@AsOfFiscalYear * 1000)+ @AsOfGlPeriod))		
		GROUP BY d.ItemId, d.LocId, d.SumYear, d.SumPeriod
	UNION All
	--back out value of received quantities that have been invoiced (invoiced qty @ received cost)
	SELECT d.ItemId, d.LocId, d.SumYear, d.SumPeriod
		, -SUM(CASE WHEN d.Source BETWEEN 80 AND 84 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END) CostSold
		, -SUM(CASE WHEN d.Source BETWEEN 30 AND 32 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END) CostRetSold
		, -SUM(CASE WHEN d.Source BETWEEN 10 AND 14 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END) CostPurch
		, -SUM(CASE WHEN d.Source BETWEEN 70 AND 72 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END) CostRetPurch
		, -SUM(CASE WHEN d.Source = 75 THEN -ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) WHEN d.Source = 17 THEN (ROUND(d.Qty * r.CostUnit, @CurrencyPrecision)) ELSE 0 END) CostMatReq
		, -SUM(CASE WHEN d.Source = 16 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END) CostXferIn
		, -SUM(CASE WHEN d.Source = 74 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END) CostXferOut
		, -SUM(CASE WHEN d.Source = 15 THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) WHEN d.Source = 73 THEN -(ROUND(d.Qty * r.CostUnit, @CurrencyPrecision)) ELSE 0 END) CostAdj
		, -SUM(CASE WHEN d.Source IN (18,33,34) THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END) CostBuilt
		, -SUM(CASE WHEN d.Source IN (76,85,86) THEN ROUND(d.Qty * r.CostUnit, @CurrencyPrecision) ELSE 0 END ) CostConsumed
		FROM dbo.tblInHistDetail d INNER JOIN #InValueTotals b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
			INNER JOIN dbo.tblInHistDetail r ON d.HistSeqNum_Rcpt = r.HistSeqNum
		WHERE (@AsOfDateOption = 0 AND d.TransDate < DATEADD(DAY, 1, @AsOfDate)) OR
			(@AsOfDateOption = 1 AND ((d.SumYear * 1000)+ d.GLPeriod <= (@AsOfFiscalYear * 1000)+ @AsOfGlPeriod))
		GROUP BY d.ItemId, d.LocId, d.SumYear, d.SumPeriod
	) tmp
	GROUP BY ItemId, LocId, SumYear, SumPeriod

	--capture COGS/PPV values FROM as of the given point in time
	INSERT INTO #InValueHist (ItemId, LocId, SumYear, SumPeriod, CogsAdj, PurchPriceVar)
	SELECT d.ItemId, d.LocId, d.SumYear, d.SumPeriod, 
		-SUM(CASE WHEN d.Source = 200 THEN d.CostExt ELSE 0 END) CogsAdj,
		-SUM(CASE WHEN d.Source = 201 THEN d.CostExt ELSE 0 END) PurchPriceVar
	FROM dbo.tblInHistDetail d INNER JOIN #InValueTotals b ON d.ItemId = b.ItemId AND d.LocId = b.LocId
	WHERE d.Source IN (200,201) AND ((@AsOfDateOption = 0 AND d.TransDate < DATEADD(DAY, 1, @AsOfDate)) OR
		(@AsOfDateOption = 1 AND ((d.SumYear * 1000)+ d.GLPeriod <= (@AsOfFiscalYear * 1000)+ @AsOfGlPeriod)))
	GROUP BY d.ItemId, d.LocId, d.SumYear, d.SumPeriod

	--calculate the Current Balances for qty AND cost
	Update #InValueTotals Set QtyOnHand = s.Qty, ExtCost = s.ExtCost, HasValue = 1
	FROM (SELECT ItemId, LocId, SUM(Qty) Qty, SUM(ExtCost) ExtCost FROM #InValue GROUP BY ItemId, LocId) s
	WHERE #InValueTotals.ItemId = s.ItemId AND #InValueTotals.LocId = s.LocId

	--calculate the Period AND Year Beginning Balances (take relative hist trans out of the current balance)
	Update #InValueTotals Set PeriodBegBal = ExtCost - ISNULL(s.PdAdj, 0)
		, YearBegBal = ExtCost - ISNULL(s.YearAdj, 0), HasValue = 1
	FROM (SELECT ItemId, LocId
		, SUM(CASE WHEN SumYear = @AsOfFiscalYear AND SumPeriod = @AsOfGlPeriod
			THEN CostPurch - CostRetPurch - CostSold + CostRetSold 
				+ CogsAdj + PurchPriceVar + CostMatReq 
				+ CostXferIn - CostXferOut + CostAdj 
				+ CostBuilt - CostConsumed
			ELSE 0 End) PdAdj
		, SUM(CASE WHEN SumYear = @AsOfFiscalYear
			THEN CostPurch - CostRetPurch - CostSold + CostRetSold 
				+ CogsAdj + PurchPriceVar + CostMatReq 
				+ CostXferIn - CostXferOut + CostAdj 
				+ CostBuilt - CostConsumed
			ELSE 0 End) YearAdj
		FROM #InValueHist GROUP BY ItemId, LocId) s
	WHERE #InValueTotals.ItemId = s.ItemId AND #InValueTotals.LocId = s.LocId

	--populate the return temp TABLE with the min resultset 
	--	needed to retrieve any additional information
	INSERT INTO #InValuationResults (ItemId, LocId
		, QtyOnHand, ExtCost, PeriodBegBal, YearBegBal
		, COGS, CostPurchased, CostMatReq, CostXfer, CostAdj
		, TotCogsAdj, TotPurchPriceVar, UOM)
	SELECT b.ItemId, b.LocId, b.QtyOnHand, b.ExtCost
		, b.PeriodBegBal, b.YearBegBal
		, ISNULL(s.COGS, 0) COGS, ISNULL(s.CostPurchased, 0) CostPurchased
		, ISNULL(s.CostMatReq, 0) CostMatReq, ISNULL(s.CostXfer, 0) CostXfer, ISNULL(s.CostAdj, 0) CostAdj
		, ISNULL(s.TotCogsAdj, 0) TotCogsAdj, ISNULL(s.TotPurchPriceVar, 0) TotPurchPriceVar, b.UOM
	FROM #InValueTotals b LEFT JOIN 
		(SELECT ItemId, LocId, SUM(CostSold - CostRetSold) COGS
			, SUM(CostPurch - CostRetPurch) CostPurchased
			, SUM(CogsAdj) TotCogsAdj
			, SUM(PurchPriceVar) TotPurchPriceVar
			, SUM(CostMatReq) CostMatReq
			, SUM(CostXferIn - CostXferOut) CostXfer
			, SUM(CostAdj) CostAdj
		FROM #InValueHist
		WHERE SumYear = @AsOfFiscalYear 
		GROUP BY ItemId, LocId) s ON b.ItemId = s.ItemId AND b.LocId = s.LocId
	WHERE b.HasValue = 1

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InValuation_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InValuation_proc';

