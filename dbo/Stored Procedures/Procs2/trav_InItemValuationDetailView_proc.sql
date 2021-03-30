
CREATE PROCEDURE [dbo].[trav_InItemValuationDetailView_proc]
@AsOfDate datetime = '20161231',
@AsOfDateOption tinyint = 0, --As Of Date option (0=BY date/1=BY gl period & fiscal year)
@AsOfGlPeriod smallint = 12,
@AsOfFiscalYear smallint = 2016,
@CurrencyPrecision tinyint = 2,
@QuantityPrecision tinyint = 4,
@ReportUom tinyint = 0, -- 0, Reporting;1, Base;
@CostingMethod tinyint = 0 -- 0, FIFO/LIFO; 1, Average; 2, Standard;
AS
BEGIN TRY
	SET NOCOUNT ON
	  
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
	SELECT	i.ItemId, i.Descr, i.ProductLine, l.LocId, 
			v.QtyOnHand / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END Qty,
			CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,i.UomDflt) ELSE Base.Uom END AS UOM, 	
			CASE WHEN v.QtyOnHand = 0 THEN 0 ELSE (v.ExtCost / (v.QtyOnHand/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END)) END CostUnit, 
			v.TotCogsAdj, 
			v.TotPurchPriceVar,
			v.ExtCost,	
			l.ABCClass, 
			l.GLAcctCode, 
			i.ItemType, 
			CAST(i.KittedYN AS bit) [KittedYN], 
			l.ItemLocStatus, 
			i.LottedYN, 
			i.SalesCat, 
			i.TaxClass, 
			CASE WHEN @ReportUom = 0 THEN 'Reporting' ELSE 'Base' END ReportUOM,
			h.HMCode, 
			l.DfltVendId, 
			l.DfltBinNum, 
			l.DateLastSale, 
			l.DateLastPurch 
	FROM	dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
			INNER JOIN #InValuationResults v ON l.ItemId = v.ItemId AND l.LocId = v.LocId
			INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
			INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
			LEFT JOIN (	SELECT	ud.ItemId, dflt.ConvFactor, ud.Uom, ud.DfltType 
						FROM	dbo.tblInItemUomDflt ud 
								INNER JOIN dbo.tblInItemUom dflt ON ud.ItemId = dflt.ItemId AND ud.Uom = dflt.Uom 
						WHERE	ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
			LEFT JOIN dbo.tblInHazMat h ON i.HMRef = h.HMRef 
	WHERE	v.QtyOnHand <> 0 OR v.TotCogsAdj <> 0 OR v.ExtCost <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemValuationDetailView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemValuationDetailView_proc';

