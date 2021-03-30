
CREATE PROCEDURE dbo.trav_ApPurchaseAnalysisReport_proc
@Year Int,
@Period Int,
@TotPeriod Smallint, 
@IncludeSalesTax bit, 
@IncludeFreightCharges bit, 
@IncludeMiscCharges bit

AS
BEGIN TRY

	CREATE TABLE #tmpHistHeader 
	(
		FiscalYear smallint, 
		GLPeriod smallint, 
		NumOfPurch int, 
		TotPurch pDecimal NULL DEFAULT (0), 
		PrepaidAmt pDecimal NULL DEFAULT (0)
	)

	INSERT INTO #tmpHistHeader(FiscalYear, GLPeriod, NumOfPurch, TotPurch, PrepaidAmt) 
	SELECT FiscalYear, GLPeriod, COUNT(TransType) AS NumOfPurch
		, SUM(SIGN(TransType) * 
			(Subtotal 
				+ CASE WHEN @IncludeSalesTax <> 0 THEN SalesTax + TaxAdjAmt ELSE 0 END 
				+ CASE WHEN @IncludeFreightCharges <> 0 THEN Freight ELSE 0 END 
				+ CASE WHEN @IncludeMiscCharges <> 0 THEN Misc ELSE 0 END)
			) AS TotPurch
		, SUM(PrepaidAmt) AS PrepaidAmt 
	FROM dbo.tblApHistHeader 
	GROUP BY FiscalYear, GLPeriod

	CREATE TABLE #tmpCheckHist 
	(
		FiscalYear smallint, 
		GlPeriod smallint, 
		TotDiscTaken pDecimal NULL DEFAULT (0), 
		TotDiscLost pDecimal NULL DEFAULT (0), 
		PurchNoDisc pDecimal NULL DEFAULT (0), 
		PurchDiscTaken pDecimal NULL DEFAULT (0), 
		PurchDiscLost pDecimal NULL DEFAULT (0), 
		TotPmt pDecimal NULL DEFAULT (0)
	)

	INSERT INTO #tmpCheckHist(FiscalYear, GlPeriod, TotDiscTaken, TotDiscLost, PurchNoDisc, PurchDiscTaken, PurchDiscLost, TotPmt) 
	SELECT FiscalYear, GlPeriod, SUM(DiscTaken) AS TotDiscTaken
		, SUM(DiscLost) AS TotDiscLost
		, SUM(CASE WHEN DiscAmt = 0 THEN GrossAmtDue ELSE 0 END) AS PurchNoDisc
		, SUM(CASE WHEN DiscTaken <> 0 THEN GrossAmtDue ELSE 0 END) AS PurchDiscTaken
		, SUM(CASE WHEN DiscLost <> 0 THEN GrossAmtDue ELSE 0 END) AS PurchDiscLost
		, SUM(GrossAmtDue - DiscTaken) AS TotPmt 
	FROM dbo.tblApCheckHist 
	WHERE VoidYn = 0 
	GROUP BY FiscalYear, GlPeriod

	DECLARE @TotPurch pDecimal,@TotDiscTaken pDecimal,@TotDiscLost pDecimal,@LastTotPurch pDecimal , 
		@LastTotDiscTaken pDecimal,@LastTotDiscLost pDecimal,@QTDTotPurch pDecimal,@QTDTotDiscTaken pDecimal,@QTDTotDiscLost pDecimal,
		@YTDTotPurch pDecimal,@YTDTotDiscTaken pDecimal,@YTDTotDiscLost pDecimal,@LQTDTotPurch pDecimal,@LQTDTotDiscTaken pDecimal, 
		@LQTDTotDiscLost pDecimal,@LYTDTotPurch pDecimal,@LYTDTotDiscTaken pDecimal,@LYTDTotDiscLost pDecimal
	DECLARE @Qtr TinyInt, @YrPeriod Int

	CREATE TABLE #tmpYrPeriod 
	([Year] Int NOT NULL, Period Int NOT NULL, TotPurch pDecimal NOT NULL, 
	 TotDiscTaken pDecimal NOT NULL,  TotDiscLost pDecimal NOT NULL)
	
	SET @YrPeriod = @Year * 1000 + @Period

	INSERT INTO #tmpYrPeriod ([Year], Period, TotPurch, TotDiscTaken, TotDiscLost)
	SELECT y.GlYear, y.GlPeriod, ISNULL(t.TotPurch,0),ISNULL(p.TotDiscTaken,0),ISNULL(p.TotDiscLost,0)
	FROM (SELECT GlYear,GlPeriod FROM dbo.tblSmPeriodConversion 
			WHERE GlYear * 1000 + GlPeriod BETWEEN (@YrPeriod - 1000) AND @YrPeriod ) y
		LEFT JOIN #tmpHistHeader t ON y.GlYear = t.FiscalYear AND y.GlPeriod = t.GlPeriod 
		LEFT JOIN #tmpCheckHist p ON y.GlYear = p.FiscalYear AND y.GlPeriod = p.GlPeriod

	SET @Qtr = CAST((CAST(@Period AS Decimal(28,10)) * 4 / CAST(@TotPeriod AS Decimal(28,10)) + 0.9) AS TINYINT)

	-- Current Period
	SELECT @TotPurch = TotPurch
	FROM #tmpHistHeader 
	WHERE FiscalYear = @Year AND GlPeriod = @Period

	SELECT @TotDiscTaken = TotDiscTaken, @TotDiscLost = TotDiscLost
	FROM #tmpCheckHist 
	WHERE FiscalYear = @Year AND GlPeriod = @Period

	-- Current Period Last Year
	SELECT @LastTotPurch = TotPurch
	FROM #tmpHistHeader 
	WHERE FiscalYear = @Year - 1 AND GlPeriod = @Period

	SELECT @LastTotDiscTaken = TotDiscTaken, @LastTotDiscLost = TotDiscLost
	FROM #tmpCheckHist 
	WHERE FiscalYear = @Year - 1 AND GlPeriod = @Period

	-- Current Year QTD
	SELECT @QTDTotPurch = SUM(TotPurch)
	FROM #tmpHistHeader 
	WHERE FiscalYear = @Year AND GlPeriod <= @Period
		AND CAST((CAST(GlPeriod AS Decimal(28,10)) * 4 / CAST(@TotPeriod AS Decimal(28,10)) + 0.9) AS TINYINT) = @Qtr
	
	SELECT @QTDTotDiscTaken = SUM(TotDiscTaken), @QTDTotDiscLost = SUM(TotDiscLost)
	FROM #tmpCheckHist 
	WHERE FiscalYear = @Year AND GlPeriod <= @Period
		AND CAST((CAST(GlPeriod AS Decimal(28,10)) * 4 / CAST(@TotPeriod AS Decimal(28,10)) + 0.9) AS TINYINT) = @Qtr

	-- Last Year QTD
	SELECT @LQTDTotPurch = SUM(TotPurch)
	FROM #tmpHistHeader 
	WHERE FiscalYear = @Year - 1 AND GlPeriod <= @Period
		AND CAST((CAST(GlPeriod AS Decimal(28,10)) * 4 / CAST(@TotPeriod AS Decimal(28,10)) + 0.9) AS TINYINT) = @Qtr
	
	SELECT @LQTDTotDiscTaken = SUM(TotDiscTaken), @LQTDTotDiscLost = SUM(TotDiscLost)
	FROM #tmpCheckHist 
	WHERE FiscalYear = @Year - 1 AND GlPeriod <= @Period
		AND CAST((CAST(GlPeriod AS Decimal(28,10)) * 4 / CAST(@TotPeriod AS Decimal(28,10)) + 0.9) AS TINYINT) = @Qtr

	-- Current Year YTD
	SELECT @YTDTotPurch = SUM(TotPurch)
	FROM #tmpHistHeader 
	WHERE FiscalYear = @Year AND GlPeriod <= @Period

	SELECT @YTDTotDiscTaken = SUM(TotDiscTaken), @YTDTotDiscLost = SUM(TotDiscLost)
	FROM #tmpCheckHist 
	WHERE FiscalYear = @Year AND GlPeriod <= @Period

	-- Last Year YTD 
	SELECT @LYTDTotPurch = SUM(TotPurch)
	FROM #tmpHistHeader 
	WHERE FiscalYear = @Year - 1 AND GlPeriod <= @Period

	SELECT @LYTDTotDiscTaken = SUM(TotDiscTaken), @LYTDTotDiscLost = SUM(TotDiscLost)
	FROM #tmpCheckHist 
	WHERE FiscalYear = @Year - 1 AND GlPeriod <= @Period

	SELECT SUBSTRING(CAST(Period + 100 AS nvarchar(3)),2,2) + '/' + CAST([Year] AS nvarchar(4)) AS YrPeriod, 
		TotPurch, CASE WHEN ISNULL(@TotPurch,0) = 0 THEN 0 ELSE TotPurch/ISNULL(@TotPurch,0)*100 END PerTotPurch, 
		TotDiscTaken, CASE WHEN ISNULL(@TotDiscTaken,0) = 0 THEN 0 ELSE TotDiscTaken/ISNULL(@TotDiscTaken,0)*100 END PerTotDiscTaken, 
		TotDiscLost, CASE WHEN ISNULL(@TotDiscLost,0) = 0 THEN 0 ELSE TotDiscLost/ISNULL(@TotDiscLost,0)*100 END PerTotDiscLost
		FROM #tmpYrPeriod
	ORDER BY [Year] DESC, Period DESC
	
	SELECT  TotPurch = ISNULL(@TotPurch,0),TotDiscTaken = ISNULL(@TotDiscTaken,0),TotDiscLost = ISNULL(@TotDiscLost,0),
		QTDTotPurch = ISNULL(@QTDTotPurch,0), QTDTotDiscTaken = ISNULL(@QTDTotDiscTaken,0), QTDTotDiscLost = ISNULL(@QTDTotDiscLost,0),
		LQTDTotPurch = ISNULL(@LQTDTotPurch,0), LQTDTotDiscTaken = ISNULL(@LQTDTotDiscTaken,0), LQTDTotDiscLost = ISNULL(@LQTDTotDiscLost,0),
		LastTotPurch = ISNULL(@LastTotPurch,0), LastTotDiscTaken = ISNULL(@LastTotDiscTaken,0), LastTotDiscLost = ISNULL(@LastTotDiscLost,0),
		YTDTotPurch = ISNULL(@YTDTotPurch,0), YTDTotDiscTaken = ISNULL(@YTDTotDiscTaken,0), YTDTotDiscLost = ISNULL(@YTDTotDiscLost,0),
		LYTDTotPurch = ISNULL(@LYTDTotPurch,0), LYTDTotDiscTaken = ISNULL(@LYTDTotDiscTaken,0), LYTDTotDiscLost = ISNULL(@LYTDTotDiscLost,0)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPurchaseAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPurchaseAnalysisReport_proc';

