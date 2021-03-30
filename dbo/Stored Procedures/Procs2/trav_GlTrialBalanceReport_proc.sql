
CREATE PROCEDURE dbo.trav_GlTrialBalanceReport_proc
@FiscalYear smallint = 2008,
@GlPeriod smallint = 12,
@SortOrder nvarchar(80) = '1,2,3',
@PrintByAccoutType bit = 0,
@PrintZeroBalance bit = 0,
@MultiCurrency bit = 1,
@BaseCurrency pCurrency = 'USD',
@BFRef int = 0, -- 0, Current Year; -1, Last Year;
@BFType tinyint = 2 -- 0, Budget; 1, Forecast; 2, Actual;
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @SortString nvarchar(255)
	DECLARE @ctr smallint
	DECLARE @ExchRate pDecimal
	DECLARE @CompID nvarchar(3)
	DECLARE @sql nvarchar(max)

	CREATE TABLE #AcctInfo
	(
		SortOrder1 pGlAcct Null,
		SortOrder2 pGlAcct Null,
		AcctId pGlAcct Null,
		YTDActual pCurrDecimal Null,
		YTDDFBudget pCurrDecimal Null,
		YTDDFForecast pCurrDecimal Null,
		AcctTypeId smallint null
	)

	SET @sql = ''
	SET @CompID  = LEFT(DB_NAME(), 3)

	IF (@BFRef = -1)
		SET @FiscalYear = @FiscalYear - 1

	INSERT INTO #AcctInfo (AcctId, YTDActual, YTDDFBudget, YTDDFForecast, AcctTypeId)
	SELECT h.AcctId, SUM(h.ActualBase)  ActualBase, SUM(ISNULL(b.YTDDFBudget, 0)) YTDDFBudget, SUM(ISNULL(f.YTDDFForecast, 0)) YTDDFForecast, h.AcctTypeId
	FROM 
		(SELECT h.AcctId, SUM(ISNULL(d.ActualBase,0)) ActualBase, h.AcctTypeId 
		 FROM #tmpAccountList m INNER JOIN dbo.tblGlAcctHdr h ON m.AcctId = h.AcctId 
			LEFT JOIN (SELECT AcctId, ActualBase FROM dbo.tblGlAcctDtl WHERE [Year] = @FiscalYear AND Period <= @GlPeriod) d ON h.AcctId = d.AcctId
		 WHERE  h.AcctTypeId < 900
		 GROUP BY h.AcctId, h.AcctTypeId) h 
		LEFT JOIN 
			(SELECT dbf.AcctID,SUM(ISNULL(dbf.Amount, 0)) AS YTDDFBudget 
			 FROM dbo.tblGlAcctDtlBudFrcst dbf INNER JOIN  #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef
				 INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef
			 WHERE t.BFType = 0 AND dbf.BFRef = @BFRef AND c.CompID = @CompID AND dbf.GlYear = @FiscalYear 
				 AND dbf.GlPeriod <= @GlPeriod
			 GROUP BY dbf.AcctId) b ON h.AcctId = b.AcctId
		LEFT JOIN 
			(SELECT dbf.AcctID, SUM(ISNULL(dbf.Amount, 0)) AS YTDDFForecast
			 FROM dbo.tblGlAcctDtlBudFrcst dbf  INNER JOIN  #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef
				 INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef
			 WHERE abs(t.BFType) = 1 AND dbf.BFRef = @BFRef AND c.CompID = @CompID AND dbf.GlYear = @FiscalYear 
				 AND dbf.GlPeriod <= @GlPeriod
			 GROUP BY dbf.AcctId) f ON h.AcctId = f.AcctId
	GROUP BY h.AcctId, h.AcctTypeId
	
	SET @SortString = 'h.AcctId'
	IF @SortOrder <> ''
	BEGIN
		SET @SortString = ''
	
		WHILE CHARINDEX(',',@SortOrder) <> 0
		BEGIN
			SET @ctr = CHARINDEX(',',@SortOrder)
			IF LEN(@SortString) > 0 SET @SortString = @SortString + ' + '
			SET @SortString = @SortString + 'h.Segment' + SUBSTRING(@SortOrder, 1, @ctr - 1)
			SET @SortOrder = RIGHT(@SortOrder,LEN(@SortOrder) - @ctr )
		END
		SET @SortString = @SortString + ' + h.Segment' + @SortOrder
	END

	--pack the AcctTypeId with 0's for proper numeric sorting of report
	SET @sql = 'Update #AcctInfo SET SortOrder1 = CASE WHEN ' + str(@PrintByAccoutType) + ' = 1 THEN Right(Replicate(nchar(48), 6) + CAST(#AcctInfo.AcctTypeId AS nvarchar), 6) ELSE ' 
	SET @sql = @sql + @SortString + ' END, SortOrder2 = ' + @SortString
	SET @sql = @sql + ' FROM #AcctInfo INNER JOIN dbo.trav_GlAccountHeader_view h ON #AcctInfo.AcctId = h.AcctId'

	EXECUTE (@sql)

	IF @MultiCurrency = 1
	BEGIN
		SELECT i.SortOrder1, i.SortOrder2, h.AcctId, h.[Desc], h.AcctTypeId, t.[Desc] AcctTypeDesc, @FiscalYear AS [Year], @GlPeriod AS Period
			, CASE WHEN h.BalType * YTDActual > 0 THEN h.BalType * YTDActual ELSE 0 END AS YTDActualDebit
			, CASE WHEN h.BalType * YTDActual < 0 THEN -h.BalType * YTDActual ELSE 0 END AS YTDActualCredit
			, CASE WHEN h.BalType * YTDDFBudget > 0 THEN h.BalType * YTDDFBudget ELSE 0 END/ISNULL(e.ExchRate,1) AS YTDBudgetDebit
			, CASE WHEN h.BalType * YTDDFBudget < 0 THEN -h.BalType * YTDDFBudget ELSE 0 END/ISNULL(e.ExchRate,1) AS YTDBudgetCredit
			, CASE WHEN h.BalType * YTDDFForecast > 0 THEN h.BalType * YTDDFForecast ELSE 0 END/ISNULL(e.ExchRate,1) AS YTDForecastDebit
			, CASE WHEN h.BalType * YTDDFForecast < 0 THEN -h.BalType * YTDDFForecast ELSE 0 END/ISNULL(e.ExchRate,1) AS YTDForecastCredit
			, CASE WHEN h.Baltype * ISNULL(d.ActualBase,0) > 0 THEN h.Baltype * ISNULL(d.ActualBase,0) ELSE 0 END AS ActualDebit
			, CASE WHEN h.BalType * ISNULL(d.ActualBase,0) < 0 THEN -h.BalType * ISNULL(d.ActualBase,0) ELSE 0 END AS ActualCredit
			, CASE WHEN h.BalType * ISNULL(b.DFBudget,0) > 0 THEN h.BalType * ISNULL(b.DFBudget,0) ELSE 0 END/ISNULL(e.ExchRate,1) AS BudgetDebit
			, CASE WHEN h.BalType * ISNULL(b.DFBudget,0) < 0 THEN -h.BalType * ISNULL(b.DFBudget,0) ELSE 0 END/ISNULL(e.ExchRate,1) AS BudgetCredit
			, CASE WHEN h.BalType * ISNULL(f.DFForecast,0) > 0 THEN h.BalType * ISNULL(f.DFForecast,0) ELSE 0 END/ISNULL(e.ExchRate,1) AS ForecastDebit
			, CASE WHEN h.BalType * ISNULL(f.DFForecast,0) < 0 THEN -h.BalType * ISNULL(f.DFForecast,0) ELSE 0 END/ISNULL(e.ExchRate,1) AS ForecastCredit
		FROM dbo.tblGlAcctHdr h LEFT JOIN (SELECT AcctId, ActualBase FROM dbo.tblGlAcctDtl WHERE [Year] = @FiscalYear AND Period = @GlPeriod) d ON h.AcctId = d.AcctId
			INNER JOIN dbo.tblGlAcctType t ON h.AcctTypeId = t.AcctTypeId
			INNER JOIN #AcctInfo i ON h.AcctId = i.AcctId 
			LEFT JOIN #tmpSmExchRateYrPd e ON e.FiscalYear = @FiscalYear AND e.GlPeriod = @GlPeriod AND h.CurrencyId = e.CurrencyTo AND h.CurrencyId <> @BaseCurrency
			LEFT JOIN 
				(SELECT dbf.AcctID, GlPeriod, SUM(ISNULL(dbf.Amount, 0)) AS DFForecast
				 FROM dbo.tblGlAcctDtlBudFrcst dbf INNER JOIN  #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef 
					INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef   
				 WHERE t.BFType = 1 AND dbf.BFRef = @BFRef AND dbf.GlYear = @FiscalYear AND
					c.CompID = @CompID AND dbf.GlPeriod <= @GlPeriod 
				 GROUP BY  dbf.AcctID, GlPeriod
				) f	ON h.AcctId = f.AcctId  AND f.GlPeriod = @GlPeriod
			LEFT JOIN 
				(SELECT dbf.AcctID, GlPeriod, SUM(ISNULL(dbf.Amount, 0)) AS DFBudget
				 FROM dbo.tblGlAcctDtlBudFrcst dbf INNER JOIN  #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef 
					INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef   
				 WHERE t.BFType = 0 AND dbf.BFRef = @BFRef AND dbf.GlYear = @FiscalYear AND
					c.CompID =  @CompID  AND dbf.GlPeriod <= @GlPeriod 
				 GROUP BY  dbf.AcctID, GlPeriod
				) b	ON h.AcctId = b.AcctId AND b.GlPeriod = @GlPeriod
		WHERE CASE WHEN @PrintZeroBalance <> 0 THEN 1 ELSE CASE @BFType
						WHEN 1 THEN ABS(ISNULL(f.DFForecast, 0)) + ABS(YTDDFForecast) 
						WHEN 0 THEN ABS(ISNULL(b.DFBudget, 0)) + ABS(YTDDFBudget)
						ELSE ABS(ISNULL(d.ActualBase, 0)) + ABS(YTDActual)
						END
					END <> 0 --conditionally add criteria to filter out zero balance accounts
	END
	ELSE
	BEGIN
		SELECT i.SortOrder1, i.SortOrder2, h.AcctId, h.[Desc], h.AcctTypeId, t.[Desc] AcctTypeDesc
			, @FiscalYear  AS [Year], @GlPeriod AS Period
			, CASE WHEN h.BalType * YTDActual > 0 THEN h.BalType * YTDActual ELSE 0 END AS YTDActualDebit
			, CASE WHEN h.BalType * YTDActual < 0 THEN -h.BalType * YTDActual ELSE 0 END AS YTDActualCredit
			, CASE WHEN h.BalType * YTDDFBudget > 0 THEN h.BalType * YTDDFBudget ELSE 0 END AS YTDBudgetDebit
			, CASE WHEN h.BalType * YTDDFBudget < 0 THEN -h.BalType * YTDDFBudget ELSE 0 END AS YTDBudgetCredit
			, CASE WHEN h.BalType * YTDDFForecast > 0 THEN h.BalType * YTDDFForecast ELSE 0 END AS YTDForecastDebit
			, CASE WHEN h.BalType * YTDDFForecast < 0 THEN -h.BalType * YTDDFForecast ELSE 0 END AS YTDForecastCredit
			, CASE WHEN h.Baltype * ISNULL(d.Actual,0) > 0 THEN h.Baltype * ISNULL(d.Actual,0) ELSE 0 END AS ActualDebit
			, CASE WHEN h.BalType * ISNULL(d.Actual,0) < 0 THEN -h.BalType * ISNULL(d.Actual,0) ELSE 0 END AS ActualCredit
			, CASE WHEN h.BalType * ISNULL(b.DFBudget,0) > 0 THEN h.BalType * ISNULL(b.DFBudget,0) ELSE 0 END AS BudgetDebit
			, CASE WHEN h.BalType * ISNULL(b.DFBudget,0) < 0 THEN -h.BalType * ISNULL(b.DFBudget,0) ELSE 0 END AS BudgetCredit
			, CASE WHEN h.BalType * ISNULL(f.DFForecast,0) > 0 THEN h.BalType * ISNULL(f.DFForecast,0) ELSE 0 END AS ForecastDebit
			, CASE WHEN h.BalType * ISNULL(f.DFForecast,0) < 0 THEN -h.BalType * ISNULL(f.DFForecast,0) ELSE 0 END AS ForecastCredit
		FROM dbo.tblGlAcctHdr h LEFT JOIN (SELECT AcctId, Actual FROM dbo.tblGlAcctDtl WHERE [Year] = @FiscalYear AND Period = @GlPeriod) d ON h.AcctId = d.AcctId
			INNER JOIN dbo.tblGlAcctType t ON h.AcctTypeId = t.AcctTypeId
			INNER JOIN #AcctInfo i ON h.AcctId = i.AcctId 
			LEFT JOIN 
				(SELECT dbf.AcctID, GlPeriod, SUM(ISNULL(dbf.Amount, 0)) AS DFForecast
				 FROM dbo.tblGlAcctDtlBudFrcst dbf INNER JOIN #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef 
					INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef   
				 WHERE t.BFType = 1 AND dbf.BFRef = @BFRef AND dbf.GlYear = @FiscalYear AND
					c.CompID = @CompID AND dbf.GlPeriod <= @GlPeriod 
				 GROUP BY  dbf.AcctID, GlPeriod
				) f  ON h.AcctId = f.AcctId  AND f.GlPeriod = @GlPeriod
			LEFT JOIN 
				(SELECT dbf.AcctID, GlPeriod, SUM(ISNULL(dbf.Amount, 0)) AS DFBudget
				 FROM dbo.tblGlAcctDtlBudFrcst dbf INNER JOIN  #tmpGLBudFrcstDescr t ON dbf.BFRef  = t.BFRef 
					INNER JOIN #tmpGLBudFrcstComp c ON dbf.BFRef = c.BFRef   
				 WHERE t.BFType = 0 AND dbf.BFRef = @BFRef AND dbf.GlYear = @FiscalYear AND
					c.CompID =  @CompID  AND dbf.GlPeriod <= @GlPeriod 
				 GROUP BY  dbf.AcctID, GlPeriod
				) b ON h.AcctId = b.AcctId AND b.GlPeriod = @GlPeriod
		WHERE CASE WHEN @PrintZeroBalance <> 0 THEN 1 
				ELSE CASE @BFType
					WHEN 1 THEN ABS(ISNULL(f.DFForecast, 0)) + ABS(YTDDFForecast) 
					WHEN 0 THEN ABS(ISNULL(b.DFBudget, 0)) + ABS(YTDDFBudget)
					ELSE ABS(ISNULL(d.Actual, 0)) + ABS(YTDActual)
					END
				END <> 0--conditionally add criteria to filter out zero balance accounts
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlTrialBalanceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlTrialBalanceReport_proc';

