
CREATE PROCEDURE [dbo].[trav_ArHistoryAging_proc]


@FiscalYear smallint,
@GlPeriod smallint,
@CustIdFrom pCustId = NULL,
@CustIdThru pCustId = NULL,
@Foreign bit = 0 

AS
SET NOCOUNT ON
BEGIN TRY

      DECLARE @CutoffDate datetime, @Day1 datetime, @Day2 datetime, @Day3 datetime, @Day4 datetime
      DECLARE @MaxInvcAgingDate datetime, @MaxPmtAgingDate datetime

      CREATE TABLE #ArOpenInvoice 
      (
            CustId pCustId, RecType smallint, InvcNum pInvoiceNum, AgingDate datetime, AmountDue pDecimal default(0)
      ) 

      CREATE TABLE #ArInvoice
      (
            CustId pCustId, InvcNum pInvoiceNum, MinAgingDate datetime NULL, MaxRecType smallint, Unapplied pDecimal DEFAULT (0), AmtCurrent pDecimal DEFAULT (0), 
            AmtDue1 pDecimal DEFAULT (0), AmtDue2 pDecimal DEFAULT (0), AmtDue3 pDecimal DEFAULT (0), AmtDue4 pDecimal DEFAULT (0), PRIMARY KEY (CustId,InvcNum)
      )

      --get Transaction/Payment cutoff date from period conversion table (calc as last day of month for default)
      SELECT @CutoffDate = ISNULL(EndDate , DATEADD(DAY, 1, DATEADD(MONTH, -1, CAST(CAST(@GlPeriod AS nvarchar) + '/01/'+ CAST(@FiscalYear AS nvarchar) AS datetime))))
            FROM dbo.tblSmPeriodConversion WHERE GlYear = @FiscalYear AND GlPeriod = @GlPeriod

      --Set Aging dates based upon the cutoff date
      SELECT @Day1 = DATEADD(DAY, -30, @CutoffDate), @Day2 = DATEADD(DAY, -60, @CutoffDate), @Day3 = DATEADD(DAY, -90, @CutoffDate), @Day4 = DATEADD(DAY, -120, @CutoffDate)

      --Get invoices/Cash receipts
      INSERT INTO #ArOpenInvoice (CustId, RecType, InvcNum, AgingDate, AmountDue)
            SELECT CustId, TransType, InvcNum, InvcDate
                  , ISNULL(CASE WHEN @Foreign = 0 THEN SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax + Freight + Misc) 
                        ELSE SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn + FreightFgn + MiscFgn) END, 0)
                  FROM dbo.tblArHistHeader 
                  WHERE (InvcDate <= @CutoffDate) AND ((CustId BETWEEN @CustIdFrom AND @CustIdThru) OR (@CustIdFrom IS NULL OR @CustIdThru IS NULL))
                        AND NOT(CustId IS NULL) AND VoidYn = 0 --ignore 'misc' entries not associated with a customer

      --Get payments
      INSERT INTO #ArOpenInvoice (CustId, RecType, InvcNum, AgingDate, AmountDue)
            SELECT CustId, -2, InvcNum, PmtDate, ISNULL(CASE WHEN @Foreign = 0 THEN -(PmtAmt + DiffDisc - CalcGainLoss) ELSE -(PmtAmtFgn + DiffDiscFgn) END, 0)
              FROM dbo.tblArHistPmt 
              WHERE (PmtDate <= @CutoffDate) AND ((CustId BETWEEN @CustIdFrom AND @CustIdThru) OR (@CustIdFrom IS NULL OR @CustIdThru IS NULL))AND NOT(CustId IS NULL)  --ignore 'misc' entries not associated with a customer
				AND VoidYn = 0

      --build list of all non-zero balance invoices
      SELECT CustId, InvcNum, SUM(AmountDue) BalDue  INTO #TempCust FROM #ArOpenInvoice GROUP BY CustId, InvcNum 
      INSERT INTO #ArInvoice (CustId, InvcNum) SELECT CustId, InvcNum FROM #TempCust WHERE BalDue > 0 OR BalDue < 0


      --capture the max invoice and payment dates for calculating the MinAgingDates
      --used to force the value to be ignored.  Couldn't use a null as the warning message
      --prevented the report from working properly
      SELECT @MaxInvcAgingDate = MAX(AgingDate) FROM #ArOpenInvoice WHERE RecType = 1 AND NOT(AgingDate IS NULL)
      SELECT @MaxPmtAgingDate = MAX(AgingDate) FROM #ArOpenInvoice WHERE RecType <> 1 AND NOT(AgingDate IS NULL)
      SELECT @MaxInvcAgingDate = COALESCE(@MaxInvcAgingDate, GETDATE()), @MaxPmtAgingDate = COALESCE(@MaxPmtAgingDate, GETDATE())

      --process invoices/payments by Min aging date and max rec typ so that over payments on invoices are aged with the invoice
      UPDATE #ArInvoice 
            SET MinAgingDate = m.MinAgingDate, MaxRecType = m.MaxRecType
            FROM #ArInvoice 
            INNER JOIN (SELECT CustId, InvcNum, Max(RecType) MaxRecType, CASE WHEN Max(RecType) = 1 THEN Min(InvcDate) ELSE Min(PmtDate) END MinAgingDate
                        FROM (SELECT CustId, InvcNum, ISNULL(RecType, 1) RecType
                                    , CASE WHEN ISNULL(RecType, 1) = 1 THEN AgingDate ELSE @MaxInvcAgingDate END InvcDate --can't use Null to force the value to be ignored
                                    , Case When ISNULL(RecType, 1) <> 1 THEN AgingDate ELSE @MaxPmtAgingDate END PmtDate  --so subistute the absolute max
                                    FROM #ArOpenInvoice) d  GROUP BY CustId, InvcNum) m
            ON #ArInvoice.CustId = m.CustId AND #ArInvoice.InvcNum = m.InvcNum

      --separate amounts into aging buckets
      UPDATE #ArInvoice
            SET Unapplied = ISNULL(s.Unapplied, 0), AmtCurrent = ISNULL(s.AmtCurrent, 0)
                  , AmtDue1 = ISNULL(s.AmtDue1, 0), AmtDue2 = ISNULL(s.AmtDue2, 0), AmtDue3 = ISNULL(s.AmtDue3, 0), AmtDue4 = ISNULL(s.AmtDue4, 0)
            FROM #ArInvoice INNER JOIN (SELECT i.CustId, i.InvcNum, SUM(CASE WHEN i.maxrectype < 0 THEN o.AmountDue ELSE 0 END) Unapplied
                  , SUM(CASE WHEN i.maxrectype > 0 AND i.MinAgingDate > @Day1 THEN o.AmountDue ELSE 0 END) AmtCurrent
                  , SUM(CASE WHEN i.maxrectype > 0 AND i.MinAgingDate BETWEEN DateAdd(Day,1, @Day2) AND @Day1 THEN o.AmountDue ELSE 0 END) AmtDue1
                  , SUM(CASE WHEN i.maxrectype > 0 AND i.MinAgingDate BETWEEN DateAdd(Day,1, @Day3) AND @Day2 THEN o.AmountDue ELSE 0 END) AmtDue2
                  , SUM(CASE WHEN i.maxrectype > 0 AND i.MinAgingDate BETWEEN DateAdd(Day,1, @Day4) AND @Day3 THEN o.AmountDue ELSE 0 END) AmtDue3
                  , SUM(CASE WHEN i.maxrectype > 0 AND i.MinAgingDate <= @Day4  THEN o.AmountDue ELSE 0 END) AmtDue4
                  FROM #ArInvoice i INNER JOIN #ArOpenInvoice o ON i.CustId = o.CustId AND i.InvcNum = o.InvcNum
                  GROUP BY i.CustId, i.InvcNum) s
            ON #ArInvoice.CustId = s.CustId AND #ArInvoice.InvcNum = s.InvcNum

      --return totals via the #HistAging table
      INSERT INTO #HistAging (CustId, UnapplCredit, CurAmtDue, BalAge1, BalAge2, BalAge3, BalAge4)
            SELECT CASE WHEN @CustIdFrom IS NULL AND @CustIdThru IS NULL THEN '' ELSE CustId END CustId, SUM(ISNULL(Unapplied, 0)) UnapplCredit, SUM(ISNULL(AmtCurrent, 0)) CurAmtDue 
                  , SUM(ISNULL(AmtDue1, 0)) BalAge1, SUM(ISNULL(AmtDue2, 0)) BalAge2, SUM(ISNULL(AmtDue3, 0)) BalAge3, SUM(ISNULL(AmtDue4, 0)) BalAge4
            FROM #ArInvoice   GROUP BY CASE WHEN @CustIdFrom IS NULL AND @CustIdThru IS NULL THEN '' ELSE CustId END


END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArHistoryAging_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArHistoryAging_proc';

