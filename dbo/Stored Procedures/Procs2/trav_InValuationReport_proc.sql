
CREATE PROCEDURE dbo.trav_InValuationReport_proc
@AsOfDate datetime = '20081231',
@AsOfDateOption tinyint = 0, --As Of Date option (0=BY date/1=BY gl period & fiscal year)
@AsOfGlPeriod smallint = 12,
@AsOfFiscalYear smallint = 2008,
@CurrencyPrecision tinyint = 2,
@QuantityPrecision tinyint = 4,
@ReportUom tinyint = 0, -- 0, Reporting;1, Base;
@PrintDetail bit = 1,
@SummaryBy tinyint = 0, -- 0, Item Id; 1, Location Id; 2, Product line;
@CostingMethod tinyint = 0 -- 0, FIFO/LIFO; 1, Average; 2, Standard;
AS
SET NOCOUNT ON
BEGIN TRY
  
	--create the temp table populated by qryInValuation to retrieve the results
	CREATE TABLE #InValuationResults
	(
		ItemId pItemId,
		LocId pItemId,
		QtyOnHand pDecimal DEFAULT(0),
		ExtCost pDecimal DEFAULT(0),
		PeriodBegBal pDecimal DEFAULT(0),
		YearBegBal pDecimal DEFAULT(0),
		COGS pDecimal DEFAULT(0),
		CostPurchased pDecimal DEFAULT(0),              
		CostMatReq pDecimal DEFAULT(0),
		CostXfer pDecimal DEFAULT(0),
		CostAdj pDecimal DEFAULT(0),
		TotCogsAdj pDecimal DEFAULT(0),
		TotPurchPriceVar pDecimal DEFAULT(0),
		Uom pUom
	)
	CREATE INDEX [IX_InValuationResults] ON #InValuationResults(ItemId, LocId)

	--call the valuation calc routines to populate the resultset table
	Exec dbo.trav_InValuation_proc @AsOfDate, @AsOfDateOption, @AsOfGlPeriod, @AsOfFiscalYear,
		@CurrencyPrecision, @QuantityPrecision, @CostingMethod

	--return the resultset
	IF @PrintDetail = 1
	BEGIN
		SELECT i.ItemId, l.LocId, l.GLAcctCode, i.Descr
			, i.ProductLine, i.UsrFld1, i.UsrFld2,
			v.QtyOnHand / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END Qty,
			CASE WHEN v.QtyOnHand = 0 THEN 0 ELSE (v.ExtCost / (v.QtyOnHand/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END)) End CostUnit, 
			v.ExtCost,	v.PeriodBegBal PeriodBegBal, 
			v.YearBegBal YearBegBal,
			v.COGS COGS, 
			v.CostPurchased CostPurchased,
			v.TotCogsAdj TotCogsAdj, 
			v.TotPurchPriceVar TotPurchPriceVar,
			v.CostMatReq CostMatReq, 
			v.CostXfer CostXfer, 
			v.CostAdj CostAdj,
			d.AddlDescr,
			CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,i.UomDflt) ELSE Base.Uom END AS UOM
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
			INNER JOIN #InValuationResults v ON l.ItemId = v.ItemId AND l.LocId = v.LocId
			LEFT JOIN dbo.tblInItemAddlDescr d ON i.ItemId = d.ItemId
			INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
			INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
			LEFT JOIN (SELECT ud.ItemId, dflt.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
				INNER JOIN dbo.tblInItemUom dflt ON ud.ItemId = dflt.ItemId AND ud.Uom = dflt.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
		WHERE v.QtyOnHand <> 0 OR v.TotCogsAdj <> 0 OR v.ExtCost <> 0
	END
	ELSE 
	BEGIN
		IF @SummaryBy = 0 -- Item Id
			SELECT i.ItemId, i.Descr 
				, SUM(v.QtyOnHand/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) Qty 
				, SUM(v.ExtCost) ExtCost 
				, SUM(v.PeriodBegBal) PeriodBegBal, SUM(v.YearBegBal) YearBegBal
				, SUM(v.COGS) COGS, SUM(v.CostPurchased) CostPurchased
				, SUM(v.TotCogsAdj) TotCogsAdj, SUM(v.TotPurchPriceVar) TotPurchPriceVar
				, SUM(v.CostMatReq) CostMatReq, SUM(v.CostXfer) CostXfer, SUM(v.CostAdj) CostAdj, i.ProductLine,
				CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,i.UomDflt) ELSE Base.Uom END AS UOM
				FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
				INNER JOIN #InValuationResults v ON l.ItemId = v.ItemId AND l.LocId = v.LocId
				INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
				INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
				LEFT JOIN (SELECT ud.ItemId, dflt.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
				INNER JOIN dbo.tblInItemUom dflt ON ud.ItemId = dflt.ItemId AND ud.Uom = dflt.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
				WHERE v.QtyOnHand <> 0 OR v.TotCogsAdj <> 0 OR v.ExtCost <> 0
				Group By i.ItemId, i.Descr, i.ProductLine, CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,i.UomDflt) ELSE Base.Uom END
		ELSE IF @SummaryBy = 1 -- Location Id
			SELECT l.LocId
				, SUM(v.QtyOnHand) Qty 
				, SUM(v.ExtCost) ExtCost
				, SUM(v.PeriodBegBal) PeriodBegBal, SUM(v.YearBegBal) YearBegBal
				, SUM(v.COGS) COGS, SUM(v.CostPurchased) CostPurchased
				, SUM(v.TotCogsAdj) TotCogsAdj, SUM(v.TotPurchPriceVar) TotPurchPriceVar
				, SUM(v.CostMatReq) CostMatReq, SUM(v.CostXfer) CostXfer, SUM(v.CostAdj) CostAdj
			FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
				INNER JOIN #InValuationResults v ON l.ItemId = v.ItemId AND l.LocId = v.LocId
			WHERE v.QtyOnHand <> 0 OR v.TotCogsAdj <> 0 OR v.ExtCost <> 0
			Group By l.LocId
		ELSE -- Product Line
			SELECT i.ProductLine
				, SUM(v.QtyOnHand) Qty 
				, SUM(v.ExtCost) ExtCost
				, SUM(v.PeriodBegBal) PeriodBegBal, SUM(v.YearBegBal) YearBegBal
				, SUM(v.COGS) COGS, SUM(v.CostPurchased) CostPurchased
				, SUM(v.TotCogsAdj) TotCogsAdj, SUM(v.TotPurchPriceVar) TotPurchPriceVar
				, SUM(v.CostMatReq) CostMatReq, SUM(v.CostXfer) CostXfer, SUM(v.CostAdj) CostAdj
			FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
				INNER JOIN #InValuationResults v ON l.ItemId = v.ItemId AND l.LocId = v.LocId
			WHERE v.QtyOnHand <> 0 OR v.TotCogsAdj <> 0 OR v.ExtCost <> 0
			Group By i.ProductLine
	END

	SELECT l.GlAcctCode,g.GLAcctInv
		, SUM(v.ExtCost) ExtCost
		, SUM(v.PeriodBegBal) TotalPeriodBegBal, SUM(v.YearBegBal) TotalYearBegBal
		, SUM(v.COGS) TotalCostSold, SUM(v.CostPurchased) TotalCostPurch
		, SUM(v.TotCogsAdj) TotCogsAdj, SUM(v.TotPurchPriceVar) TotPurchPriceVar
		, SUM(v.CostMatReq) TotalCostMatReq, SUM(v.CostXfer) TotalCostXfer, SUM(v.CostAdj) TotalCostAdj
	FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
		INNER JOIN #InValuationResults v ON l.ItemId = v.ItemId AND l.LocId = v.LocId
		INNER JOIN dbo.tblInGLAcct g ON l.GlAcctCode = g.GlAcctCode 
	WHERE v.QtyOnHand <> 0 OR v.TotCogsAdj <> 0 OR v.ExtCost <> 0
	GROUP BY l.GlAcctCode,g.GLAcctInv

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InValuationReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InValuationReport_proc';

