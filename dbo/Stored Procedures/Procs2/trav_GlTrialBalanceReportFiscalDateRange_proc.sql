
CREATE PROCEDURE dbo.trav_GlTrialBalanceReportFiscalDateRange_proc
@FiscalPeriodFrom smallint, 
@FiscalYearFrom smallint, 
@FiscalPeriodThru smallint, 
@FiscalYearThru smallint, 
@PeriodsPerYear smallint, 
@SortOrder nvarchar(80), 
@PrintByAccoutType bit, 
@PrintZeroBalance bit, 
@MultiCurrency bit, 
@BaseCurrency pCurrency, 
@BFRef int, /* 0 = Current Year, -1 = Last Year */
@BFType tinyint, /* 0 = Budget, 1 = Forecast, 2 = Actual */
@ExcludeClosingPeriod bit

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @SortString nvarchar(255)
	DECLARE @ctr smallint
	DECLARE @ExchRate pDecimal
	DECLARE @CompID nvarchar(3)
	DECLARE @sql nvarchar(MAX)

	CREATE TABLE #AcctInfo 
	(
		SortOrder1 pGlAcct NULL, 
		SortOrder2 pGlAcct NULL, 
		AcctId pGlAcct NULL, 
		Actual pCurrDecimal NULL, 
		DFBudget pCurrDecimal NULL, 
		DFForecast pCurrDecimal NULL, 
		AcctTypeId smallint NULL
	)

	CREATE TABLE #tempPdYear 
	(
 		Period smallint NOT NULL, 
 		[Year] smallint NOT NULL
	)

	SET @sql = ''
	SET @CompID  = LEFT(DB_NAME(), 3)

	IF (@BFRef = -1)
	BEGIN
		SET @FiscalYearFrom = @FiscalYearFrom - 1
		SET @FiscalYearThru = @FiscalYearThru - 1
	END

	/* build period/year temp table */
	INSERT INTO #tempPdYear (Period, [Year]) 
	SELECT p.GlPeriod, p.GlYear 
	FROM dbo.tblSmPeriodConversion p 
	WHERE (p.GlYear * 1000) + p.GlPeriod 
		BETWEEN (@FiscalYearFrom * 1000) + @FiscalPeriodFrom AND (@FiscalYearThru * 1000) + @FiscalPeriodThru

	/* add closing period to period/year temp table when necessary */
	DECLARE @Year int
	SET @Year = @FiscalYearFrom
	WHILE @Year <= @FiscalYearThru
	BEGIN
		IF ((@FiscalYearThru > @Year) OR (@FiscalYearThru = @Year) 
			AND (@FiscalPeriodThru > @PeriodsPerYear)) AND (@ExcludeClosingPeriod = 0)
		BEGIN
			INSERT INTO #tempPdYear (Period, [Year]) 
			VALUES (@PeriodsPerYear + 1, @Year)
		END
		SET @Year = @Year + 1
	END

	IF (@FiscalPeriodFrom = 0)
	BEGIN
		INSERT INTO #tempPdYear (Period, [Year]) 
		VALUES (0, @FiscalYearFrom)
	END

	INSERT INTO #AcctInfo (AcctId, Actual, DFBudget, DFForecast, AcctTypeId) 
	SELECT h.AcctId, SUM(h.ActualBase) AS Actual, SUM(ISNULL(b.DFBudget, 0)) AS DFBudget
		, SUM(ISNULL(f.DFForecast, 0)) AS DFForecast, h.AcctTypeId 
	FROM 
	(
		SELECT h.AcctId, SUM(ISNULL(d.ActualBase, 0)) AS ActualBase, h.AcctTypeId 
		FROM #tmpAccountList m 
			INNER JOIN dbo.tblGlAcctHdr h ON m.AcctId = h.AcctId 
			LEFT JOIN 
			(
				SELECT AcctId, ActualBase, d.[Year], d.Period 
				FROM dbo.tblGlAcctDtl d 
					INNER JOIN #tempPdYear p ON d.[Year] = p.[Year] AND d.Period = p.Period
			) d ON h.AcctId = d.AcctId 
		WHERE  h.AcctTypeId < 900 
		GROUP BY h.AcctId, h.AcctTypeId
	) h 
		LEFT JOIN 
		(
			SELECT dbf.AcctID, SUM(ISNULL(dbf.Amount, 0) / ISNULL(e.ExchRate, 1)) AS DFBudget 
			FROM dbo.tblGlAcctDtlBudFrcst dbf 
				INNER JOIN  #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef 
				INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef 
				INNER JOIN #tempPdYear p ON dbf.GlYear = p.[Year] AND dbf.GlPeriod = p.Period 
				INNER JOIN dbo.tblGlAcctHdr hdr ON dbf.AcctID = hdr.AcctId 
				LEFT JOIN #tmpSmExchRateYrPd e ON e.FiscalYear = dbf.GlYear AND e.GlPeriod = dbf.GlPeriod 
					AND hdr.CurrencyId = e.CurrencyTo AND hdr.CurrencyId <> @BaseCurrency 
			WHERE t.BFType = 0 AND dbf.BFRef = @BFRef AND c.CompID = @CompID 
			GROUP BY dbf.AcctId
		) b ON h.AcctId = b.AcctId 
		LEFT JOIN 
		(
			SELECT dbf.AcctID, SUM(ISNULL(dbf.Amount, 0) / ISNULL(e.ExchRate, 1)) AS DFForecast 
			FROM dbo.tblGlAcctDtlBudFrcst dbf 
				INNER JOIN  #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef 
				INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef 
				INNER JOIN #tempPdYear p ON dbf.GlYear = p.[Year] AND dbf.GlPeriod = p.Period 
				INNER JOIN dbo.tblGlAcctHdr hdr ON dbf.AcctID = hdr.AcctId 
				LEFT JOIN #tmpSmExchRateYrPd e ON e.FiscalYear = dbf.GlYear AND e.GlPeriod = dbf.GlPeriod 
					AND hdr.CurrencyId = e.CurrencyTo AND hdr.CurrencyId <> @BaseCurrency 
			WHERE ABS(t.BFType) = 1 AND dbf.BFRef = @BFRef AND c.CompID = @CompID 
			GROUP BY dbf.AcctId
		) f ON h.AcctId = f.AcctId 
	GROUP BY h.AcctId, h.AcctTypeId

	SET @SortString = 'h.AcctId'
	IF @SortOrder <> ''
	BEGIN
		SET @SortString = ''

		WHILE CHARINDEX(',', @SortOrder) <> 0
		BEGIN
			SET @ctr = CHARINDEX(',', @SortOrder)
			IF LEN(@SortString) > 0 SET @SortString = @SortString + ' + '
			SET @SortString = @SortString + 'h.Segment' + SUBSTRING(@SortOrder, 1, @ctr - 1)
			SET @SortOrder = RIGHT(@SortOrder, LEN(@SortOrder) - @ctr )
		END
		SET @SortString = @SortString + ' + h.Segment' + @SortOrder
	END

	/* pack the AcctTypeId with 0's for proper numeric sorting of report */
	SET @sql = 'UPDATE #AcctInfo SET SortOrder1 = CASE WHEN ' + STR(@PrintByAccoutType) + ' = 1 THEN RIGHT(REPLICATE(nchar(48), 6) + CAST(#AcctInfo.AcctTypeId AS nvarchar), 6) ELSE '
	SET @sql = @sql + @SortString + ' END, SortOrder2 = ' + @SortString
	SET @sql = @sql + ' FROM #AcctInfo INNER JOIN dbo.trav_GlAccountHeader_view h ON #AcctInfo.AcctId = h.AcctId'

	EXECUTE (@sql)

	SELECT i.SortOrder1, i.SortOrder2, h.AcctId, h.[Desc], h.AcctTypeId, t.[Desc] AcctTypeDesc
		, CASE WHEN h.BalType * Actual > 0 THEN h.BalType * Actual ELSE 0 END AS ActualDebit
		, CASE WHEN h.BalType * Actual < 0 THEN -h.BalType * Actual ELSE 0 END AS ActualCredit
		, CASE WHEN h.BalType * DFBudget > 0 THEN h.BalType * DFBudget ELSE 0 END AS BudgetDebit
		, CASE WHEN h.BalType * DFBudget < 0 THEN -h.BalType * DFBudget ELSE 0 END AS BudgetCredit
		, CASE WHEN h.BalType * DFForecast > 0 THEN h.BalType * DFForecast ELSE 0 END AS ForecastDebit
		, CASE WHEN h.BalType * DFForecast < 0 THEN -h.BalType * DFForecast ELSE 0 END AS ForecastCredit 
	FROM dbo.tblGlAcctHdr h 
		INNER JOIN dbo.tblGlAcctType t ON h.AcctTypeId = t.AcctTypeId 
		INNER JOIN #AcctInfo i ON h.AcctId = i.AcctId 
	WHERE CASE WHEN @PrintZeroBalance <> 0 THEN 1 ELSE 
				CASE @BFType WHEN 1 THEN ABS(DFForecast) WHEN 0 THEN ABS(DFBudget) ELSE ABS(Actual) END 
			END <> 0 /* conditionally add criteria to filter out zero balance accounts */
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlTrialBalanceReportFiscalDateRange_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlTrialBalanceReportFiscalDateRange_proc';

