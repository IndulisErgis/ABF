
CREATE PROCEDURE [dbo].[trav_DbSummarySalesAndProfit_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Timeframe tinyint = 0, -- 0 =  Daily, 1 = Monthly, 2 = Yearly,
@Wksdate datetime =   null,
@DefaultBFRef int = null

AS
BEGIN TRY
  SET NOCOUNT ON
       DECLARE @FiscalYear smallint, @Period smallint
       DECLARE @BegPeriodDate datetime, @EndPeriodDate datetime, @DaysInPd smallint
       DECLARE @Tot pDecimal, @TotCost pDecimal, @Invc pDecimal, @InvcCost pDecimal, @SalesSum pDecimal, @ProfitSum pDecimal
       DECLARE @UnpostedCOGS pDecimal, @UnpostedSales pDecimal
       DECLARE @ActSales pDecimal, @ActCOGS pDecimal, @BudSales pDecimal, @BudCOGS pDecimal
       
       SELECT @FiscalYear = GlYear, @Period = GlPeriod 
       FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

       SELECT @BegPeriodDate = BegDate, @EndPeriodDate = EndDate 
       FROM dbo.tblSmPeriodConversion WHERE GlYear = @FiscalYear AND GlPeriod = @Period

       SET @DaysInPd = DATEDIFF(dd,@BegPeriodDate, @EndPeriodDate) + 1

       /*  SoStatistics  */
       
       SELECT @Tot = SUM((CASE TransType WHEN -1 THEN d.QtyOrdSell WHEN 4 THEN d.QtyShipSell WHEN 1 THEN d.QtyShipSell ELSE 0 END 
       * CASE @Foreign WHEN 0 THEN d.UnitPriceSell ELSE d.UnitPriceSellFgn END) 
                     * SIGN(TransType))
              , @TotCost = SUM((CASE TransType WHEN -1 THEN d.QtyOrdSell 
                           WHEN 4 THEN d.QtyShipSell WHEN 1 THEN d.QtyShipSell ELSE 0 END 
                     * CASE @Foreign WHEN 0 THEN d.UnitCostSell ELSE d.UnitCostSellFgn END) 
                     * SIGN(TransType)) 
       FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId 
       WHERE ((@Timeframe = 1 AND (FiscalYear = @FiscalYear AND GLPeriod = @Period))
              OR (@Timeframe = 2 AND (FiscalYear = @FiscalYear AND GLPeriod <= @Period))
              OR (InvcDate = @Wksdate))
              AND d.[Status] = 0 AND d.GrpId is null AND h.VoidYn = 0
       
       SELECT @Invc = ROUND(SUM(CASE WHEN TransType IN (1,-1) 
                     THEN (CASE @Foreign 
                           WHEN 0 THEN ((TaxSubtotal + NonTaxSubtotal) * SIGN(TransType)) 
                           ELSE ((TaxSubtotalFgn + NonTaxSubtotalFgn) * SIGN(TransType))END) 
                     ELSE 0 END), @Prec)
              , @InvcCost = ROUND(SUM(CASE WHEN TransType IN (1,-1) 
                     THEN (CASE @Foreign 
                           WHEN 0 THEN (TotCost * SIGN(TransType)) 
                           ELSE (TotCostFgn * SIGN(TransType))END) 
                     ELSE 0 END), @Prec) 
       FROM dbo.tblArTransHeader 
        WHERE ((@Timeframe = 1 AND (FiscalYear = @FiscalYear AND GLPeriod = @Period))
              OR (@Timeframe = 2 AND (FiscalYear = @FiscalYear AND GLPeriod <= @Period))
              OR (InvcDate = @WksDate)) 
              AND VoidYn = 0

       SELECT @SalesSum = ROUND(SUM(ISNULL(@Tot, 0) + ISNULL(@Invc, 0)), @Prec)
              , @ProfitSum = ROUND(SUM(ISNULL(@TotCost, 0) + ISNULL(@InvcCost, 0)), @Prec)

       /*  GlJournal  */
       SELECT @UnpostedCOGS = ROUND(SUM(CASE WHEN PostedYn = 0 AND h.AcctTypeId = 600 
                     THEN (SIGN(BalType) * (DebitAmt - CreditAmt)) ELSE 0 END), @Prec)
              , @UnpostedSales = ROUND(SUM(CASE WHEN PostedYn = 0 AND h.AcctTypeId BETWEEN 500 AND 510 
                     THEN (SIGN(BalType) * (DebitAmt - CreditAmt)) ELSE 0 END), @Prec) 
       FROM dbo.tblGlJrnl j LEFT JOIN dbo.tblGlAcctHdr h ON j.AcctId = h.AcctId 
       WHERE (@Timeframe = 1 AND ([Year] = @FiscalYear AND Period = @Period))
       OR (@Timeframe = 2 AND ([Year] = @FiscalYear AND Period <= @Period))
       OR (TransDate = @WksDate) 
              
       /*  GlAccountDetail  */
       SELECT @ActSales = SUM(CASE WHEN h.AcctTypeId BETWEEN 500 AND 510 
              THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Actual, 0) ELSE ISNULL(d.Actual, 0) END) 
              ELSE 0 END)
       , @ActCOGS = SUM(CASE WHEN h.AcctTypeId = 600 
              THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Actual, 0) ELSE ISNULL(d.Actual, 0) END) 
              ELSE 0 END)
       , @BudSales = SUM(CASE WHEN h.AcctTypeId BETWEEN 500 AND 510 
              THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Budget, 0) ELSE ISNULL(d.Budget, 0) END) 
              ELSE 0 END)
       , @BudCOGS = SUM(CASE WHEN h.AcctTypeId = 600 
              THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Budget, 0) ELSE ISNULL(d.Budget, 0) END) 
              ELSE 0 END)
       FROM dbo.tblGlAcctHdr h 
       LEFT JOIN (
              SELECT [AcctId], [Year], [period], [Actual], 0 AS [Budget] FROM dbo.tblGlAcctDtl
              UNION ALL
              SELECT [AcctId], [GlYear], [GlPeriod], 0, [Amount] FROM dbo.tblGlAcctDtlBudFrcst WHERE BFRef = @DefaultBFRef
              ) d ON h.AcctId = d.AcctId 
       WHERE ((@Timeframe = 0 OR @Timeframe =1) AND (d.[Year]  = @FiscalYear AND d.[Period] = @Period))
              OR (@Timeframe = 2 AND (d.[Year]  = @FiscalYear AND d.[Period] <= @Period))


       SELECT @SalesSum = ISNULL(@SalesSum, 0), @ProfitSum = ISNULL(@ProfitSum, 0)
              , @UnpostedCOGS = ISNULL(@UnpostedCOGS, 0), @UnpostedSales = ISNULL(@UnpostedSales, 0)
              , @ActSales = ISNULL(@ActSales, 0), @ActCOGS = ISNULL(@ActCOGS, 0)
              , @BudSales = ISNULL(@BudSales, 0), @BudCOGS = ISNULL(@BudCOGS, 0)

       -- return resultset
       SELECT ISNULL((@UnpostedSales + CASE WHEN @Timeframe = 0 THEN 0 ELSE (@ActSales * -1) END + @SalesSum),0) AS ActSales
              , ISNULL(CASE WHEN @Timeframe = 0 THEN CASE WHEN @DaysInPd = 0 THEN 0 ELSE ((@BudSales * -1) / @DaysInPd) END 
                     ELSE (@BudSales * -1) END,0) AS BudSales
              , ISNULL(CASE WHEN @Timeframe = 0 THEN CASE WHEN @DaysInPd = 0 THEN 0 
                           ELSE ((@UnpostedSales + @SalesSum) - ((@BudSales * -1) / @DaysInPd)) END 
                     ELSE ((@UnpostedSales + (@ActSales * -1) + @SalesSum) - (@BudSales * -1)) END,0) AS SalesVariance
              , ISNULL(((@UnpostedSales + CASE WHEN @Timeframe = 0 THEN 0 
                           ELSE (@ActSales * -1) END + @SalesSum) - (@UnpostedCOGS + CASE WHEN @Timeframe = 0 THEN 0 
                     ELSE @ActCOGS END + @ProfitSum)) ,0)AS ActProfit
              , ISNULL(CASE WHEN @Timeframe = 0 THEN CASE WHEN @DaysInPd = 0 THEN 0 
                           ELSE (((@BudSales * -1) - @BudCOGS) / @DaysInPd) END 
                     ELSE ((@BudSales * -1) - @BudCOGS) END,0) AS BudProfit
              ,ISNULL( CASE WHEN @Timeframe = 0 THEN CASE WHEN @DaysInPd = 0 THEN 0 
                           ELSE (((@UnpostedSales + @SalesSum) - (@UnpostedCOGS + @ProfitSum)) 
                                  - (((@BudSales * -1) - @BudCOGS) / @DaysInPd)) END 
                     ELSE (((@UnpostedSales + (@ActSales * -1) + @SalesSum) - (@UnpostedCOGS + @ActCOGS + @ProfitSum)) 
                           - ((@BudSales * -1) - @BudCOGS)) END,0) AS ProfitVariance
END TRY
BEGIN CATCH
       EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummarySalesAndProfit_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummarySalesAndProfit_proc';

