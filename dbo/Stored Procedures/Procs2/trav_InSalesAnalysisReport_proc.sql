
CREATE PROCEDURE dbo.trav_InSalesAnalysisReport_proc
@HistoryPeriod smallint = 12,
@FiscalYear  smallint = 2008,
@SuppressZeroQtyItem  bit = 0,
@PrintOption tinyint = 0, -- 0, Period-To-Date;1, Year-To-Date;2, Both;
@CostingMethod tinyint = 0, -- 0, FIFO;1, LIFO;2, Average;3, Standard;
@ReportUom tinyint = 0 -- 0, Reporting;1, Base;
--todo, user defined fields
AS
SET NOCOUNT ON
BEGIN TRY
	
	CREATE TABLE #tmpInSalesAnalRptSub
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyOnHand pDecimal NOT NULL,
		Cost pDecimal NOT NULL
	)

	INSERT INTO #tmpInSalesAnalRptSub(ItemId, LocId, QtyOnHand, Cost)
	SELECT q.ItemId, q.LocId, q.QtyOnHand, q.Cost
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHand_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 


	INSERT INTO #tmpInSalesAnalRptSub(ItemId, LocId, QtyOnHand, Cost)
	SELECT q.ItemId, q.LocId, q.QtyOnHand, q.Cost
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandSer_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 

	IF @PrintOption = 0 OR @PrintOption = 2
	BEGIN
		SELECT s.SumYear,s.SumPeriod,s.ItemId,s.LocId,Sum(s.TotSold) AS TotSoldSub,Sum(s.TotRetSold) AS TotRetSold,Sum(s.TotCogsAdj) AS TotCogsAdj, 
			  Sum(s.TotPurchPriceVar) AS TotPPVAmt,Sum(s.CostSold) AS CostSold,Sum(s.CostRetSold) AS CostRetSold,Sum(s.QtySold) AS TotQtySoldSub,
			  Sum(s.QtyRetSold) AS TotQtyRetSold
		INTO #tmpInSalesAnalPTDRptSub       
		FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
		WHERE s.SumYear = @FiscalYear AND s.SumPeriod = @HistoryPeriod
		GROUP BY s.SumYear,s.SumPeriod,s.ItemId,s.LocId

		SELECT i.ItemId,l.LocId,tp.SumPeriod,tp.SumYear,i.Descr,a.AddlDescr,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,
			 u.ConvFactor,
			 CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,u.Uom) ELSE Base.Uom END AS UomDflt,
			 l.DateLastSale,
			 ((tp.TotSoldSub-tp.TotRetSold) -(CASE WHEN @CostingMethod=3 THEN tp.CostSold-tp.CostRetSold+tp.TotCOGSAdj+tp.TotPPVAmt ELSE tp.CostSold-tp.CostRetSold+tp.TotCOGSAdj END)) AS ProfitAmt, 
			 CASE WHEN tp.TotSoldSub-tp.TotRetSold = 0 THEN 0 ELSE (((tp.TotSoldSub-tp.TotRetSold) -(CASE WHEN @CostingMethod=3 THEN tp.CostSold-tp.CostRetSold+tp.TotCOGSAdj+tp.TotPPVAmt ELSE tp.CostSold-tp.CostRetSold+tp.TotCOGSAdj END))/(tp.TotSoldSub-tp.TotRetSold))*100 END AS MarginPct, 
			 tp.TotSoldSub-tp.TotRetSold AS TotSold,
			 (tp.TotQtySoldSub-tp.TotQtyRetSold)/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS TotQtySold,
			 (CASE WHEN @CostingMethod=3 THEN tp.CostSold-tp.CostRetSold+tp.TotCOGSAdj+tp.TotPPVAmt ELSE tp.CostSold-tp.CostRetSold+tp.TotCOGSAdj END) AS COGSAdj,
			 CASE WHEN DATENAME(dayofyear, GETDATE()) *ISNULL(ts.Cost,0) = 0 THEN 0 ELSE (365*(tp.CostSold-tp.CostRetSold+(CASE WHEN @CostingMethod = 3 THEN tp.TotCogsAdj+tp.TotPPVAmt ELSE tp.TotCogsAdj END)))/(DATENAME(dayofyear, GETDATE()) *ISNULL(ts.Cost,0)) END AS Turns,
			 (ISNULL(ts.QtyOnHand,0)/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS OnHandQty
		INTO #tmpInSalesAnalPTDRpt
		FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId 
			INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
			INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
			LEFT JOIN dbo.tblInItemAddlDescr a ON i.ItemId = a.ItemId
		    LEFT JOIN #tmpInSalesAnalRptSub ts ON l.LocId = ts.LocId AND l.ItemId = ts.ItemId 
		    LEFT JOIN #tmpInSalesAnalPTDRptSub tp ON l.LocId = tp.LocId AND l.ItemId = tp.ItemId
			INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
			LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
				INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
		WHERE tp.SumYear = @FiscalYear AND tp.SumPeriod = @HistoryPeriod AND (@SuppressZeroQtyItem = 0 OR tp.TotSoldSub-tp.TotRetSold <> 0)
	END

	IF @PrintOption = 1 OR @PrintOption = 2
	BEGIN
		SELECT s.SumYear,s.ItemId,s.LocId,Sum(s.TotSold) AS TotSoldSub,Sum(s.TotRetSold) AS TotRetSold,Sum(s.TotCogsAdj) AS TotCogsAdj, 
		   Sum(s.TotPurchPriceVar) AS TotPPVAmt,Sum(s.CostSold) AS CostSold,Sum(s.CostRetSold) AS CostRetSold,Sum(s.QtySold) AS TotQtySoldSub,
			  Sum(s.QtyRetSold) AS TotQtyRetSold
		INTO #tmpInSalesAnalYTDRptSub       
		FROM #tmpItemLocationList t INNER JOIN dbo.trav_InHistoryByYearPeriodItemLocation_view s ON t.ItemId = s.ItemId AND t.LocId = s.LocId
		WHERE s.SumYear = @FiscalYear
		GROUP BY s.SumYear,s.ItemId,s.LocId

		SELECT i.ItemId,l.LocId,ty.SumYear,i.Descr,a.AddlDescr,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,
			 u.ConvFactor,
			 CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,u.Uom) ELSE Base.Uom END AS UomDflt,
			 l.DateLastSale,
			 ((ty.TotSoldSub-ty.TotRetSold) -(CASE WHEN @CostingMethod=3 THEN ty.CostSold-ty.CostRetSold+ty.TotCOGSAdj+ty.TotPPVAmt ELSE ty.CostSold-ty.CostRetSold+ty.TotCOGSAdj END)) AS ProfitAmt, 
			 CASE WHEN ty.TotSoldSub-ty.TotRetSold = 0 THEN 0 ELSE (((ty.TotSoldSub-ty.TotRetSold) -(CASE WHEN @CostingMethod=3 THEN ty.CostSold-ty.CostRetSold+ty.TotCOGSAdj+ty.TotPPVAmt ELSE ty.CostSold-ty.CostRetSold+ty.TotCOGSAdj END))/(ty.TotSoldSub-ty.TotRetSold))*100 END AS MarginPct, 
			 ty.TotSoldSub-ty.TotRetSold AS TotSold,
			 (ty.TotQtySoldSub-ty.TotQtyRetSold)/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS TotQtySold,
			 (CASE WHEN @CostingMethod=3 THEN ty.CostSold-ty.CostRetSold+ty.TotCOGSAdj+ty.TotPPVAmt ELSE ty.CostSold-ty.CostRetSold+ty.TotCOGSAdj END) AS COGSAdj,
			 CASE WHEN DATENAME(dayofyear, GETDATE()) *ISNULL(ts.Cost,0) = 0 THEN 0 ELSE (365*(ty.CostSold-ty.CostRetSold+(CASE WHEN @CostingMethod = 3 THEN ty.TotCogsAdj+ty.TotPPVAmt ELSE ty.TotCogsAdj END)))/(DATENAME(dayofyear, GETDATE()) *ISNULL(ts.Cost,0)) END AS Turns,
			 (ISNULL(ts.QtyOnHand,0)/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS OnHandQty
		INTO #tmpInSalesAnalYTDRpt
		FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId 
			INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
			INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
			LEFT JOIN dbo.tblInItemAddlDescr a ON i.ItemId = a.ItemId
			LEFT JOIN #tmpInSalesAnalRptSub ts ON l.LocId = ts.LocId AND l.ItemId = ts.ItemId 
			LEFT JOIN #tmpInSalesAnalYTDRptSub ty ON l.LocId = ty.LocId AND l.ItemId = ty.ItemId
			INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
			LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
				INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
		WHERE ty.SumYear = @FiscalYear AND (@SuppressZeroQtyItem = 0 OR ty.TotSoldSub - ty.TotRetSold <> 0)
	END
	/* By PTD */
	IF @PrintOption = 0 
	BEGIN
		 SELECT * FROM #tmpInSalesAnalPTDRpt
	END
	/* By YTD */
	ELSE IF @PrintOption = 1
	BEGIN
		 SELECT * FROM #tmpInSalesAnalYTDRpt
   	END 
	/* By Both */
	ELSE IF @PrintOption = 2
	BEGIN
		 SELECT ty.ItemId,ty.LocId,ty.SumYear,ty.Descr,ty.AddlDescr,ty.ProductLineZls,ty.UsrFld1Zls,ty.UsrFld2Zls,
				ty.ConvFactor,ty.UomDflt,ty.DateLastSale,ty.ProfitAmt,ty.MarginPct,ty.TotSold,ty.TotQtySold,ty.COGSAdj,
				ty.Turns,ty.OnHandQty,ISNULL(tp.ProfitAmt,0) AS PTDProfitAmt,ISNULL(tp.MarginPct,0) AS PTDMarginPct,
				ISNULL(tp.TotSold,0) AS PTDTotSold,ISNULL(tp.TotQtySold,0) AS PTDTotQtySold,ISNULL(tp.COGSAdj,0) AS PTDCOGSAdj,
				ISNULL(tp.Turns,0) AS PTDTurns,ISNULL(tp.OnHandQty,0) AS PTDOnHandQty
		 FROM #tmpInSalesAnalYTDRpt ty LEFT JOIN #tmpInSalesAnalPTDRpt tp
			  ON ty.ItemId = tp.ItemId AND ty.LocId = tp.LocId
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSalesAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSalesAnalysisReport_proc';

