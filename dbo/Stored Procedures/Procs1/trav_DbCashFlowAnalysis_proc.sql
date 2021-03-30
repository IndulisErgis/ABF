
CREATE PROCEDURE [dbo].[trav_DbCashFlowAnalysis_proc]
@UnappliedCreditsYn bit = 1, 
@Prec tinyint = 2, 
@Foreign bit = 0, 
@InvcFinch pInvoiceNum = 'FIN CHRG',
@DateToday datetime =null

AS
BEGIN TRY
--MOD:Finance Charge Enhancements

      SET NOCOUNT ON

      CREATE TABLE #ArOpenInvc
      (
            CustId pCustId, 
            InvcNum pInvoiceNum, 
            FirstOfDueDate datetime, 
            Amount pDecimal, 
            MaxOfRecType smallint
      )

      CREATE TABLE #ArInflow
      (
            UnpaidFinch pDecimal DEFAULT(0), 
            UnApplCredit pDecimal DEFAULT(0),
            InflowToday pDecimal DEFAULT(0),
            InflowWeek1 pDecimal DEFAULT(0),
            InflowWeek2 pDecimal DEFAULT(0),
            InflowWeek3 pDecimal DEFAULT(0),
            InflowWeek4 pDecimal DEFAULT(0),
            InflowWeek5 pDecimal DEFAULT(0),
            InflowWeek6 pDecimal DEFAULT(0),
            InflowFuture pDecimal DEFAULT(0), 
            InflowTotal pDecimal DEFAULT(0)
      )

      CREATE TABLE #ApOpenInvc
      (
            VendorID pVendorId, 
            NetDueDate datetime,
            GrossAmountDue pDecimal
      )

      CREATE TABLE #ApOutflow
      (
            OutflowToday pDecimal, 
            OutflowWeek1 pDecimal,
            OutflowWeek2 pDecimal, 
            OutflowWeek3 pDecimal,
            OutflowWeek4 pDecimal, 
            OutflowWeek5 pDecimal,
            OutflowWeek6 pDecimal, 
            OutflowFuture pDecimal, 
            OutflowTotal pDecimal
      )

      CREATE TABLE #GlAccountDetail
      (
            BeginCashBal pDecimal DEFAULT (0)
      )

      DECLARE 
      --@DateToday datetime, 
      @GlYear smallint, 
      @GlPeriod smallint, 
      @BeginWeek1 datetime, 
      @EndWeek1 datetime, 
      @BeginWeek2 datetime, 
      @EndWeek2 datetime, 
      @BeginWeek3 datetime, 
      @EndWeek3 datetime, 
      @BeginWeek4 datetime, 
      @EndWeek4 datetime, 
      @BeginWeek5 datetime, 
      @EndWeek5 datetime, 
      @BeginWeek6 datetime, 
      @EndWeek6 datetime, 
      @DateFuture datetime

      --SELECT @DateToday = CONVERT(varchar(8), GETDATE(), 112)
      SELECT @BeginWeek1 = DATEADD(day, 1, @DateToday)
      SELECT @EndWeek1 = DATEADD(week, 1, @DateToday)
      SELECT @BeginWeek2 = DATEADD(day, 8, @DateToday)
      SELECT @EndWeek2 = DATEADD(week, 2, @DateToday)
      SELECT @BeginWeek3 = DATEADD(day, 15, @DateToday)
      SELECT @EndWeek3 = DATEADD(week, 3, @DateToday)
      SELECT @BeginWeek4 = DATEADD(day, 22, @DateToday)
      SELECT @EndWeek4 = DATEADD(week, 4, @DateToday)
      SELECT @BeginWeek5 = DATEADD(day, 29, @DateToday)
      SELECT @EndWeek5 = DATEADD(week, 5, @DateToday)
      SELECT @BeginWeek6 = DATEADD(day, 36, @DateToday)
      SELECT @EndWeek6 = DATEADD(week, 6, @DateToday)
      SELECT @DateFuture = DATEADD(day, 43, @DateToday)

      SELECT @GlYear = GlYear, @GlPeriod = GlPeriod
      FROM dbo.tblSmPeriodConversion 
      WHERE @DateToday BETWEEN BegDate AND EndDate

      INSERT INTO #ArOpenInvc (CustId, InvcNum, MaxOfRecType, FirstOfDueDate, Amount)
      SELECT CustId, InvcNum, MAX(RecType) MaxOfRecType
                  , CASE WHEN MAX(RecType) > 0 THEN MIN(TransDate) ELSE MIN(PmtDate) END FirstOfDueDate
                  , SUM(SIGN(RecType) * Amt) Amount 
            FROM (SELECT i.CustId, i.InvcNum, i.RecType, CASE WHEN i.NetDueDate IS NULL THEN 0 ELSE Amt END Amt
                  , CASE WHEN i.RecType > 0 THEN i.NetDueDate ELSE NULL END TransDate
                  , CASE WHEN i.RecType < 0 THEN i.NetDueDate ELSE NULL END PmtDate
                  FROM dbo.tblArOpenInvoice i INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId
                  WHERE c.AcctType = 0 AND i.Status <> 4
                  ) d
            GROUP BY CustId, InvcNum
      IF @@ROWCOUNT = 0
      BEGIN
            INSERT INTO #ArOpenInvc (CustId, InvcNum, MaxOfRecType, FirstOfDueDate, Amount)
                  VALUES ('', '', 0, '', 0)
      END

      INSERT INTO #ArInflow (UnpaidFinch, UnApplCredit, InflowToday, InflowWeek1, InflowWeek2, InflowWeek3, InflowWeek4, InflowWeek5, InflowWeek6, InflowFuture, InflowTotal)
            SELECT      ROUND(SUM(CASE WHEN MaxOfRecType = 4 THEN Amount ELSE 0 END), @Prec) AS UnpaidFinch
                  , ROUND(SUM(CASE WHEN (MaxOfRecType < 0 AND @UnappliedCreditsYn <> 1) THEN Amount ELSE 0 END), @Prec) AS UnApplCredit
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate <= @DateToday) THEN Amount ELSE 0 END), @Prec) AS InflowToday
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate BETWEEN @BeginWeek1 AND @EndWeek1) THEN Amount ELSE 0 END), @Prec) AS InflowWeek1
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate BETWEEN @BeginWeek2 AND @EndWeek2) THEN Amount ELSE 0 END), @Prec) AS InflowWeek2
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate BETWEEN @BeginWeek3 AND @EndWeek3) THEN Amount ELSE 0 END), @Prec) AS InflowWeek3
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate BETWEEN @BeginWeek4 AND @EndWeek4) THEN Amount ELSE 0 END), @Prec) AS InflowWeek4
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate BETWEEN @BeginWeek5 AND @EndWeek5) THEN Amount ELSE 0 END), @Prec) AS InflowWeek5
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate BETWEEN @BeginWeek6 AND @EndWeek6) THEN Amount ELSE 0 END), @Prec) AS InflowWeek6
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) AND (FirstOfDueDate >= @DateFuture) THEN Amount ELSE 0 END), @Prec) AS InflowFuture
                  , ROUND(SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND (MaxOfRecType <> 4) THEN Amount ELSE 0 END), @Prec) AS InflowTotal
            FROM #ArOpenInvc 

      IF @@ROWCOUNT = 0
      BEGIN
            INSERT INTO #ArInflow (UnpaidFinch, UnApplCredit, InflowToday, InflowWeek1, InflowWeek2, InflowWeek3, InflowWeek4, InflowWeek5, InflowWeek6, InflowFuture, InflowTotal)
                  VALUES (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
      END

      UPDATE #ArInflow SET #ArInflow.UnpaidFinch = ROUND(#ArInflow.UnpaidFinch + ISNULL(c.UnpaidFinch, 0), @Prec)
            , #ArInflow.UnApplCredit = ROUND(#ArInflow.UnApplCredit + ISNULL(c.UnApplCredit, 0), @Prec)
            , InflowToday = ROUND(InflowToday + ISNULL(c.BalDue, 0), @Prec)
            , InflowTotal = ROUND(InflowTotal + ISNULL(c.BalDue, 0), @Prec)
            FROM (SELECT SUM(UnpaidFinch) UnpaidFinch, SUM(UnApplCredit) AS UnApplCredit
                  , SUM(CurAmtDue + BalAge1 + BalAge2 + BalAge3 + BalAge4) AS BalDue            
                  FROM dbo.tblArCust c WHERE c.AcctType = 1) c

      INSERT INTO #ApOpenInvc (VendorID, NetDueDate, GrossAmountDue)
            SELECT VendorID, NetDueDate, 
                  ROUND(SUM(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END), @Prec) AS GrossAmountDue
            FROM dbo.tblApOpenInvoice WHERE Status NOT IN (3,4)
      GROUP BY VendorID, NetDueDate

      IF @@ROWCOUNT = 0
      BEGIN
            INSERT INTO #ApOpenInvc (VendorID, NetDueDate, GrossAmountDue)
                  VALUES ('', '', 0)
      END

      INSERT INTO #ApOutflow(OutflowToday, OutflowWeek1, OutflowWeek2, OutflowWeek3, OutflowWeek4, 
                  OutflowWeek5, OutflowWeek6, OutflowFuture, OutflowTotal)
            SELECT 
                  ROUND(SUM(CASE WHEN NetDueDate <= @DateToday THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowToday
                  , ROUND(SUM(CASE WHEN NetDueDate BETWEEN @BeginWeek1 AND @EndWeek1 THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowWeek1
                  , ROUND(SUM(CASE WHEN NetDueDate BETWEEN @BeginWeek2 AND @EndWeek2 THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowWeek2
                  , ROUND(SUM(CASE WHEN NetDueDate BETWEEN @BeginWeek3 AND @EndWeek3 THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowWeek3
                  , ROUND(SUM(CASE WHEN NetDueDate BETWEEN @BeginWeek4 AND @EndWeek4 THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowWeek4
                  , ROUND(SUM(CASE WHEN NetDueDate BETWEEN @BeginWeek5 AND @EndWeek5 THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowWeek5
                  , ROUND(SUM(CASE WHEN NetDueDate BETWEEN @BeginWeek6 AND @EndWeek6 THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowWeek6
                  , ROUND(SUM(CASE WHEN NetDueDate >= @DateFuture THEN GrossAmountDue ELSE 0 END), @Prec) AS OutflowFuture
                  , ROUND(SUM(GrossAmountDue), @Prec) AS OutflowTotal
            FROM #ApOpenInvc

      IF @@ROWCOUNT = 0
      BEGIN
            INSERT INTO #ApOutflow (OutflowToday, OutflowWeek1, OutflowWeek2, OutflowWeek3, OutflowWeek4, 
                  OutflowWeek5, OutflowWeek6, OutflowFuture, OutflowTotal)
                  VALUES (0, 0, 0, 0, 0, 0, 0, 0, 0)
      END

      INSERT INTO #GlAccountDetail (BeginCashBal) 
      SELECT ISNULl(SUM(CASE WHEN AcctTypeId IN (5,10) AND d.[Year] = @GlYear AND d.Period <= @GlPeriod THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Actual, 0) ELSE ISNULL(d.Actual, 0) END) ELSE 0 END),0) AS BeginCashBal 
      FROM dbo.tblGlAcctHdr h 
            LEFT JOIN dbo.tblGlAcctDtl d ON h.AcctId = d.AcctId 
      
      SELECT  (@DateToday) AS DateToday, (@EndWeek1) AS DateWeek1, (@EndWeek2) AS DateWeek2
            , (@EndWeek3) AS DateWeek3, (@EndWeek4) AS DateWeek4, (@EndWeek5) AS DateWeek5
            , (@EndWeek6) AS DateWeek6
            , InflowToday, InflowWeek1, InflowWeek2, InflowWeek3
            , InflowWeek4, InflowWeek5, InflowWeek6, InflowFuture
            , OutflowToday, OutflowWeek1, OutflowWeek2, OutflowWeek3
            , OutflowWeek4, OutflowWeek5, OutflowWeek6, OutflowFuture
            , ROUND(InflowToday - OutflowToday, @Prec) AS NetToday
            , ROUND(InflowWeek1 - OutflowWeek1, @Prec) AS NetWeek1
            , ROUND(InflowWeek2 - OutflowWeek2, @Prec) AS NetWeek2
            , ROUND(InflowWeek3 - OutflowWeek3, @Prec) AS NetWeek3
            , ROUND(InflowWeek4 - OutflowWeek4, @Prec) AS NetWeek4
            , ROUND(InflowWeek5 - OutflowWeek5, @Prec) AS NetWeek5
            , ROUND(InflowWeek6 - OutflowWeek6, @Prec) AS NetWeek6
            , ROUND(InflowFuture - OutflowFuture, @Prec) AS NetFuture
            , BeginCashBal AS BeginCashBal
            , ROUND(InflowTotal - OutflowTotal, @Prec) + BeginCashBal AS EndCashBal
      FROM #ArInflow, #ApOutflow, #GlAccountDetail
      
END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCashFlowAnalysis_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCashFlowAnalysis_proc';

