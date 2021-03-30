
CREATE PROCEDURE dbo.trav_GlAuditTrialBalanceReport_proc
@FiscalPeriodFrom smallint, 
@FiscalYear smallint, 
@FiscalPeriodThru smallint, 
@FiscalYearThru smallint, 
@PeriodsPerYear smallint, 
@SortOrder nvarchar(80), 
@BFRef int /* 0 = Current Year, -1 = Last Year */

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @CrossTab nvarchar(MAX)
	DECLARE @sql nvarchar(MAX)
	DECLARE @CompID nvarchar(3)
	DECLARE @SortString nvarchar(255)
	DECLARE @ctr smallint

	CREATE TABLE #Temp 
	(
		SortOrder nvarchar(255) NULL, 
		AcctID pGlAcct NOT NULL, 
		[Desc] nvarchar(50) NULL, 
		CYActual pCurrDecimal NOT NULL, 
		LYActual pCurrDecimal NOT NULL, 
		DFBudget pCurrDecimal NOT NULL, 
		DFForecast pCurrDecimal NOT NULL, 
		CurrencyId pCurrency NOT NULL
	)

	CREATE TABLE #tempPdYear 
	(
 		Period smallint NOT NULL, 
 		[Year] smallint NOT NULL
	)

	SET @CrossTab = ''
	SET @CompID  = LEFT(DB_NAME(), 3)

	/* build period/year temp table */
	INSERT INTO #tempPdYear (Period, [Year]) 
	SELECT p.GlPeriod, p.GlYear 
	FROM dbo.tblSmPeriodConversion p 
	WHERE (p.GlYear * 1000) + p.GlPeriod 
		BETWEEN (@FiscalYear * 1000) + @FiscalPeriodFrom AND (@FiscalYearThru * 1000) + @FiscalPeriodThru

	/* add closing period to period/year temp table when necessary */
	DECLARE @Year int
	SET @Year = @FiscalYear
	WHILE @Year <= @FiscalYearThru
	BEGIN
		IF (@FiscalYearThru > @Year) OR (@FiscalYearThru = @Year) AND (@FiscalPeriodThru > @PeriodsPerYear)
		BEGIN
			INSERT INTO #tempPdYear (Period, [Year]) 
			VALUES (@PeriodsPerYear + 1, @Year)
		END
		SET @Year = @Year + 1
	END

	IF (@FiscalPeriodFrom = 0)
	BEGIN
		INSERT INTO #tempPdYear (Period, [Year]) 
		VALUES (0, @FiscalYear)
	END
	
	INSERT INTO #Temp (AcctID, [Desc], CYActual, LYActual, DFBudget, DFForecast, CurrencyId) 
	SELECT h.AcctId, h.[Desc], ISNULL(c.CYActual, 0), ISNULL(l.LYActual, 0)
		, ISNULL(b.DFBudget, 0), ISNULL(f.DFForecast, 0), h.CurrencyId 
	FROM #tmpAccountList m 
		INNER JOIN dbo.trav_GlAccountHeader_view h ON m.AcctId = h.AcctId 
		INNER JOIN dbo.tblGlAcctType t ON h.AcctTypeId = t.AcctTypeId 
		INNER JOIN dbo.tblGlAcctClass s ON t.AcctClassId = s.AcctClassId 
		LEFT JOIN 
		(
			SELECT AcctId, SUM(ISNULL(Actual, 0)) CYActual 
			FROM dbo.tblGlAcctDtl d 
				INNER JOIN #tempPdYear p ON d.[Year] = p.[Year] AND d.Period = p.Period
			GROUP BY AcctId
		) c ON h.AcctId = c.AcctId
		LEFT JOIN 
		(
			SELECT AcctId, SUM(ISNULL(Actual, 0)) LYActual 
			FROM dbo.tblGlAcctDtl d 
				INNER JOIN #tempPdYear p ON d.[Year] = (p.[Year] - 1) AND d.Period = p.Period
			GROUP BY AcctId
		) l ON h.AcctId = l.AcctId
		LEFT JOIN 
		(
			SELECT d.AcctID, SUM(ISNULL(d.Amount, 0)) DFBudget 
			FROM dbo.tblGlAcctDtlBudFrcst d 
				INNER JOIN #tmpGLBudFrcstDescr t ON d.BFRef = t.BFRef 
				INNER JOIN #tmpGLBudFrcstComp c ON d.BFRef = c.BFRef 
				INNER JOIN #tempPdYear p ON d.GlYear = p.[Year] AND d.GlPeriod = p.Period 
			WHERE t.BFType = 0 AND t.BFRef = @BFRef AND c.CompID = @CompID 
			GROUP BY d.AcctId
		) b ON h.AcctId = b.AcctId
		LEFT JOIN 
		(
			SELECT d.AcctID, SUM(Coalesce(d.Amount, 0)) DFForecast 
			FROM dbo.tblGlAcctDtlBudFrcst d 
				INNER JOIN #tmpGLBudFrcstDescr t ON d.BFRef = t.BFRef 
				INNER JOIN #tmpGLBudFrcstComp c ON d.BFRef = c.BFRef 
				INNER JOIN #tempPdYear p ON d.GlYear = p.[Year] AND d.GlPeriod = p.Period 
			WHERE ABS(t.BFType) = 1 AND t.BFRef = @BFRef AND c.CompID = @CompID 
			GROUP BY d.AcctId
		) f ON h.AcctId = f.AcctId 
	WHERE h.AcctTypeId < 900

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

	SET @sql = 'UPDATE #Temp SET SortOrder = ' + @SortString
	SET @sql = @sql + ' FROM #Temp INNER JOIN dbo.trav_GlAccountHeader_view h ON #Temp.AcctId = h.AcctId'

	EXECUTE (@sql)

	/* apply the Account Balance Type to the output values */
	UPDATE #Temp SET CYActual = -CYActual
		, LYActual = -LYActual
		, DFBudget = -DFBudget
		, DFForecast = -DFForecast 
	FROM #Temp t 
		INNER JOIN dbo.tblGlAcctHdr h ON t.AcctId = h.AcctId 
	WHERE h.BalType < 0

	SELECT d.BFType, replace(d.Heading, ' ', '') Heading
		, CASE d.BFType WHEN 0 THEN 'DFBudget' WHEN 1 THEN 'DFForecast' END  AS DFAmount 
	INTO #tmpDflt 
	FROM #tmpGLBudFrcstDescr d 
		INNER JOIN #tmpGLBudFrcstComp c ON d.BFRef = c.BFRef 
	WHERE c.CompID = @CompID AND d.BFRef = @BFRef

	SELECT @CrossTab = @CrossTab + ', ' + CAST(DFAmount AS nvarchar) +  '[DFB]' 
	FROM #tmpDflt

	SELECT @CrossTab = CASE WHEN LEN(@CrossTab) > 0 THEN @CrossTab ELSE SUBSTRING(@CrossTab, 2, LEN(@CrossTab)) END
	IF (@BFRef = -1)
		SELECT SortOrder, AcctID, [Desc], LYActual AS [DFB], CYActual AS CYAct, CurrencyId 
		FROM #Temp WHERE AcctID IS NOT NULL ORDER BY SortOrder
	ELSE
		EXEC('SELECT SortOrder, AcctID, [Desc], CYActual AS CYAct  ' +  @CrossTab + ', CurrencyId 
				FROM #Temp WHERE AcctID IS NOT NULL ORDER BY SortOrder')

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAuditTrialBalanceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAuditTrialBalanceReport_proc';

