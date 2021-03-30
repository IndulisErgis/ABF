
CREATE PROCEDURE dbo.trav_ArCustomerAnalysisReport_proc

@FiscalYear Int,
@FiscalPeriod Int,
@PrintFor tinyint,
@IncludeYTDTotals bit,
@PrintPeriods int,
@IncludeLastYearTotals bit

AS
BEGIN TRY

	DECLARE @sql nvarchar(max)

	IF (@PrintFor = 0)
	BEGIN
	SELECT d.FiscalYear, d.GlPeriod, c.CustId, c.CustName, c.Addr1, c.City, c.Region, c.Country, c.PostalCode, c.Phone
		, c.Fax, c.SalesRepId1, c.DistCode, c.CreditLimit, c.CurrencyId, c.FirstSaleDate, c.LastSaleDate
		, [NewFinch] + [UnpaidFinch] + [CurAmtDue] + [BalAge1] + [BalAge2] + [BalAge3] + [BalAge4] - [UnapplCredit] AS BalanceDue
		, t.DiscPct, t.DiscDays, t.NetDueDays, d.Sales AS Sales, d.Cogs AS Cogs, d.Profit AS Profit, d.NumInvc AS NumInvc, d.Finch AS FinChrg
		, d.Pmt AS Payments, d.Disc AS Discounts, d.NumPmt AS NumPmt, d.DaysToPay AS DaysToPay, b.CurrencyBalDue AS CurrencyBalanceDue 
	FROM dbo.tblArCust c 
		INNER JOIN #tmpCustomerList tmp ON tmp.CustId = c.CustId
		INNER JOIN dbo.tblArTermsCode t ON t.TermsCode = c.TermsCode 
		INNER JOIN 
			( 	SELECT CustID, FiscalYear, GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit, SUM(NumInvc) AS NumInvc
				, SUM(Finch) AS Finch, SUM(Pmt) AS Pmt, SUM(Disc) AS Disc, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
				FROM (
					SELECT CustID, FiscalYear, GlPeriod, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
					FROM dbo.trav_ArCustomerHistory_view

					UNION ALL

					SELECT CustId, FiscalYear, GlPeriod, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
					FROM dbo.trav_ArCustomerHistoryOffset_view ) o 

				WHERE FiscalYear = @FiscalYear AND (GlPeriod = @FiscalPeriod OR @FiscalPeriod = 999) 
	 			GROUP BY CustId, Fiscalyear, GlPeriod

				UNION ALL

				SELECT CustID, FiscalYear, 9998 AS GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit, SUM(NumInvc) AS NumInvc
					, SUM(Finch) AS Finch, SUM(Pmt) AS Pmt, SUM(Disc) AS Disc, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
				FROM ( 
					SELECT CustID, FiscalYear, GlPeriod, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
					FROM dbo.trav_ArCustomerHistory_view

					UNION ALL

					SELECT CustId, FiscalYear, GlPeriod, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
					FROM dbo.trav_ArCustomerHistoryOffset_view ) o 

				WHERE FiscalYear = @FiscalYear AND @IncludeYTDTotals = 1 
				GROUP BY CustId, Fiscalyear

				UNION ALL

				SELECT CustID, FiscalYear, 9999 AS GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit, SUM(NumInvc) AS NumInvc
					, SUM(Finch) AS Finch, SUM(Pmt) AS Pmt, SUM(Disc) AS Disc, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
				FROM ( 
					SELECT CustID, FiscalYear, GlPeriod, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
					FROM dbo.trav_ArCustomerHistory_view

					UNION ALL

					SELECT CustId, FiscalYear, GlPeriod, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
					FROM dbo.trav_ArCustomerHistoryOffset_view ) o 

				WHERE FiscalYear = @FiscalYear - 1 AND @IncludeYTDTotals = 1 
				GROUP BY CustId, Fiscalyear
			) d ON c.CustID = d.CustID 

		INNER JOIN 
			(
				SELECT CurrencyId, SUM([NewFinch] + [UnpaidFinch] + [CurAmtDue] + [BalAge1] + [BalAge2] + [BalAge3] + [BalAge4] - [UnapplCredit]) AS CurrencyBalDue 
				FROM dbo.tblArCust c INNER JOIN #tmpCustomerList tmp ON tmp.CustId = c.CustId
				GROUP BY CurrencyId
			) b ON c.CurrencyId = b.CurrencyId  -- capture the total balance by currency id for report totals
		ORDER BY d.GlPeriod
	END

	ELSE
	BEGIN
	SELECT d.FiscalYear, d.GlPeriod, c.CustId, c.CustName, c.Addr1, c.City, c.Region, c.Country, c.PostalCode
		, c.Phone, c.Fax, c.SalesRepId1, c.DistCode, c.CreditLimit, c.CurrencyId, c.FirstSaleDate, c.LastSaleDate
		, [NewFinch] + [UnpaidFinch] + [CurAmtDue] + [BalAge1] + [BalAge2] + [BalAge3] + [BalAge4] - [UnapplCredit] AS BalanceDue
		, t.DiscPct, t.DiscDays, t.NetDueDays, d.Sales AS Sales,d.Cogs AS Cogs, d.Profit AS Profit, d.NumInvc AS NumInvc, d.Finch AS FinChrg
		, d.Pmt AS Payments, d.Disc AS Discounts, d.NumPmt AS NumPmt, d.DaysToPay AS DaysToPay, b.CurrencyBalDue AS CurrencyBalanceDue 
	FROM dbo.tblArCust c 
		INNER JOIN #tmpCustomerList tmp ON tmp.CustId = c.CustId
		INNER JOIN  dbo.tblArTermsCode t ON t.TermsCode = c.TermsCode
		INNER JOIN 
		(
			SELECT CustID, FiscalYear, GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit, SUM(NumInvc) AS NumInvc
				, SUM(Finch) AS Finch, SUM(Pmt) AS Pmt, SUM(Disc) AS Disc, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
			FROM 
			  ( SELECT CustID, FiscalYear, GlPeriod, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
				FROM dbo.trav_ArCustomerHistory_view

				UNION ALL

				SELECT SoldToId AS CustId, FiscalYear, GlPeriod, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
				FROM dbo.trav_ArCustomerHistoryOffset_view ) o 
			WHERE FiscalYear = @FiscalYear AND (GlPeriod = @FiscalPeriod OR @FiscalPeriod = 999) 
			GROUP BY CustId, Fiscalyear, GlPeriod

			UNION ALL

			SELECT CustID, FiscalYear, 9998 AS GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit, SUM(NumInvc) AS NumInvc
				, SUM(Finch) AS Finch, SUM(Pmt) AS Pmt, SUM(Disc) AS Disc, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
			FROM 
			  ( SELECT CustID, FiscalYear, GlPeriod, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
				FROM dbo.trav_ArCustomerHistory_view

				UNION ALL

				SELECT SoldToId AS CustId, FiscalYear, GlPeriod, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
				FROM dbo.trav_ArCustomerHistoryOffset_view ) o 
			WHERE FiscalYear = @FiscalYear AND @IncludeYTDTotals = 1 
			GROUP BY CustId, Fiscalyear

			UNION ALL

			SELECT CustID, FiscalYear, 9999 AS GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit, SUM(NumInvc) AS NumInvc
				, SUM(Finch) AS Finch, SUM(Pmt) AS Pmt, SUM(Disc) AS Disc, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
			FROM 
			  ( SELECT CustID, FiscalYear, GlPeriod, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
				FROM dbo.trav_ArCustomerHistory_view

				UNION ALL

				SELECT SoldToId AS CustId, FiscalYear, GlPeriod, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
				FROM dbo.trav_ArCustomerHistoryOffset_view ) o 
			WHERE FiscalYear = @FiscalYear - 1 AND @IncludeYTDTotals = 1 
			GROUP BY CustId, Fiscalyear
		) d ON c.CustID = d.CustID 
		INNER JOIN 
		(	SELECT CurrencyId, SUM([NewFinch] + [UnpaidFinch] + [CurAmtDue] + [BalAge1] + [BalAge2] + [BalAge3] + [BalAge4] - [UnapplCredit]) AS CurrencyBalDue 
			FROM dbo.tblArCust c INNER JOIN #tmpCustomerList tmp ON tmp.CustId = c.CustId
			GROUP BY CurrencyId
		) b ON c.CurrencyId = b.CurrencyId  -- capture the total balance by currency id for report totals
	ORDER BY d.GlPeriod
	END

	-- Data for Customer Analysis total
	SET @sql = ''

	IF @PrintPeriods <> 2
	BEGIN
		SET @sql = @sql + 'SELECT CurrencyId, GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit, SUM(NumInvc) AS NumInvc
			, SUM(Finch) AS FinChrg, SUM(Pmt) AS Payments, SUM(Disc) AS Discounts, SUM(NumPmt) AS NumPmt, SUM(DaysToPay)AS DaysToPay 
			FROM dbo.tblArCust c 
			INNER JOIN #tmpCustomerList tmp ON tmp.CustId = c.CustId
			INNER JOIN 
				( SELECT '
					IF @PrintFor = 0 SET @sql = @sql + 'CustId, '
					IF @PrintFor = 1 SET @sql = @sql + 'SoldToId AS CustId, '
					SET @sql = @sql + 'GlPeriod, FiscalYear
					, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc
					, 0 AS Finch, 0 AS pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
				FROM dbo.trav_ArCustomerHistoryOffset_view 
				UNION ALL 
				SELECT CustId, GlPeriod, FiscalYear, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
				FROM dbo.trav_ArCustomerHistory_view 
			  ) o ON o.CustId = c.CustId 
			WHERE ((FiscalYear) = ' + CAST(@FiscalYear AS nvarchar(4)) + ') '
			IF @PrintPeriods = 0 SET @sql = @sql + 'AND ((GLPeriod) = ' + CAST(@FiscalPeriod AS nvarchar(3)) + ') '
			SET @sql = @sql + ' GROUP BY CurrencyId, GlPeriod'
	END

	IF @IncludeYTDTotals = 1
	BEGIN
		IF @PrintPeriods <> 2 SET @sql = @sql + ' UNION ALL '
		SET @sql = @sql + 'SELECT CurrencyId, 9998 AS GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit
			, SUM(NumInvc) AS NumInvc, SUM(Finch) AS FinChrg, SUM(Pmt) AS Payments, SUM(Disc) AS Discounts
			, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
			FROM dbo.tblArCust c 
			INNER JOIN #tmpCustomerList tmp ON tmp.CustId = c.CustId
			INNER JOIN 
			  ( SELECT '
					IF @PrintFor = 0 SET @sql = @sql + 'CustId, '
					IF @PrintFor = 1 SET @sql = @sql + 'SoldToId AS CustId, '
					SET @sql = @sql + 'FiscalYear, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc
					, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
				FROM dbo.trav_ArCustomerHistoryOffset_view 
				UNION ALL 
				SELECT CustId, FiscalYear, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
				FROM dbo.trav_ArCustomerHistory_view 
			 ) o ON o.CustId = c.CustId 
			WHERE ((FiscalYear) = ' + CAST(@FiscalYear AS nvarchar(4)) + ') 
			GROUP BY CurrencyId'
	END

	IF @IncludeLastYearTotals = 1
	BEGIN
		IF @PrintPeriods <> 2 OR @IncludeYTDTotals = 1 SET @sql = @sql + ' UNION ALL '
		SET @sql = @sql + 'SELECT CurrencyId, 9999 AS GlPeriod, SUM(Sales) AS Sales, SUM(Cogs) AS Cogs, SUM(Profit) AS Profit
			, SUM(NumInvc) AS NumInvc, SUM(Finch) AS FinChrg, SUM(Pmt) AS Payments, SUM(Disc) AS Discounts
			, SUM(NumPmt) AS NumPmt, SUM(DaysToPay) AS DaysToPay 
			FROM dbo.tblArCust c 
			INNER JOIN #tmpCustomerList tmp ON tmp.CustId = c.CustId
			INNER JOIN 
				(
				SELECT '
				IF @PrintFor = 0 SET @sql = @sql + 'CustId, '
				IF @PrintFor = 1 SET @sql = @sql + 'SoldToId AS CustId, '
				SET @sql = @sql + 'FiscalYear, -Sales AS Sales, -Cogs AS Cogs, -Profit AS Profit, -NumInvc AS NumInvc
				, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
				FROM dbo.trav_ArCustomerHistoryOffset_view 
				UNION ALL 
				SELECT CustId, FiscalYear, Sales, Cogs, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
				FROM dbo.trav_ArCustomerHistory_view
				) o ON o.CustId = c.CustId 
			WHERE ((FiscalYear) = ' + CAST((@FiscalYear - 1) AS nvarchar(4)) + ') 
			GROUP BY CurrencyId'
	END

	IF @sql <> '' EXECUTE (@sql)
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerAnalysisReport_proc';

