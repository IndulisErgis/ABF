
CREATE PROCEDURE [dbo].[trav_DbArCustomerInvoiceCount_proc]
@InvcFinch pInvoiceNum = 'FIN CHRG',
@CustomerId pCustId = NULL,
@Wksdate datetime =   null,
@CustId pCustId = NULL
AS
BEGIN TRY
--PET:http://webfront:801/view.php?id=237636
--MOD:Finance Charge Enhancements

	SET NOCOUNT ON

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
	
		DECLARE @InvoiceCount int, @CustCount int, @ActiveCust int, @PastDueCust int

  DECLARE @FiscalYear smallint, @Period smallint
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

/* ArAging */
INSERT INTO #Aging(CustId, CustName, InvcNum, InvcType, CurrencyId, ExchRate, UnpaidFinch, UnApplCredit, CurAmtDue
		, BalAge1, BalAge2, BalAge3, BalAge4, UnpaidFinchFgn, UnapplCreditFgn, CurAmtDueFgn
		, BalAge1Fgn, BalAge2Fgn, BalAge3Fgn, BalAge4Fgn)
	EXEC trav_DbArCustAgedBalances_proc @WksDate, @InvcFinch, @WksDate, @CustId, @CustId, 0, 2, 1
declare @Activecountcust int
		select @Activecountcust = count( distinct a.CustId)
            FROM dbo.#Aging a 
            INNER JOIN 
            (
			   SELECT CustId FROM dbo.tblArOpenInvoice WHERE RecType > 0 AND Status <> 4 GROUP BY CustId
            ) t 
            ON a.CustId = t.CustId
            where CurAmtDue <> 0 OR BalAge1 <> 0 OR BalAge2 <> 0 OR BalAge3 <> 0 OR BalAge4 <> 0   
            
          declare @Pastcountcust int
		select @Pastcountcust = count( distinct a.CustId)
            FROM dbo.#Aging a 
            INNER JOIN 
            (
			   SELECT CustId FROM dbo.tblArOpenInvoice WHERE RecType > 0 AND Status <> 4 GROUP BY CustId
            ) t 
            ON a.CustId = t.CustId
            where BalAge1 <> 0 OR BalAge2 <> 0 OR BalAge3 <> 0 OR BalAge4 <> 0     
            
	/*  ArAgingAnalysis  */
	INSERT INTO #ArAgingAnalysis(UnpaidFinChg, UnappliedCredit, CurrentBal
		, Bal3160, Bal6190, Bal91120, BalOver120,ActiveCust,PastDueCust, TotDue) 
SELECT ISNULL(SUM(UnpaidFinch),0) AS UnpaidFinChg, ISNULL(SUM(UnApplCredit),0) AS UnappliedCredit, ISNULL(SUM(CurAmtDue),0) AS CurrentBal
		, ISNULL(SUM(BalAge1),0) AS Bal3160, ISNULL(SUM(BalAge2),0) AS Bal6190, ISNULL(SUM(BalAge3),0) AS Bal91120, ISNULL(SUM(BalAge4),0) AS BalOver120
		,ISNULL(@Activecountcust,0)
		,ISNULL(@Pastcountcust,0)
		--(
		--select distinct SUM(CASE WHEN CurAmtDue <> 0 OR BalAge1 <> 0 OR BalAge2 <> 0 OR BalAge3 <> 0 OR BalAge4 <> 0 
		--	AND NOT (t.CustId IS NULL) THEN 1 ELSE 0 END)) AS ActiveCust
		--, SUM(CASE WHEN BalAge1 <> 0 OR BalAge2 <> 0 OR BalAge3 <> 0 OR BalAge4 <> 0 
		--	THEN 1 ELSE 0 END) AS PastDueCust
		, ISNULL(SUM(UnpaidFinch + CurAmtDue + BalAge1 + BalAge2 + BalAge3 + BalAge4 - UnApplCredit),0) AS TotDue 
	FROM dbo.#Aging a 
			LEFT JOIN 
			(
				SELECT CustId FROM dbo.tblArOpenInvoice WHERE RecType > 0 AND Status <> 4 GROUP BY CustId
			) t 
			ON a.CustId = t.CustId
	SELECT @ActiveCust = ActiveCust, @PastDueCust = PastDueCust FROM #ArAgingAnalysis

	/*  ArCustomers  */
	SELECT @CustCount = CustCount 
	FROM 
	(
		SELECT CAST(COUNT(CustId)AS int) AS CustCount 
		FROM dbo.tblArCust
	) tmp

	/*  ArOpenInvoices  */
	SELECT @InvoiceCount = InvoiceCount 
	FROM 
	(
		SELECT SUM(CASE WHEN RecType > 0 AND i.Status <> 4 AND TransDate <= @WksDate 
			THEN 1 ELSE 0 END) AS InvoiceCount 
		FROM dbo.tblArOpenInvoice i INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId
	) tmp

	-- return resultset
	SELECT ISNULL(@ActiveCust, 0) AS ActiveCust, ISNULL(@CustCount, 0) AS CustCount
		, ISNULL(@InvoiceCount, 0) AS InvoiceCount, ISNULL(@PastDueCust, 0) AS PastDueCust
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArCustomerInvoiceCount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbArCustomerInvoiceCount_proc';

