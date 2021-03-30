

create PROCEDURE dbo.trav_DbArCustAgedBalances_proc
@CutoffDate datetime = '2011-08-31', -- Invoice cutoff date
@InvcFinch pInvoiceNum = 'FIN CHRG', -- Finance charge invoice number
@BaseAgingDate datetime = '2011-08-31', -- base date for the aging dates
@CustomerIdFrom pCustId = NULL, -- Customer ID From
@CustomerIdThru pCustId = NULL, -- Customer ID Thru
@UnappliedCreditsYn bit = 0, -- option to age unapplied payments
@BaseCurrPrec smallint = 2, -- base currency precision factor
@IncludeHeldYn bit = 1 -- option to include held invoices

AS
BEGIN TRY

	SET NOCOUNT ON

	DECLARE 
	@Age1 datetime, -- Aging date 1
	@Age2 datetime, -- Aging date 2
	@Age3 datetime, -- Aging date 3
	@Age4 datetime -- Aging date 4
	SELECT @Age1 = DATEADD(day, -30, @BaseAgingDate)
	SELECT @Age2 = DATEADD(day, -60, @BaseAgingDate)
	SELECT @Age3 = DATEADD(day, -90, @BaseAgingDate)
	SELECT @Age4 = DATEADD(day, -120, @BaseAgingDate)

	SELECT @CustomerIdFrom = COALESCE(@CustomerIdFrom, ''), @CustomerIdThru = COALESCE(@CustomerIdThru, REPLICATE('z', 20)) -- pack to 20 in case of expansion

	CREATE TABLE #OpenInvc
	(
		CustId pCustID,
		CustName nvarchar(255),
		CurrencyId pCurrency, 
		InvcNum pInvoiceNum, 
		InvcType nvarchar(10),
		FirstOfTransDate datetime, 
		Amount pDecimal, 
		AmountFgn pDecimal, 
		MaxOfRecType smallint
	)

	CREATE TABLE #TempGrp
	(
		CustId pCustID, 
		CustName nvarchar(255),
		CurrencyId pCurrency NULL, 
		InvcNum pInvoiceNum, 
		InvcType nvarchar(10),
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

-- Process Open Invoice type customers
--  sum invoices into #OpenInvc
--  include paid invoices so overpayments are aged instead of processed as unapplied credits
--  maintain trans AND pmt date for proper payment aging
--  optionally include held invoices
INSERT INTO #OpenInvc (CustId, CustName, CurrencyId, InvcNum, InvcType, MaxOfRecType, FirstOfTransDate, Amount, AmountFgn) 
	SELECT CustId, CustName, CurrencyId, InvcNum
		, CASE MAX(RecType) 
			WHEN 1 THEN 'Invoice' 
			WHEN 4 THEN 'Fin Charge' 
			--WHEN 5 THEN 'Pro Forma' 
			WHEN -1 THEN 'CREDIT' 
			WHEN -2 THEN 'PAYMENT' 
			WHEN -3 THEN 'Gain/Loss' END
		 , MAX(RecType) MaxOfRecType
		 ,(CONVERT(nvarchar(8),CASE WHEN MAX(RecType) > 0 THEN MIN(TransDate) ELSE MIN(PmtDate) END,112)) FirstOfTransDate
		, SUM(SIGN(RecType) * Amt)
		, SUM(SIGN(RecType) * AmtFgn) 
	FROM 
	(
		SELECT i.CustId, c.CustName, c.CurrencyId, i.InvcNum, i.RecType, Amt, AmtFgn
			, CASE WHEN i.RecType > 0 THEN i.TransDate ELSE NULL END TransDate
			, CASE WHEN i.RecType < 0 THEN i.TransDate ELSE NULL END PmtDate 
		FROM dbo.tblArOpenInvoice i INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId 
		WHERE i.CustId BETWEEN @CustomerIdFrom AND @CustomerIdThru AND c.AcctType = 0 
		AND i.TransDate < DATEADD(day,1,@CutoffDate) AND (i.Status <> 1 OR @IncludeHeldYn = 1) AND i.RecType <> 5
	) d 
	GROUP BY CustId, CustName, CurrencyId, InvcNum

	-- age periods
	--  age unapplied payments
	--  if @UnappliedCreditsYn = 1 THEN age any unapplied credits instead of lumping them into the unapplied bucket
	INSERT INTO #TempGrp (CustID, CustName, InvcNum, InvcType, CurrencyId, ExchRate, UnpaidFinch, UnApplCredit, CurAmtDue
		, BalAge1, BalAge2, BalAge3, BalAge4, UnpaidFinchFgn, UnApplCreditFgn, CurAmtDueFgn
		, BalAge1Fgn, BalAge2Fgn, BalAge3Fgn, BalAge4Fgn) 
		SELECT CustId, CustName, InvcNum, InvcType, CurrencyId, 1.0 -- default exchrate
			, SUM(CASE WHEN MaxOfRecType = 4 THEN amount ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType < 0 AND @UnappliedCreditsYn <> 1) THEN amount ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate >= @Age1 THEN amount ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate BETWEEN @Age2 and DATEADD(day,-1, @Age1) THEN amount ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate BETWEEN @Age3 and DATEADD(day,-1, @Age2) THEN amount ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate BETWEEN @Age4 and DATEADD(day,-1, @Age3) THEN amount ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate < @Age4  THEN amount ELSE 0 END)

			, SUM(CASE WHEN MaxOfRecType = 4 THEN AmountFgn ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType < 0 AND @UnappliedCreditsYn <> 1) THEN AmountFgn ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate >= @Age1 THEN AmountFgn ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate BETWEEN @Age2 and DATEADD(day,-1, @Age1) THEN AmountFgn ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate BETWEEN @Age3 and DATEADD(day,-1, @Age2) THEN AmountFgn ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate BETWEEN @Age4 and DATEADD(day,-1, @Age3) THEN AmountFgn ELSE 0 END)
			, SUM(CASE WHEN (MaxOfRecType > 0 OR @UnappliedCreditsYn = 1) AND MaxOfRecType <> 4 AND FirstOfTransDate < @Age4  THEN AmountFgn ELSE 0 END)
		FROM #OpenInvc 
		GROUP BY CustId, CustName, InvcNum, InvcType, CurrencyId

	-- add zero records for missing Open Invoice customers AND all Balance Forward
	INSERT INTO #TempGrp (CustID, CurrencyId, ExchRate) 
		SELECT c.CustID, c.CurrencyId, 1.0 -- default exchrate
		FROM dbo.tblArCust c 
		WHERE c.CustId BETWEEN @CustomerIdFrom AND @CustomerIdThru 
			AND c.CustId NOT IN (SELECT CustId FROM #TempGrp) 
	--		AND c.AcctType = 0 -- include BF customers

	-- add Balance Forward type customers (calculate the point in time base values)
	UPDATE #TempGrp SET #TempGrp.UnpaidFinchFgn = c.UnpaidFinch
		, #TempGrp.UnApplCreditFgn = c.UnApplCredit
		, #TempGrp.CurAmtDueFgn = c.CurAmtDue
		, #TempGrp.BalAge1Fgn =c.BalAge1
		, #TempGrp.BalAge2Fgn = c.BalAge2
		, #TempGrp.BalAge3Fgn = c.BalAge3
		, #TempGrp.BalAge4Fgn = c.BalAge4

		, #TempGrp.UnpaidFinch = ROUND(c.UnpaidFinch / ExchRate, @BaseCurrPrec)
		, #TempGrp.UnApplCredit = ROUND(c.UnApplCredit / ExchRate, @BaseCurrPrec)
		, #TempGrp.CurAmtDue = ROUND(c.CurAmtDue / ExchRate, @BaseCurrPrec)
		, #TempGrp.BalAge1 = ROUND(c.BalAge1 / ExchRate, @BaseCurrPrec)
		, #TempGrp.BalAge2 = ROUND(c.BalAge2 / ExchRate, @BaseCurrPrec)
		, #TempGrp.BalAge3 = ROUND(c.BalAge3 / ExchRate, @BaseCurrPrec)
		, #TempGrp.BalAge4 = ROUND(c.BalAge4 / ExchRate, @BaseCurrPrec) 
		FROM dbo.tblArCust c 
		WHERE #TempGrp.CustId = c.CustId AND c.AcctType = 1

	-- return a resultset
	SELECT CustId, CustName, InvcNum, InvcType, CurrencyId, ExchRate, UnpaidFinch, UnapplCredit, CurAmtDue, BalAge1, BalAge2, BalAge3, BalAge4
		, UnpaidFinchFgn, UnapplCreditFgn, CurAmtDueFgn, BalAge1Fgn, BalAge2Fgn, BalAge3Fgn, BalAge4Fgn 
	FROM #TempGrp

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArCustAgedBalances_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArCustAgedBalances_proc';

