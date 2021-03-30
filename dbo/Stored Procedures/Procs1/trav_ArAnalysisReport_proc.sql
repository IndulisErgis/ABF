
CREATE PROCEDURE [dbo].[trav_ArAnalysisReport_proc]

@GlPeriod smallint,
@FiscalYear smallint,
@CurPdDays smallint,
@PeriodsPerYr smallint

AS
SET NOCOUNT ON
BEGIN TRY

      DECLARE @CompId nvarchar(3), @curPeriods cursor, @tmpPeriod smallint, @tmpYear smallint, @tmpDays smallint
      DECLARE @PdId smallint, @Rcount smallint -- 1=current/2=current - 1/3=current - 2/4=Last year

      --build temp tables for gathering results
      CREATE TABLE #HistAging
        (
            PdId smallint DEFAULT 0, FiscalYear smallint DEFAULT 0, GlPeriod smallint DEFAULT 0, Days smallint DEFAULT 0,
            CustId pCustId Null, UnapplCredit pDecimal DEFAULT 0, CurAmtDue pDecimal DEFAULT 0,
            BalAge1 pDecimal DEFAULT 0, BalAge2 pDecimal DEFAULT 0, BalAge3 pDecimal DEFAULT 0, BalAge4 pDecimal DEFAULT 0
        )

      CREATE TABLE #Results
        (
            PdTotSales pDecimal DEFAULT 0, PdTotCogs pDecimal DEFAULT 0, PdNumInvc int DEFAULT 0, PdTotDisc pDecimal DEFAULT 0, PdNumPmt int DEFAULT 0, 
            PdTotDaysToPay int DEFAULT 0, PdUnpaidFinch pDecimal DEFAULT 0, PdCurAmtDue pDecimal DEFAULT 0, PdBalAge1 pDecimal DEFAULT 0,
            PdBalAge2 pDecimal DEFAULT 0, PdBalAge3 pDecimal DEFAULT 0, PdBalAge4 pDecimal DEFAULT 0, PdDays smallint DEFAULT 0,

            PdPriorTotSales pDecimal DEFAULT 0, PdPriorTotCogs pDecimal DEFAULT 0, PdPriorNumInvc int DEFAULT 0, PdPriorTotDisc pDecimal DEFAULT 0, 
            PdPriorNumPmt int DEFAULT 0, PdPriorTotDaysToPay int DEFAULT 0, PdPriorUnpaidFinch pDecimal DEFAULT 0, PdPriorCurAmtDue pDecimal DEFAULT 0,
            PdPriorBalAge1 pDecimal DEFAULT 0, PdPriorBalAge2 pDecimal DEFAULT 0, PdPriorBalAge3 pDecimal DEFAULT 0, PdPriorBalAge4 pDecimal DEFAULT 0, PdPriorDays smallint DEFAULT 0,

            PdLyTotSales pDecimal DEFAULT 0, PdLyTotCogs pDecimal DEFAULT 0, PdLyNumInvc int DEFAULT 0, PdLyTotDisc pDecimal DEFAULT 0,  PdLyNumPmt int DEFAULT 0, 
            PdLyTotDaysToPay int DEFAULT 0, PdLyUnpaidFinch pDecimal DEFAULT 0, PdLyCurAmtDue pDecimal DEFAULT 0, PdLyBalAge1 pDecimal DEFAULT 0,
            PdLyBalAge2 pDecimal DEFAULT 0, PdLyBalAge3 pDecimal DEFAULT 0, PdLyBalAge4 pDecimal DEFAULT 0, PdLyDays smallint DEFAULT 0,

            PdAvgTotSales pDecimal DEFAULT 0, PdAvgTotCogs pDecimal DEFAULT 0, PdAvgNumInvc int DEFAULT 0, PdAvgTotDisc pDecimal DEFAULT 0, PdAvgNumPmt int DEFAULT 0, 
            PdAvgTotDaysToPay int DEFAULT 0, PdAvgUnpaidFinch pDecimal DEFAULT 0, PdAvgCurAmtDue pDecimal DEFAULT 0, PdAvgBalAge1 pDecimal DEFAULT 0,
            PdAvgBalAge2 pDecimal DEFAULT 0, PdAvgBalAge3 pDecimal DEFAULT 0, PdAvgBalAge4 pDecimal DEFAULT 0, PdAvgDays smallint DEFAULT 0,
        )

      --capture the company id
      SELECT @CompId = DB_Name()

      --capture the 'current year' three periods to work with
      --    Use a cursor to loop through periods to call qryArHistoryAging - inserting results into work table
      SET @curPeriods = CURSOR STATIC FOR 
            SELECT TOP 3 GlYear, GlPeriod, DATEDIFF(DAY, BegDate, EndDate) + 1 [Days] FROM dbo.tblSmPeriodConversion 
                  WHERE (((GlPeriod <= @GlPeriod) AND (GlYear = @FiscalYear)) OR (GlYear < @FiscalYear))AND GlPeriod <= @PeriodsPerYr
                  ORDER BY GlYear DESC, GlPeriod DESC

            --initialize counter to track the periods
            SET @PdId = 1
            OPEN  @curPeriods
            IF @@Cursor_Rows <> 0
            BEGIN
                  FETCH NEXT FROM @curPeriods   INTO @tmpYear, @tmpPeriod, @tmpDays
                  WHILE (@@FETCH_STATUS = 0)
                  BEGIN
                        --get historical aging for given period and year
                        EXEC dbo.trav_ArHistoryAging_proc @tmpYear, @tmpPeriod, NULL, NULL, 0

                        IF EXISTS(SELECT * FROM #HistAging WHERE PdId = 0)
                        BEGIN
                              --update the PdId for the created record
                              UPDATE #HistAging 
                                    SET PdId = @PdId, FiscalYear = @tmpYear, GlPeriod = @tmpPeriod, [Days] = CASE WHEN @PdId = 1 THEN @CurPdDays ELSE @tmpDays END
                              WHERE PdId = 0                
                        END
                        ELSE
                        BEGIN
                              --add a record if none created
                              INSERT INTO #HistAging (PdId, FiscalYear, GlPeriod, [Days]) VALUES ( @PdId, @tmpYear, @tmpPeriod, CASE WHEN @PdId = 1 THEN @CurPdDays ELSE @tmpDays END )
                        END

                        --increment the PdId tracking variable
                        SELECT @PdId = @PdId + 1
                        FETCH NEXT FROM @curPeriods   INTO @tmpYear, @tmpPeriod, @tmpDays
                  END

                  CLOSE @curPeriods
            END
            DEALLOCATE @curPeriods

      --capture the 'last year' period to work with - get historical aging for given last year
      --    Use @GlPeriod and @FiscalYear - 1 for last year values
      SELECT @tmpYear = @FiscalYear - 1
      EXEC dbo.trav_ArHistoryAging_proc @tmpYear, @GlPeriod, NULL, NULL, 0

      IF EXISTS(SELECT * FROM #HistAging WHERE PdId = 0)
      BEGIN
            --update the PdId for the created record
            UPDATE #HistAging
                  SET PdId = 4, FiscalYear = @tmpYear, GlPeriod = @GlPeriod, [Days] = (SELECT DATEDIFF(DAY, BegDate, EndDate) + 1 [Days] FROM dbo.tblSmPeriodConversion 
                        WHERE GlPeriod = @GlPeriod AND GlYear = @tmpYear)
            WHERE PdId = 0
      END
      ELSE
      BEGIN
            --add a record if none created
            INSERT INTO #HistAging (PdId, FiscalYear, GlPeriod, [Days]) VALUES (@PdId, @tmpYear, @tmpPeriod, CASE WHEN @PdId = 1 THEN @CurPdDays ELSE @tmpDays END)
      END

      --pet 43228 - include UnapplCredit in BalAge4
      UPDATE #HistAging SET BalAge4 = ISNULL(BalAge4, 0) + ISNULL(UnapplCredit, 0)

      --build the calculatd results for the report
      --Current period (initial insert)
      INSERT INTO #Results(PdCurAmtDue, PdBalAge1, PdBalAge2, PdBalAge3, PdBalAge4, PdDays)
            SELECT ISNULL(a.CurAmtDue, 0), ISNULL(a.BalAge1, 0), ISNULL(a.BalAge2, 0), ISNULL(a.BalAge3, 0), ISNULL(a.BalAge4, 0), ISNULL(a.[Days], 0)
            FROM #HistAging a WHERE a.PdId = 1

      --update from histheader
      UPDATE #Results SET PdTotSales = ISNULL(h.TotSales, 0), PdTotCogs = ISNULL(h.TotCogs, 0), PdNumInvc = ISNULL(h.NumInvc, 0)
            FROM (SELECT SUM(SIGN(TransType)*(TaxSubtotal + NonTaxSubtotal)) TotSales,
                  SUM(SIGN(TransType)* TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc
            FROM dbo.tblArHistHeader dh INNER JOIN #HistAging t   ON dh.FiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
            WHERE t.PdID=1 AND VoidYn = 0) H

      --update from pmthist
      UPDATE #Results SET PdTotDisc = ISNULL(h.TotDisc, 0), PdNumPmt = ISNULL(h.NumPmt, 0), PdTotDaysToPay = ISNULL(h.TotDaysToPay, 0)
            FROM (SELECT SUM(TotDisc) TotDisc, SUM(NUmPmt) NumPmt, SUM(TotDaysToPay) TotDaysToPay
                  FROM dbo.trav_ArPmtHistSumbyCust p INNER JOIN #HistAging t ON p.FiscalYear = t.FiscalYear AND p.SumHistPeriod = t.GlPeriod
                  WHERE t.PdID=1 GROUP BY p.FiscalYear, p.SumHistPeriod) H

      --update from histFinch
      UPDATE #Results SET PdUnpaidFinch = ISNULL(h.TotFinchAmt, 0)
            FROM (SELECT SUM(FinchAmt) TotFinchAmt
                  FROM dbo.tblArHistFinch dh inner join #HistAging t ON dh.fiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
                  WHERE t.PdID=1) H

      --Prior Period
      UPDATE #Results SET PdPriorCurAmtDue = ISNULL(a.CurAmtDue, 0), PdPriorBalAge1 = ISNULL(a.BalAge1, 0), PdPriorBalAge2 = ISNULL(a.BalAge2, 0),
             PdPriorBalAge3 = ISNULL(a.BalAge3, 0), PdPriorBalAge4 = ISNULL(a.BalAge4, 0), PdPriorDays = ISNULL(a.[Days], 0)
            FROM #HistAging a 
            WHERE a.PdId = 2

      UPDATE #Results SET PdPriorTotSales = ISNULL(h.TotSales, 0), PdPriorTotCogs = ISNULL(h.TotCogs, 0), PdPriorNumInvc = ISNULL(h.NumInvc, 0)
            FROM (SELECT SUM(SIGN(TransType)*(TaxSubtotal + NonTaxSubtotal)) TotSales,
              SUM(SIGN(TransType)*TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc
                  FROM dbo.tblArHistHeader dh inner join #HistAging t ON dh.FiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
                  WHERE t.PdID=2 AND VoidYn = 0) H

      UPDATE #Results SET PdPriorTotDisc = ISNULL(h.TotDisc, 0), PdPriorNumPmt = ISNULL(h.NumPmt, 0), PdPriorTotDaysToPay = ISNULL(h.TotDaysToPay, 0)
            FROM (SELECT SUM(TotDisc) TotDisc, SUM(NUmPmt) NumPmt, SUM(TotDaysToPay) TotDaysToPay
                  FROM dbo.trav_ArPmtHistSumbyCust p INNER JOIN #HistAging t ON p.FiscalYear = t.FiscalYear AND p.SumHistPeriod = t.GlPeriod
                  WHERE t.PdID=2 GROUP BY p.FiscalYear, p.SumHistPeriod) H

      UPDATE #Results SET PdPriorUnpaidFinch = ISNULL(h.TotFinchAmt, 0)
            FROM (SELECT SUM(FinchAmt) TotFinchAmt
                  FROM dbo.tblArHistFinch dh INNER JOIN #HistAging t ON dh.fiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
                  WHERE t.PdID=2) H

      --Last Year Current Period
      UPDATE #Results SET PdLyCurAmtDue = ISNULL(a.CurAmtDue, 0), PdLyBalAge1 = ISNULL(a.BalAge1, 0), PdLyBalAge2 = ISNULL(a.BalAge2, 0),
              PdLyBalAge3 = ISNULL(a.BalAge3, 0), PdLyBalAge4 = ISNULL(a.BalAge4, 0), PdLyDays = ISNULL(a.[Days], 0)
            FROM #HistAging a
            WHERE a.PdId = 4

      UPDATE #Results SET PdLyTotSales = ISNULL(h.TotSales, 0), PdLyTotCogs = ISNULL(h.TotCogs, 0), PdLyNumInvc = ISNULL(h.NumInvc, 0)
            FROM (SELECT SUM(SIGN(TransType)*(TaxSubtotal + NonTaxSubtotal)) TotSales,
              SUM(SIGN(TransType)* TotCost) TotCogs, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc
                  FROM dbo.tblArHistHeader dh INNER JOIN #HistAging t ON dh.FiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
                  WHERE t.PdID=4 AND VoidYn = 0) H

      UPDATE #Results SET PdLyTotDisc = ISNULL(h.TotDisc, 0), PdLyNumPmt = ISNULL(h.NumPmt, 0), PdLyTotDaysToPay = ISNULL(h.TotDaysToPay, 0)
            FROM (SELECT SUM(TotDisc) TotDisc, SUM(NUmPmt) NumPmt, SUM(TotDaysToPay) TotDaysToPay
                  FROM dbo.trav_ArPmtHistSumbyCust p INNER JOIN #HistAging t ON p.FiscalYear = t.FiscalYear AND p.SumHistPeriod = t.GlPeriod
                  WHERE t.PdID=4 GROUP BY p.FiscalYear, p.SumHistPeriod) H

      UPDATE #Results SET PdLyUnpaidFinch = ISNULL(h.TotFinchAmt, 0)
            FROM (SELECT SUM(FinchAmt) TotFinchAmt
                  FROM dbo.tblArHistFinch dh INNER JOIN #HistAging t ON dh.fiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
                  WHERE t.PdID=4) H

      --3 period average (current / -1 / -2) --protect against division by zero
      IF ISNULL((SELECT PdDays + PdPriorDays + (SELECT Days FROM #HistAging WHERE PdId = 3) FROM #Results), 0) > 0 
      BEGIN
            SELECT @tmpDays = Days FROM #HistAging WHERE PdId = 3

            UPDATE #Results SET PdAvgCurAmtDue = ISNULL((((PdCurAmtDue * PdDays) + (PdPriorCurAmtDue * PdPriorDays) + (a.CurAmtDue * a.[Days])) / (PdDays + PdPriorDays + a.[Days])), 0)
            , PdAvgBalAge1 = ISNULL((((PdBalAge1 * PdDays) + (PdPriorBalAge1 * PdPriorDays) + (a.BalAge1 * a.[Days])) / (PdDays + PdPriorDays + a.[Days])), 0)
            , PdAvgBalAge2 = ISNULL((((PdBalAge2 * PdDays) + (PdPriorBalAge2 * PdPriorDays) + (a.BalAge2 * a.[Days])) / (PdDays + PdPriorDays + a.[Days])), 0)
            , PdAvgBalAge3 = ISNULL((((PdBalAge3 * PdDays) + (PdPriorBalAge3 * PdPriorDays) + (a.BalAge3 * a.[Days])) / (PdDays + PdPriorDays + a.[Days])), 0)
            , PdAvgBalAge4 = ISNULL((((PdBalAge4 * PdDays) + (PdPriorBalAge4 * PdPriorDays) + (a.BalAge4 * a.[Days])) / (PdDays + PdPriorDays + a.[Days])), 0)
            , PdAvgDays = ISNULL((PdDays + PdPriorDays + a.[Days]) / 3, 0)
            FROM #HistAging a WHERE a.PdId = 3

            UPDATE #Results SET PdAvgTotSales = ISNULL((((PdTotSales * PdDays) + (PdPriorTotSales * PdPriorDays) + (h.TotSales * @tmpDays)) / (PdDays + PdPriorDays + @tmpDays)), 0)
            , PdAvgTotCogs = ISNULL((((PdTotCogs * PdDays) + (PdPriorTotCogs * PdPriorDays) + (h.TotCogs * @tmpDays)) / (PdDays + PdPriorDays + @tmpDays)), 0)
            , PdAvgNumInvc = ISNULL((((PdNumInvc * PdDays) + (PdPriorNumInvc * PdPriorDays) + (h.NumInvc * @tmpDays)) / (PdDays + PdPriorDays + @tmpDays)), 0)
            FROM (SELECT SUM(SIGN(TransType)*(TaxSubtotal + NonTaxSubtotal)) TotSales, SUM(SIGN(TransType)* TotCost) TotCogs,
                    SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END) NumInvc
                  FROM dbo.tblArHistHeader dh INNER JOIN #HistAging t ON dh.FiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
                  WHERE t.PdID=3 AND VoidYn = 0) H
            
            UPDATE #Results SET PdAvgTotDisc = ISNULL((((PdTotDisc * PdDays) + (PdPriorTotDisc * PdPriorDays) + (h.TotDisc * @tmpDays)) / (PdDays + PdPriorDays + @tmpDays)), 0)
            , PdAvgNumPmt = ISNULL((((PdNumPmt * PdDays) + (PdPriorNumPmt * PdPriorDays) + (h.NumPmt * @tmpDays)) / (PdDays + PdPriorDays + @tmpDays)), 0)
            , PdAvgTotDaysToPay = ISNULL((((PdTotDaysToPay * PdDays) + (PdPriorTotDaysToPay * PdPriorDays) + (h.TotDaysToPay * @tmpDays)) / (PdDays + PdPriorDays + @tmpDays)), 0)
            FROM (SELECT SUM(TotDisc) TotDisc, SUM(NUmPmt) NumPmt, SUM(TotDaysToPay) TotDaysToPay
                        FROM dbo.trav_ArPmtHistSumbyCust p INNER JOIN #HistAging t ON p.FiscalYear = t.FiscalYear AND p.SumHistPeriod = t.GlPeriod
                        WHERE t.PdID=3 GROUP BY p.FiscalYear, p.SumHistPeriod) H
            
            UPDATE #Results SET PdAvgUnpaidFinch = ISNULL((((PdUnpaidFinch * PdDays) + (PdPriorUnpaidFinch * PdPriorDays) + (h.TotFinchAmt * @tmpDays)) / (PdDays + PdPriorDays + @tmpDays)), 0)
            FROM (SELECT SUM(FinchAmt) TotFinchAmt
                        FROM dbo.tblArHistFinch dh INNER JOIN #HistAging t ON dh.fiscalYear = t.FiscalYear AND dh.GlPeriod = t.GlPeriod
                        WHERE t.PdID=3) H
      END

      --return the single record resultset
      SELECT * FROM #Results

END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAnalysisReport_proc';

