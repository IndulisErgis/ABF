
CREATE PROCEDURE dbo.trav_ApApAnalysisReport_proc
@Year Int,
@Period Int,
@TotPeriod Smallint,
@PrecCurrency tinyint = 2, 
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

	DECLARE @LastAp pDecimal, @CurrAp pDecimal, @CurrTotPurch pDecimal, @CurrTotPmt pDecimal, @CurrTotDiscTaken pDecimal,
		@LastTotPurch pDecimal, @LastTotPmt pDecimal, @LastTotDiscTaken pDecimal, @PreGrossDue pDecimal
	 
	CREATE TABLE #tmpPeriods ( YrPeriod int NULL,
		CurrTotPurch pDecimal NULL default 0, CurrAp pDecimal NULL default 0, CurrTotPmt pDecimal NULL default 0, CurrPrepaidAmt pDecimal NULL default 0, CurrPurchDiscTaken pDecimal NULL default 0, 
		CurrPurchNoDisc pDecimal NULL default 0, CurrTotDiscTaken pDecimal NULL default 0, CurrTotDiscLost pDecimal NULL default 0, CurrPaidOnAcct pDecimal NULL default 0, CurrDiscAvail pDecimal NULL default 0,

		PreTotPurch pDecimal NULL default 0, PreAp pDecimal NULL default 0, PreTotPmt pDecimal NULL default 0, PrePrepaidAmt pDecimal NULL default 0, PrePurchDiscTaken pDecimal NULL default 0, PrePurchNoDisc pDecimal NULL default 0,
		PreTotDiscTaken pDecimal NULL default 0, PreTotDiscLost pDecimal NULL default 0, PrePaidOnAcct pDecimal NULL default 0, 	PreDiscAvail pDecimal NULL default 0,

		AvgTotPurch pDecimal NULL default 0, AvgAp pDecimal NULL default 0, AvgTotPmt pDecimal NULL default 0, AvgPrepaidAmt pDecimal NULL default 0, AvgPurchDiscTaken pDecimal NULL default 0, AvgPurchNoDisc pDecimal NULL default 0,
		AvgTotDiscTaken pDecimal NULL default 0, AvgTotDiscLost pDecimal NULL default 0, AvgPaidOnAcct pDecimal NULL default 0, AvgDiscAvail pDecimal NULL default 0,

		LastTotPurch pDecimal NULL default 0, LastAp pDecimal NULL default 0, LastTotPmt pDecimal NULL default 0, LastPrepaidAmt pDecimal NULL default 0, LastPurchDiscTaken pDecimal NULL default 0, LastPurchNoDisc pDecimal NULL default 0,
		LastTotDiscTaken pDecimal NULL default 0,	LastTotDiscLost pDecimal NULL default 0, LastPaidOnAcct pDecimal NULL default 0, LastDiscAvail pDecimal NULL default 0 )

	CREATE TABLE #tmpYrPeriod 
	(SeqNum Int NOT NULL, [Year] Int NOT NULL, Period Int NOT NULL, TotPurch pDecimal NOT NULL, 
	 GrossDue pDecimal NOT NULL, TotPmt pDecimal NOT NULL, PrepaidAmt pDecimal NOT NULL, PurchDiscTaken pDecimal NOT NULL,  
	 PurchNoDisc pDecimal NOT NULL, TotDiscTaken pDecimal NOT NULL,  TotDiscLost pDecimal NOT NULL)

	INSERT INTO #tmpYrPeriod (SeqNum, [Year], Period, TotPurch, GrossDue, TotPmt, PrepaidAmt, PurchDiscTaken, PurchNoDisc
		, TotDiscTaken, TotDiscLost)
	SELECT y.SeqNum, y.[Year], y.Period, ISNULL(t.TotPurch, 0), ISNULL(t.TotPurch, 0) - ISNULL(p.TotPmt, 0) - ISNULL(p.TotDiscTaken, 0),
		ISNULL(p.TotPmt, 0), ISNULL(t.PrepaidAmt, 0), ISNULL(p.PurchDiscTaken, 0),  
		ISNULL(p.PurchNoDisc, 0), ISNULL(p.TotDiscTaken, 0),  ISNULL(p.TotDiscLost, 0)
	FROM
		(SELECT 1 SeqNum,@Year [Year], @Period Period --Current Period
		UNION ALL 
		SELECT 2, CASE WHEN @Period - 1 = 0 THEN @Year -1 ELSE @Year END, 
			CASE WHEN @Period - 1 = 0 THEN @TotPeriod ELSE @Period - 1 END --Previous Period
		UNION ALL
		SELECT 3, CASE WHEN @Period - 2 <= 0  THEN @Year -1 ELSE @Year END,
			CASE WHEN @Period - 1 = 0 THEN @TotPeriod -1 
			WHEN @Period - 2 = 0 THEN @TotPeriod ELSE @Period - 2 END --Two Period ago
		UNION ALL
		SELECT 4, @Year - 1, @Period --Last Year Same Period
		) y 
		LEFT JOIN #tmpHistHeader t ON y.[Year] = t.FiscalYear AND y.Period = t.GlPeriod 
		LEFT JOIN #tmpCheckHist p ON y.[Year] = p.FiscalYear AND y.Period = p.GlPeriod

	--Calculate total AP up to current period 
	SELECT @CurrTotPurch = ISNULL(SUM(TotPurch), 0) 
	FROM #tmpHistHeader 
	WHERE (FiscalYear = @Year AND GlPeriod < = @Period) OR  FiscalYear < @Year

	SELECT @CurrTotPmt = ISNULL(SUM(TotPmt), 0) , @CurrTotDiscTaken = ISNULL(SUM(TotDiscTaken), 0)
	FROM #tmpCheckHist 
	WHERE (FiscalYear = @Year AND GlPeriod < = @Period) OR  FiscalYear < @Year

	SET @CurrAp = ISNULL(@CurrTotPurch, 0) - ISNULL(@CurrTotPmt, 0) - ISNULL(@CurrTotDiscTaken, 0)

	--Calculate total AP up to Last Year Same Period
	SELECT @LastTotPurch = ISNULL(SUM(TotPurch), 0) 
	FROM #tmpHistHeader 
	WHERE (FiscalYear = @Year - 1 AND GlPeriod < = @Period) OR  FiscalYear < @Year - 1

	SELECT @LastTotPmt = ISNULL(SUM(TotPmt), 0) , @LastTotDiscTaken = ISNULL(SUM(TotDiscTaken), 0)
	FROM #tmpCheckHist 
	WHERE (FiscalYear = @Year - 1 AND GlPeriod < = @Period) OR  FiscalYear < @Year - 1

	SET @LastAp = ISNULL(@LastTotPurch, 0) - ISNULL(@LastTotPmt, 0) - ISNULL(@LastTotDiscTaken, 0)

	--GrossDue of previous period
	SELECT @PreGrossDue = GrossDue
	FROM #tmpYrPeriod
	WHERE SeqNum = 2

	-- Current Period
	INSERT INTO #tmpPeriods (YrPeriod,	CurrTotPurch, CurrAp, CurrTotPmt, CurrPrepaidAmt, CurrPurchDiscTaken, 
			CurrPurchNoDisc, CurrTotDiscTaken, CurrTotDiscLost, CurrPaidOnAcct, CurrDiscAvail, PreAp, LastAp,
			AvgAp  )
	SELECT ([Year] * 1000 + Period), TotPurch, @CurrAp, TotPmt, PrepaidAmt,	PurchDiscTaken, PurchNoDisc, 
		TotDiscTaken, TotDiscLost, (TotPmt - PrepaidAmt), (TotDiscTaken + TotDiscLost), @CurrAp - GrossDue,
		@LastAp, ISNULL((3 * @CurrAp - 2 * GrossDue - @PreGrossDue)/3, 0)
	FROM #tmpYrPeriod
	WHERE SeqNum = 1

	-- Previous Period
	UPDATE #tmpPeriods 
	SET PreTotPurch = t.TotPurch, PreTotPmt = t.TotPmt, PrePrepaidAmt = t.PrepaidAmt,
		PrePurchDiscTaken = t.PurchDiscTaken, PrePurchNoDisc = t.PurchNoDisc, PreTotDiscTaken = t.TotDiscTaken,
		PreTotDiscLost = t.TotDiscLost, PrePaidOnAcct = t.TotPmt - t.PrepaidAmt, PreDiscAvail = t.TotDiscTaken + t.TotDiscLost
	FROM #tmpPeriods, #tmpYrPeriod t
	WHERE t.SeqNum = 2

	-- Last Year Same Period
	UPDATE #tmpPeriods 
	SET LastTotPurch = t.TotPurch, LastTotPmt = t.TotPmt, LastPrepaidAmt = t.PrepaidAmt,
		LastPurchDiscTaken = t.PurchDiscTaken, LastPurchNoDisc = t.PurchNoDisc, LastTotDiscTaken = t.TotDiscTaken,
		LastTotDiscLost = t.TotDiscLost, LastPaidOnAcct = t.TotPmt - t.PrepaidAmt, LastDiscAvail = t.TotDiscTaken + t.TotDiscLost
	FROM #tmpPeriods, #tmpYrPeriod t
	WHERE t.SeqNum = 4

	-- 3 Period Avg.
	UPDATE #tmpPeriods 
	SET AvgTotPurch = t.AvgTotPurch, AvgTotPmt = t.AvgTotPmt, AvgPrepaidAmt = t.AvgPrepaidAmt,
		AvgPurchDiscTaken = t.AvgPurchDiscTaken, AvgPurchNoDisc = t.AvgPurchNoDisc, AvgTotDiscTaken = t.AvgTotDiscTaken,
		AvgTotDiscLost = t.AvgTotDiscLost, AvgPaidOnAcct = t.AvgTotPmt - t.AvgPrepaidAmt, AvgDiscAvail = t.AvgTotDiscTaken + t.AvgTotDiscLost
	FROM #tmpPeriods, (SELECT AVG(TotPurch) AvgTotPurch, AVG(TotPmt) AvgTotPmt,
		AVG(PrepaidAmt) AvgPrepaidAmt, AVG(PurchDiscTaken) AvgPurchDiscTaken,
		AVG(PurchNoDisc) AvgPurchNoDisc, AVG(TotDiscTaken) AvgTotDiscTaken,
		AVG(TotDiscLost) AvgTotDiscLost	  
		FROM #tmpYrPeriod
		WHERE SeqNum < 4) t

	SELECT  YrPeriod, CurrTotPurch, CurrAp, CurrTotPmt,	CurrPrepaidAmt, CurrPurchDiscTaken, 
		CurrPurchNoDisc, CurrTotDiscTaken, CurrTotDiscLost, CurrPaidOnAcct, CurrDiscAvail,
		PreTotPurch, PreAp, PreTotPmt, PrePrepaidAmt, PrePurchDiscTaken, PrePurchNoDisc, 
		PreTotDiscTaken, PreTotDiscLost, PrePaidOnAcct, PreDiscAvail,
		AvgTotPurch, AvgAp, AvgTotPmt, AvgPrepaidAmt, AvgPurchDiscTaken, AvgPurchNoDisc,
		AvgTotDiscTaken, AvgTotDiscLost, AvgPaidOnAcct,	AvgDiscAvail,
		LastTotPurch, LastAp, LastTotPmt, LastPrepaidAmt, LastPurchDiscTaken, LastPurchNoDisc,
		LastTotDiscTaken, LastTotDiscLost, LastPaidOnAcct, LastDiscAvail
	FROM #tmpPeriods
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApApAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApApAnalysisReport_proc';

