
--PET:http://webfront:801/view.php?id=240323
--PET:http://webfront:801/view.php?id=255067

CREATE PROCEDURE dbo.trav_DbInSlowFastMovement_proc
@ItemCount int, 
@SlowFast tinyint, -- 0 = Slow, 1 = Fast
@VolumeSalesTurns tinyint, -- 0 = Volume, 1 = Sales, 2 = Turns
@TimeFrame tinyint, -- 0 = PTD, 1 = YTD
@DetailSummary tinyint, -- 0 = Detail, 1 = Summary
@CostingMethod tinyint, -- 0 = FIFO, 1 = LIFO, 2 = Average, 3 = Standard
@WksDate datetime = NULL

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmpInSlowFastPTDNonZeroDtl
	(
		ItemId pItemID, 
		LocId pLocID, 
		PTDQty pDecimal, 
		PTDSales pDecimal, 
		PTDProfit pDecimal
	)

	CREATE TABLE #tmpInSlowFastPTDNonZeroItems
	(
		ItemId pItemID
	)

	CREATE TABLE #tmpInSlowFastYTDNonZeroDtl
	(
		ItemId pItemID, 
		LocId pLocID, 
		Descr nvarchar(35), 
		YTDQty pDecimal, 
		YTDSales pDecimal, 
		YTDProfit pDecimal
	)

	CREATE TABLE #tmpInSlowFastMove
	(
		ItemId pItemID, 
		LocId pLocID, 
		Descr nvarchar(35), 
		PTDVolume pDecimal, 
		PTDSales pDecimal, 
		YTDVolume pDecimal, 
		YTDSales pDecimal
	)

	CREATE TABLE #tmpResults
	(
		ItemLoc nvarchar(35), 
		ItemId pItemID, 
		LocId pLocID NULL, 
		Descr nvarchar(35), 
		PTDVolume pDecimal, 
		PTDSales pDecimal, 
		PTDTurns pDecimal, 
		YTDVolume pDecimal, 
		YTDSales pDecimal, 
		YTDTurns pDecimal, 
		SortBy pDecimal
	)

	DECLARE @FiscalYear smallint, @Period smallint, @DaysInYear int
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	SELECT @DaysInYear = DATEPART(DY, DATEADD(YEAR, DATEDIFF(YEAR, '19000101', @WksDate)+1, '19000101') - 1)

	INSERT INTO #tmpInSlowFastPTDNonZeroDtl(ItemId, LocId, PTDQty, PTDSales, PTDProfit) 
	SELECT s.ItemId, s.LocId, s.QtySold - s.QtyRetSold AS PTDQty, s.TotSold - s.TotRetSold AS PTDSales
		, (s.TotSold - s.TotRetSold) - (s.CostSold - s.CostRetSold) AS PTDProfit 
	FROM trav_InHistoryByYearPeriodItemLocation_view s 
		INNER JOIN dbo.tblInItemLoc l ON l.ItemId = s.ItemId AND l.LocId = s.LocId
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId 
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @Period AND (s.QtySold - s.QtyRetSold <> 0)

	INSERT INTO #tmpInSlowFastPTDNonZeroItems(ItemId) 
	SELECT s.ItemId 
	FROM dbo.trav_InHistoryByYearPeriodItemLocation_view s 
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @Period
	GROUP BY s.ItemId 
	HAVING (SUM(s.QtySold - s.QtyRetSold) <> 0)

	INSERT INTO #tmpInSlowFastYTDNonZeroDtl(ItemId, LocId, Descr, YTDQty, YTDSales, YTDProfit) 
	SELECT s.ItemId, s.LocId, i.Descr, SUM(s.QtySold - s.QtyRetSold) AS YTDQty
		, SUM(s.TotSold - s.TotRetSold) AS YTDSales
		, SUM(s.TotSold - s.TotRetSold) - SUM(s.CostSold - s.CostRetSold) AS YTDProfit 
	FROM dbo.trav_InHistoryByYearPeriodItemLocation_view s (NOLOCK) 
		INNER JOIN #tmpInSlowFastPTDNonZeroItems t ON s.ItemId = t.ItemId 
		INNER JOIN dbo.tblInItemLoc l ON l.ItemId = s.ItemId AND l.LocId = s.LocId
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId 
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod <= @Period 
	GROUP BY s.ItemId, s.LocId, i.Descr 
	HAVING (SUM(s.QtySold - s.QtyRetSold) <> 0)

	INSERT INTO #tmpInSlowFastMove(ItemId, LocId, Descr, PTDVolume, PTDSales, YTDVolume, YTDSales) 
	SELECT y.ItemId, y.LocId, y.Descr
		, ISNULL(p.PTDQty, 0) / ISNULL(ud2.ConvFactor, u.ConvFactor) AS PTDVolume
		, ISNULL(p.PTDSales, 0) AS PTDSales
		, ISNULL(y.YTDQty, 0) / ISNULL(ud2.ConvFactor, u.ConvFactor) AS YTDVolume, y.YTDSales 
	FROM #tmpInSlowFastYTDNonZeroDtl y 
		LEFT JOIN #tmpInSlowFastPTDNonZeroDtl p ON y.ItemId = p.ItemId AND y.LocID = p.LocID 
		INNER JOIN dbo.tblInItem i ON i.ItemId = y.ItemId 
		INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt 
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase 
		LEFT JOIN 
			(
				SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType 
				FROM dbo.tblInItemUomDflt ud 
					INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom 
				WHERE ud.DfltType = 1
			) AS ud2 ON i.itemId = ud2.ItemId 

	----- BEGIN Turns pulled from trav_InSalesAnalysisReport_proc -----
	CREATE TABLE #tmpInItemCost
	(
		ItemId pItemID NOT NULL, 
		LocId pLocID NOT NULL, 
		Cost pDecimal NOT NULL
	)

	CREATE TABLE #tmpInSalesPTDDtl
	(
		SumYear int, 
		SumPeriod int, 
		ItemId pItemID, 
		LocId pLocID, 
		TotSoldSub pDecimal, 
		TotRetSold pDecimal, 
		TotCogsAdj pDecimal, 
		TotPPVAmt pDecimal, 
		CostSold pDecimal, 
		CostRetSold pDecimal
	)

	CREATE TABLE #tmpInSalesPTD
	(
		ItemId pItemID, 
		LocId pLocID, 
		PTDTurns pDecimal
	)

	CREATE TABLE #tmpInSalesYTDDtl
	(
		SumYear int, 
		ItemId pItemID, 
		LocId pLocID, 
		TotSoldSub pDecimal, 
		TotRetSold pDecimal, 
		TotCogsAdj pDecimal, 
		TotPPVAmt pDecimal, 
		CostSold pDecimal, 
		CostRetSold pDecimal
	)

	CREATE TABLE #tmpInSalesYTD
	(
		ItemId pItemID, 
		LocId pLocID, 
		YTDTurns pDecimal
	)

	INSERT INTO #tmpInItemCost(ItemId, LocId, Cost) 
	SELECT ItemId, LocId, Cost FROM dbo.trav_InItemOnHand_view

	INSERT INTO #tmpInItemCost(ItemId, LocId, Cost) 
	SELECT ItemId, LocId, Cost FROM dbo.trav_InItemOnHandSer_view

	INSERT INTO #tmpInSalesPTDDtl(SumYear, SumPeriod, ItemId, LocId, TotSoldSub, TotRetSold, TotCogsAdj, TotPPVAmt, CostSold, CostRetSold) 
	SELECT s.SumYear, s.SumPeriod, s.ItemId, s.LocId
		, SUM(s.TotSold) AS TotSoldSub, SUM(s.TotRetSold) AS TotRetSold
		, SUM(s.TotCogsAdj) AS TotCogsAdj, SUM(s.TotPurchPriceVar) AS TotPPVAmt
		, SUM(s.CostSold) AS CostSold, SUM(s.CostRetSold) AS CostRetSold 
	FROM dbo.trav_InHistoryByYearPeriodItemLocation_view s 
	WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @Period 
	GROUP BY s.SumYear, s.SumPeriod, s.ItemId, s.LocId

	INSERT INTO #tmpInSalesPTD(ItemId, LocId, PTDTurns)
	SELECT i.ItemId, l.LocId
		, CASE WHEN DATENAME(DAYOFYEAR, @WksDate) * ISNULL(ts.Cost, 0) = 0 
			THEN 0 
			ELSE (@DaysInYear * (tp.CostSold - tp.CostRetSold 
				+ (CASE WHEN @CostingMethod = 3 
					THEN tp.TotCogsAdj - tp.TotPPVAmt 
					ELSE tp.TotCogsAdj END))) 
				/ (DATENAME(DAYOFYEAR, @WksDate) * ISNULL(ts.Cost, 0)) END AS PTDTurns 
	FROM dbo.tblInItemLoc l 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId 
		LEFT JOIN #tmpInItemCost ts ON l.LocId = ts.LocId AND l.ItemId = ts.ItemId 
		LEFT JOIN #tmpInSalesPTDDtl tp ON l.LocId = tp.LocId AND l.ItemId = tp.ItemId 
	WHERE tp.SumYear = @FiscalYear AND tp.SumPeriod = @Period AND (tp.TotSoldSub - tp.TotRetSold <> 0)

	INSERT INTO #tmpInSalesYTDDtl(SumYear, ItemId, LocId, TotSoldSub, TotRetSold, TotCogsAdj, TotPPVAmt, CostSold, CostRetSold) 
	SELECT s.SumYear, s.ItemId, s.LocId, SUM(s.TotSold) AS TotSoldSub, SUM(s.TotRetSold) AS TotRetSold
		, SUM(s.TotCogsAdj) AS TotCogsAdj, SUM(s.TotPurchPriceVar) AS TotPPVAmt
		, SUM(s.CostSold) AS CostSold, SUM(s.CostRetSold) AS CostRetSold 
	FROM dbo.trav_InHistoryByYearPeriodItemLocation_view s 
	WHERE s.SumYear = @FiscalYear 
	GROUP BY s.SumYear, s.ItemId, s.LocId

	INSERT INTO #tmpInSalesYTD(ItemId, LocId, YTDTurns)
	SELECT i.ItemId, l.LocId
		, CASE WHEN DATENAME(DAYOFYEAR, @WksDate) * ISNULL(ts.Cost, 0) = 0 
			THEN 0 
			ELSE (@DaysInYear * (ty.CostSold - ty.CostRetSold 
				+ (CASE WHEN @CostingMethod = 3 
					THEN ty.TotCogsAdj - ty.TotPPVAmt 
					ELSE ty.TotCogsAdj END))) 
				/ (DATENAME(DAYOFYEAR, @WksDate) * ISNULL(ts.Cost, 0)) END AS YTDTurns 
	FROM dbo.tblInItemLoc l 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId 
		LEFT JOIN #tmpInItemCost ts ON l.LocId = ts.LocId AND l.ItemId = ts.ItemId 
		LEFT JOIN #tmpInSalesYTDDtl ty ON l.LocId = ty.LocId AND l.ItemId = ty.ItemId 
	WHERE ty.SumYear = @FiscalYear AND (ty.TotSoldSub - ty.TotRetSold <> 0)

	SELECT ty.ItemId, ty.LocId, ISNULL(tp.PTDTurns, 0) AS PTDTurns, ISNULL(ty.YTDTurns, 0) AS YTDTurns 
	INTO #tmpTurns 
	FROM #tmpInSalesYTD ty 
		LEFT JOIN #tmpInSalesPTD tp ON ty.ItemId = tp.ItemId AND ty.LocId = tp.LocId
	----- END Turns pulled from trav_InSalesAnalysisReport_proc -----

	IF (@DetailSummary = 0)
	BEGIN
		INSERT INTO #tmpResults(ItemLoc, ItemId, LocId, Descr, PTDVolume, PTDSales, PTDTurns, YTDVolume, YTDSales, YTDTurns, SortBy) 
		SELECT LEFT(s.ItemId + REPLICATE(' ',24),24) + '/' + s.LocId AS ItemLoc, s.ItemId, s.LocId, s.Descr
			, s.PTDVolume, s.PTDSales, t.PTDTurns, s.YTDVolume, s.YTDSales, t.YTDTurns
			, CASE @VolumeSalesTurns 
				WHEN 0 THEN CASE WHEN @TimeFrame = 0 THEN s.PTDVolume ELSE s.YTDVolume END 
				WHEN 1 THEN CASE WHEN @TimeFrame = 0 THEN s.PTDSales ELSE s.YTDSales END 
					ELSE CASE WHEN @TimeFrame = 0 THEN t.PTDTurns ELSE t.YTDTurns END 
				END AS SortBy 
		FROM #tmpInSlowFastMove s 
			INNER JOIN #tmpTurns t ON s.ItemId = t.ItemId AND s.LocID = t.LocId 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpResults(ItemLoc, ItemId, LocId, Descr, PTDVolume, PTDSales, PTDTurns, YTDVolume, YTDSales, YTDTurns, SortBy) 
		SELECT s.ItemId AS ItemLoc, s.ItemId, NULL AS LocId, s.Descr
			, SUM(s.PTDVolume) AS PTDVolume, SUM(s.PTDSales) AS PTDSales, SUM(t.PTDTurns) AS PTDTurns
			, SUM(s.YTDVolume) AS YTDVolume, SUM(s.YTDSales) AS YTDSales, SUM(t.YTDTurns) AS YTDTurns
			, CASE @VolumeSalesTurns 
				WHEN 0 THEN CASE WHEN @TimeFrame = 0 THEN SUM(s.PTDVolume) ELSE SUM(s.YTDVolume) END 
				WHEN 1 THEN CASE WHEN @TimeFrame = 0 THEN SUM(s.PTDSales) ELSE SUM(s.YTDSales) END 
					ELSE CASE WHEN @TimeFrame = 0 THEN SUM(t.PTDTurns) ELSE SUM(t.YTDTurns) END 
				END AS SortBy 
		FROM #tmpInSlowFastMove s 
			INNER JOIN #tmpTurns t ON s.ItemId = t.ItemId AND s.LocID = t.LocId 
		GROUP BY s.ItemId, s.Descr
	END

	SET ROWCOUNT @ItemCount

	IF (@SlowFast = 0)
	BEGIN
		SELECT * FROM #tmpResults ORDER BY SortBy, ItemId, LocId ASC
	END
	ELSE
	BEGIN
		SELECT * FROM #tmpResults ORDER BY SortBy, ItemId, LocId DESC
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbInSlowFastMovement_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbInSlowFastMovement_proc';

