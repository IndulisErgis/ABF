
CREATE PROCEDURE dbo.trav_GlActivityReportRunningBalance_proc
@ReportCurrency pCurrency, 
@FiscalYear smallint, 
@YearFrom smallint, 
@YearThru smallint, 
@PeriodFrom smallint, 
@PeriodThru smallint, 
@ClosingPeriod smallint, 
@SourceCodeFrom nvarchar(2), 
@SourceCodeThru nvarchar(2), 
@PrintInactive bit, 
@IncludeZeroBalance bit, 
@SearchMissingEntries bit, 
@SortOrder nvarchar(80), 
@PeriodsPerYear smallint

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @sql nvarchar(1100)
	DECLARE @SortString nvarchar(255)
	DECLARE @ctr smallint
	DECLARE @Period smallint

	/* Create temp tables for select */
	CREATE TABLE #temp1
	(
		AcctId pGlAcct NOT NULL, 
		BalType smallint NOT NULL, 
		SumOfActual pCurrDecimal NOT NULL
	)

	CREATE TABLE #temp2
	(
		AcctId pGlAcct NOT NULL, 
		SumOfDebitAmt pCurrDecimal NOT NULL, 
		SumOfCreditAmt pCurrDecimal NOT NULL
	)

	CREATE TABLE #tempPdYear
	(
 		Period smallint NOT NULL, 
 		[Year] smallint NOT NULL
	)

	CREATE TABLE #temp3
	(
		AcctId pGlAcct NOT NULL, 
 		Period smallint NOT NULL, 
 		[Year] smallint NOT NULL, 
		SumOfActual pCurrDecimal NOT NULL, 
		Adjustment pCurrDecimal NOT NULL
	)

	CREATE TABLE #temp4
	(
		AcctId pGlAcct NOT NULL, 
		Period smallint NOT NULL, 
 		[Year] smallint NOT NULL, 
		AcctBalAmt pCurrDecimal NOT NULL
	)

	CREATE TABLE #temp5
	(
		AcctId pGlAcct NOT NULL, 
		Period smallint NOT NULL, 
 		[Year] smallint NOT NULL, 
		JrnlBalAmt pCurrDecimal NOT NULL
	)

	IF @SourceCodeFrom IS NULL SET @SourceCodeFrom = ''

	IF ISNULL(@SourceCodeThru,'') = '' SET @SourceCodeThru = 'zz'

	/* Build a list of Beginning balances by Account from Master */
	INSERT INTO #temp1 (AcctId, BalType, SumOfActual) 
	SELECT h.AcctId, h.BalType, ISNULL(d.Actual,0) 
	FROM #tmpAccountList t 
		INNER JOIN dbo.tblGlAcctHdr h ON t.AcctId = h.AcctId 
		LEFT JOIN 
		(
			SELECT AcctId, SUM(Actual) Actual FROM dbo.tblGlAcctDtl 
			WHERE [Year] = @YearFrom AND Period < @PeriodFrom 
			GROUP BY AcctId
		) d ON t.AcctId = d.AcctId 
	WHERE h.CurrencyId = @ReportCurrency AND h.BalType <> 0

	/* update Beginning balance for unposted entries */
	UPDATE #temp1 SET SumOfActual = SumOfActual + d.Unposted 
	FROM #temp1 t 
		INNER JOIN
		(
			SELECT d.AcctID
				, SUM(CASE WHEN h.BalType < 0 THEN - (d.DebitAmtFgn - d.CreditAmtFgn) 
					ELSE (d.DebitAmtFgn - d.CreditAmtFgn) END) AS Unposted 
			FROM #tmpAccountList t 
				INNER JOIN dbo.tblGlAcctHdr h ON t.AcctId = h.AcctId 
				INNER JOIN dbo.tblGlJrnl d ON h.AcctId = d.AcctId 
			WHERE [Year] = @YearFrom AND d.Period < @PeriodFrom AND d.PostedYn = 0 AND h.BalType <> 0 
			GROUP BY d.AcctID, h.BalType
		) d ON t.AcctID = d.AcctID

	/* build period/year temp table */
	INSERT INTO #tempPdYear (Period, [Year]) 
	SELECT p.GlPeriod, p.GlYear 
	FROM dbo.tblSmPeriodConversion p 
	WHERE (p.GlYear * 1000) + p.GlPeriod 
		BETWEEN (@YearFrom * 1000) + @PeriodFrom AND (@YearThru * 1000) + @PeriodThru

	/* add closing period to period/year temp table when necessary */
	DECLARE @Year int
	SET @Year = @YearFrom
	WHILE @Year <= @YearThru
	BEGIN
		IF (@YearThru > @Year) OR (@YearThru = @Year) AND (@PeriodThru > @PeriodsPerYear)
		BEGIN
			INSERT INTO #tempPdYear (Period, [Year]) 
			VALUES (@PeriodsPerYear + 1, @Year)
		END
		SET @Year = @Year + 1
	END

	/* Build a list of Active Accounts with Transaction totals from Jrnl */
	INSERT INTO #temp2 (AcctId, SumOfDebitAmt, SumOfCreditAmt) 
	SELECT t.AcctId, SUM(DebitAmtFgn), SUM(CreditAmtFgn) 
	FROM #temp1 t 
		INNER JOIN tblGlJrnl j (NOLOCK) ON j.AcctID = t.AcctID 
		INNER JOIN #tempPdYear p ON j.[Year] = p.[Year] AND j.Period = p.Period 
	WHERE j.Period <> 0 AND SourceCode BETWEEN @SourceCodeFrom AND @SourceCodeThru 
	GROUP BY t.AcctID

	/* delete inactive account records in #temp1 */
	IF @PrintInactive = 0
	BEGIN
		DELETE #temp1 
		WHERE AcctId NOT IN (SELECT AcctId FROM #temp2)
	END
	ELSE
	BEGIN
		--delete zero balance account  records in #temp1
		--	can only include/exclude zero balances for inactive accounts
		IF @IncludeZeroBalance = 0
		BEGIN
			--delete inactive accounts with zero balances */
			DELETE #temp1 
			WHERE SumOfActual = 0 AND AcctId NOT IN (SELECT AcctId FROM #temp2)
		END
	END

	INSERT INTO #temp3 (AcctId, Period, [Year], SumOfActual, Adjustment) 
	SELECT t.AcctId, p.Period, p.[Year], t.SumOfActual, 0 
	FROM #tempPdYear p, #temp1 t

	IF @SearchMissingEntries = 1
	BEGIN
		INSERT INTO #temp4 (AcctId, Period, [Year], AcctBalAmt) 
		SELECT t.AcctId, d.Period, d.[Year], SUM(Actual) 
		FROM #temp1 t, tblGlAcctDtl d (NOLOCK), #tempPdYear p 
		WHERE t.AcctID = d.AcctID AND d.[Year] = p.[Year] AND d.Period = p.Period 
		GROUP BY t.AcctID, d.Period, d.[Year]

		INSERT INTO #temp5 (AcctId, Period, [Year], JrnlBalAmt) 
		SELECT t.AcctId, j.Period, j.[Year]
			, CASE WHEN BalType >= 0 THEN SUM(DebitAmtFgn) - SUM(CreditAmtFgn) 
				ELSE SUM(CreditAmtFgn) - SUM(DebitAmtFgn) END 
		FROM #temp1 t 
			INNER JOIN tblGlJrnl j (NOLOCK) ON t.AcctId = j.AcctId 
			INNER JOIN #tempPdYear p ON j.[Year] = p.[Year] AND j.Period = p.Period 
		WHERE  j.PostedYn = -1 
		GROUP BY t.AcctID, t.BalType, j.Period, j.[Year]

		UPDATE #temp3 
		SET Adjustment = ISNULL(AcctBalAmt, 0) - ISNULL(JrnlBalAmt, 0)
		FROM #temp4 LEFT JOIN #temp5 ON #temp4.AcctID = #temp5.AcctID AND #temp4.[Year] = #temp5.[Year] AND #temp4.Period = #temp5.Period
		WHERE #temp3.AcctID = #temp4.AcctID AND #temp3.[Year] = #temp4.[Year] AND #temp3.Period = #temp4.Period
	END

	--build the sort order field list
	SET @SortString = 'h.AcctId'
	IF @SortOrder <> ''
	BEGIN
		SET @SortString = ''
	
		WHILE CHARINDEX(',', @SortOrder) <> 0
		BEGIN
			SET @ctr = CHARINDEX(',', @SortOrder)
			IF LEN(@SortString) > 0 SET @SortString = @SortString + ' + '
			SET @SortString = @SortString + 'h.Segment' + SUBSTRING(@SortOrder, 1, @ctr - 1)
			SET @SortOrder = RIGHT(@SortOrder,LEN(@SortOrder) - @ctr )
		END
		SET @SortString = @SortString + ' + h.Segment' + @SortOrder
	END

	--build a list of dynamically defined sort values
	CREATE TABLE #SortValue(AcctId pGlAcct, SortOrder nvarchar(MAX))

	SET @sql = 'INSERT INTO #SortValue (AcctId, SortOrder)'
		+ ' SELECT h.AcctId, ' + @SortString
		+ ' FROM dbo.trav_GlAccountHeader_view h (NOLOCK)'
		+ ' INNER JOIN #tmpAccountList t ON h.AcctId = t.AcctId'
	EXECUTE (@sql)

	SELECT 0 AS RecType, t.[Year], s.SortOrder
		, t.AcctId HdrAcctID, h.[Desc] AS AcctDesc, t.Period, EntryNum, EntryDate, TransDate
		, CASE WHEN h.BalType < 0 THEN -SumOfActual ELSE SumOfActual END AS Actual
		, ISNUll(DebitAmtFgn,0) DebitAmt1, ISNUll(CreditAmtFgn,0) CreditAmt1
		, CASE WHEN h.BalType < 0 THEN -Adjustment ELSE Adjustment END AS Adjustment
		, PostedYn, j.[Desc], Reference, SourceCode, AllocateYn
		, ChkRecon, CashFlow, h.BalType
		, CASE WHEN h.BalType < 0 THEN -Adjustment ELSE Adjustment END 
			+ (ISNUll(DebitAmtFgn, 0) - ISNUll(CreditAmtFgn, 0)) AS Amount
		, ISNUll(DebitAmtFgn, 0) - ISNUll(CreditAmtFgn, 0) AS AdjustedAmount 
	FROM dbo.tblGlAcctHdr h (NOLOCK) 
		INNER JOIN #temp3 t ON h.AcctId = t.AcctId 
		INNER JOIN #SortValue s ON h.AcctId = s.AcctId 
		INNER JOIN #tempPdYear p ON t.[Year] = p.[Year] AND t.Period = p.Period 
		LEFT JOIN 
		(
			SELECT AcctId, j.Period, j.[Year], EntryNum, EntryDate, TransDate, DebitAmtFgn, CreditAmtFgn
				, PostedYn, [Desc], Reference, SourceCode, ChkRecon, CashFlow, AllocateYn 
			FROM dbo.tblGlJrnl j (NOLOCK) 
				INNER JOIN #tempPdYear p ON j.[Year] = p.[Year] AND j.Period = p.Period 
			WHERE (SourceCode IS NULL OR SourceCode BETWEEN @SourceCodeFrom AND @SourceCodeThru)
		) j ON t.AcctId = j.AcctId AND t.[Year] = j.[Year] AND t.Period = j.Period 
	WHERE t.Adjustment = 0

	UNION ALL

	SELECT 1 AS RecType, t.[Year], s.SortOrder
		, t.AcctId HdrAcctID, h.[Desc] AS AcctDesc, t.Period, NULL AS EntryNum, NULL AS EntryDate, NULL AS TransDate
		, CASE WHEN h.BalType < 0 THEN -SumOfActual ELSE SumOfActual END AS Actual
		, 0 AS DebitAmt1, 0 AS CreditAmt1
		, CASE WHEN h.BalType < 0 THEN -Adjustment ELSE Adjustment END AS Adjustment
		, NULL AS PostedYn, NULL AS [Desc], NULL AS Reference, NULL AS SourceCode, NULL AS AllocateYn
		, NULL AS ChkRecon, NULL AS CashFlow, h.BalType
		, CASE WHEN h.BalType < 0 THEN -Adjustment ELSE Adjustment END AS Amount
		, 0 AS AdjustedAmount 
	FROM dbo.tblGlAcctHdr h (NOLOCK) 
		INNER JOIN #temp3 t ON h.AcctId = t.AcctId 
		INNER JOIN #SortValue s ON h.AcctId = s.AcctId 
		INNER JOIN #tempPdYear p ON t.[Year] = p.[Year] AND t.Period = p.Period 
	WHERE t.Adjustment <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlActivityReportRunningBalance_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlActivityReportRunningBalance_proc';

