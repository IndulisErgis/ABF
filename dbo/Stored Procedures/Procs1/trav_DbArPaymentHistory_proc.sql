
CREATE PROCEDURE [dbo].[trav_DbArPaymentHistory_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime,
@InvcFinch pInvoiceNum = 'FIN CHRG',
@CustId pCustId = NULL
AS
BEGIN TRY
--PET:http://webfront:801/view.php?id=237636
--MOD:Finance Charge Enhancements

	SET NOCOUNT ON

	CREATE TABLE #ArPayments
	(
		CustId pCustID, 
		PaymentsPTD pDecimal, 
		PaymentsYTD pDecimal, 
		DiscountsPTD pDecimal, 
		DiscountsYTD pDecimal, 
		DaysToPay int, 
		NumPmts int
	)

	CREATE TABLE #ArAgingAnalysis
	(
		UnpaidFinChg pDecimal DEFAULT(0), 
		UnappliedCredit pDecimal DEFAULT(0), 
		CurrentBal pDecimal DEFAULT(0), 
		Bal3160 pDecimal DEFAULT(0), 
		Bal6190 pDecimal DEFAULT(0), 
		Bal91120 pDecimal DEFAULT(0), 
		BalOver120 pDecimal DEFAULT(0), 
		ActiveCust int, 
		PastDueCust int, 
		TotDue pDecimal DEFAULT(0)
	)
	CREATE TABLE #Aging
	(
		CustId pCustID,
		CustName nvarchar(255),		
		InvcNum pInvoiceNum, 
		InvcType nvarchar(10),
		CurrencyId pCurrency NULL, 
		ExchRate pDecimal NULL,  
		UnpaidFinch pDecimal DEFAULT(0), 
		UnApplCredit pDecimal DEFAULT(0), 
		CurAmtDue pDecimal DEFAULT(0), 
		BalAge1 pDecimal DEFAULT(0), 
		BalAge2 pDecimal DEFAULT(0), 
		BalAge3 pDecimal DEFAULT(0), 
		BalAge4 pDecimal DEFAULT(0), 
		UnpaidFinchFgn pDecimal DEFAULT(0), 
		UnApplCreditFgn pDecimal DEFAULT(0),
		CurAmtDueFgn pDecimal DEFAULT(0), 
		BalAge1Fgn pDecimal DEFAULT(0),
		BalAge2Fgn pDecimal DEFAULT(0),
		BalAge3Fgn pDecimal DEFAULT(0),
		BalAge4Fgn pDecimal DEFAULT(0)
	)
	
	DECLARE @FiscalYear smallint, @Period smallint, @EndPeriodDate datetime, @BegYearDate datetime, @DaysThisYear int
	DECLARE @TotDue pDecimal, @FinChgYTD pDecimal
	DECLARE @PaymentsPTD pDecimal, @PaymentsYTD pDecimal, @DiscountsPTD pDecimal, @DiscountsYTD pDecimal
	DECLARE @DaysToPay int, @NumPmts int
	DECLARE @TotSalesHist pDecimal

	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	SELECT @EndPeriodDate = EndDate 
	FROM dbo.tblSmPeriodConversion WHERE GlYear = @FiscalYear AND GlPeriod = @Period

	SELECT @BegYearDate = BegDate 
	FROM dbo.tblSmPeriodConversion WHERE GlYear = @FiscalYear AND GlPeriod = 1

	SET @DaysThisYear = DATEDIFF(dd, @BegYearDate, @EndPeriodDate) + 1


	/* ArAging */
	INSERT INTO #Aging(CustId, CustName, InvcNum, InvcType, CurrencyId, ExchRate, UnpaidFinch, UnApplCredit, CurAmtDue
		, BalAge1, BalAge2, BalAge3, BalAge4, UnpaidFinchFgn, UnapplCreditFgn, CurAmtDueFgn
		, BalAge1Fgn, BalAge2Fgn, BalAge3Fgn, BalAge4Fgn)
	EXEC trav_DbArCustAgedBalances_proc @WksDate, @InvcFinch, @WksDate, @CustId, @CustId, 0, 2, 1

	/*  ArAgingAnalysis  */
	INSERT INTO #ArAgingAnalysis(UnpaidFinChg, UnappliedCredit, CurrentBal
		, Bal3160, Bal6190, Bal91120, BalOver120,  TotDue) --ActiveCust, PastDueCust,
		SELECT ISNULL(SUM(UnpaidFinch),0) AS UnpaidFinChg, ISNULL(SUM(UnApplCredit),0) AS UnappliedCredit, ISNULL(SUM(CurAmtDue),0) AS CurrentBal
		, ISNULL(SUM(BalAge1),0) AS Bal3160, ISNULL(SUM(BalAge2),0) AS Bal6190, ISNULL(SUM(BalAge3),0) AS Bal91120, ISNULL(SUM(BalAge4),0) AS BalOver120
		, ISNULL(SUM(UnpaidFinch + CurAmtDue + BalAge1 + BalAge2 + BalAge3 + BalAge4 - UnApplCredit),0) AS TotDue 
	FROM dbo.#Aging a 
			LEFT JOIN 
			(
				SELECT CustId FROM dbo.tblArOpenInvoice WHERE RecType > 0 AND Status <> 4 GROUP BY CustId
			) t 
			ON a.CustId = t.CustId
			
	SELECT @TotDue = TotDue FROM #ArAgingAnalysis

	-- NOT USING THIS FIELD FOR FINAL DB VALUES
	/*  ArFinanceCharges  */
	SELECT @FinChgYTD = ISNULL(SUM(CASE WHEN @Foreign = 0 THEN FinchAmt ELSE FinchAmtFgn END), 0)
		FROM dbo.tblArHistFinch
		WHERE FiscalYear = @FiscalYear AND GLPeriod <= @Period 

	
	/*  ArPaymentHistory  */
	INSERT INTO #ArPayments (CustId, PaymentsPTD, PaymentsYTD, DiscountsPTD, DiscountsYTD, DaysToPay, NumPmts) 
	SELECT ISNULL(p.CustId, '') AS CustId
		, ISNULL(SUM(CASE WHEN GLPeriod = @Period THEN 
			(CASE WHEN @Foreign = 0 THEN ISNULL(PmtAmt, 0) ELSE ISNULL(PmtAmtFgn, 0) END) ELSE 0 END), 0) AS PaymentsPTD
		, ISNULL(SUM(CASE WHEN @Foreign = 0 THEN ISNULL(PmtAmt, 0) ELSE ISNULL(PmtAmtFgn, 0) END), 0) AS PaymentsYTD
		, ISNULL(SUM(CASE WHEN GLPeriod = @Period THEN 
			(CASE WHEN @Foreign = 0 THEN ISNULL(DiffDisc, 0) ELSE ISNULL(DiffDiscFgn, 0) END) ELSE 0 END), 0) AS DiscountsPTD
		, ISNULL(SUM(CASE WHEN @Foreign = 0 THEN ISNULL(DiffDisc, 0) ELSE ISNULL(DiffDiscFgn, 0) END), 0) AS DiscountsYTD
		, ISNULL(SUM(CASE WHEN p.PmtDate > h.InvcDate THEN DATEDIFF(dy, h.InvcDate, p.PmtDate) ELSE 0 END), 0) AS DaysToPay
		, ISNULL(SUM(CASE WHEN p.PmtAmtFgn > 0 THEN 1 ELSE 0 END), 0) AS NumPmts
	FROM dbo.tblArHistPmt p 
		LEFT JOIN 
		(SELECT CustId, InvcNum, MAX(InvcDate) AS [InvcDate] 
			FROM dbo.tblArHistHeader 
			WHERE FiscalYear = @FiscalYear AND GLPeriod <= @Period AND VoidYn =0
			GROUP BY CustId, InvcNum
		) h
	ON p.CustId = h.CustId AND p.InvcNum = h.InvcNum 
	WHERE p.VoidYn = 0 AND p.FiscalYear = @FiscalYear AND p.GLPeriod <= @Period
	GROUP BY p.CustId

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO #ArPayments (CustId, PaymentsPTD, PaymentsYTD, DiscountsPTD, DiscountsYTD, DaysToPay, NumPmts) 
		VALUES ('', 0, 0, 0, 0, 0, 0)
	END

	SELECT @PaymentsPTD = SUM(PaymentsPTD)
		, @PaymentsYTD = SUM(PaymentsYTD)
		, @DiscountsPTD = SUM(DiscountsPTD)
		, @DiscountsYTD = SUM(DiscountsYTD)
		, @DaysToPay = SUM(DaysToPay)
		, @NumPmts = SUM(NumPmts)
	FROM #ArPayments

	/*  ArSalesHistory  */
	SELECT @TotSalesHist = ROUND(ISNULL(SUM(
		CASE WHEN @Foreign = 0 
			THEN ((TaxSubtotal + NonTaxSubTotal + SalesTax + Freight + Misc) * SIGN(TransType)) 
			ELSE ((TaxSubtotalFgn + NonTaxSubTotalFgn + SalesTaxFgn + FreightFgn + MiscFgn) * SIGN(TransType)) 
			END), 0), @Prec)
	FROM dbo.tblArHistHeader 
	WHERE VoidYn = 0 AND FiscalYear = @FiscalYear AND GLPeriod <= @Period 


	-- return resultset
	SELECT CASE WHEN ISNULL(@NumPmts, 0) = 0 THEN 0.0 ELSE (CAST(ISNULL(@DaysToPay, 0) as decimal) / @NumPmts) END AS AvgDaysToPay
		, CASE WHEN ISNULL(@TotSalesHist, 0) = 0 
			THEN 0 ELSE (ISNULL(@TotDue, 0) / (@TotSalesHist / ISNULL(@DaysThisYear, 0))) END AS DaysSalesOutstanding
		, ISNULL(@DiscountsPTD, 0) AS DiscountsPTD
		, ISNULL(@DiscountsYTD, 0) AS DiscountsYTD
		, ISNULL(@PaymentsPTD, 0) AS PaymentsPTD
		, ISNULL(@PaymentsYTD, 0) AS PaymentsYTD
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArPaymentHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArPaymentHistory_proc';

