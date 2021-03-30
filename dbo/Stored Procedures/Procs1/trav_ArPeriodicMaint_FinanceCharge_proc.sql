
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_FinanceCharge_proc
AS

SET NOCOUNT ON
BEGIN TRY
--MOD:Finance Charge Enhancements

	DECLARE @CompId sysname
	DECLARE @PostRun pPostRun, @WrkStnDate datetime
	DECLARE @GlAcctFinch pGlAcct, @InvcFinch pInvoiceNum
	DECLARE @FiscalYear smallint, @FiscalPeriod smallint
	DECLARE @BaseCurrency pCurrency, @BaseCurrencyPrec smallint
	DECLARE @PostNewFinch bit

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @GlAcctFinch = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'GlAcctFinch'
	SELECT @InvcFinch = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'InvcFinch'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @BaseCurrency = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'BaseCurrency'
	SELECT @BaseCurrencyPrec = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BaseCurrencyPrec'
	SELECT @PostNewFinch = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostNewFinch'

	IF @PostRun IS NULL OR @WrkStnDate IS NULL 
		OR @GlAcctFinch IS NULL OR @InvcFinch IS NULL
		OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL
		OR @BaseCurrency IS NULL OR @BaseCurrencyPrec IS NULL 
		OR @PostNewFinch IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--========================
	--post new finance charges
	--========================
	IF @PostNewFinch = 1
	BEGIN
		--list of finance charge information
		CREATE TABLE #FinCharges
		(
			CustId pCustId, 
			CurrencyId pCurrency,
			DistCode pDistCode,
			NewFinch pDecimal, 
			NewFinchBase pDecimal, 
			ExchRate pDecimal, 
			UNIQUE CLUSTERED (CustId)
		)

		--PET:http://webfront:801/view.php?id=225002
		--capture the new finance charge information (calculate the base amount)
		INSERT INTO #FinCharges (CustId, CurrencyId, DistCode, NewFinch, NewFinchBase, ExchRate) 
		SELECT c.CustId, c.CurrencyId, c.DistCode, ROUND(c.NewFinch, ISNULL(ci.[Prec], 2)) 
			, ROUND(ROUND(c.NewFinch, ISNULL(ci.[Prec], 2)) / CASE WHEN ISNULL(ci.ExchangeRate, 0) = 0 THEN 1.0 ELSE ci.ExchangeRate END, @BaseCurrencyPrec)
			, CASE WHEN ISNULL(ci.ExchangeRate, 0) = 0 THEN 1.0 ELSE ci.ExchangeRate END
		FROM dbo.tblArCust c 
		LEFT JOIN #CurrencyInfo ci on c.CurrencyId = ci.CurrencyId
		WHERE c.NewFinch <> 0


		--create a credit to the Fin Charge Account for the new finance charge amounts (must be a base currency account)
		INSERT #GlPostLogs (PostRun, CompId, PostDate, TransDate, [Description], SourceCode, Reference
			, GlAccount, FiscalPeriod, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
			, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, CurrencyId, ExchRate)
		SELECT @PostRun, @CompId, @WrkStnDate, @WrkStnDate, 'AR - ' + @InvcFinch, 'AR', 'AR FINCH'
			, @GlAcctFinch, @FiscalPeriod, @FiscalYear, NULL, NULL, -5
			, SUM(f.NewFinchBase), 0, SUM(f.NewFinchBase), 0, SUM(f.NewFinchBase), @BaseCurrency, 1.0
		FROM #FinCharges f
		HAVING SUM(f.NewFinchBase) <> 0


		--create debits to the receivables accounts for the new finance charge amounts
		--	use the customer currency amounts when the GL Account and/or GL Account Currency doesn't exist
		--	otherwise calculate the foreign amount in the receivables account currency.
		INSERT #GlPostLogs (PostRun, CompId, PostDate, TransDate, [Description], SourceCode, Reference
			, GlAccount, FiscalPeriod, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
			, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, CurrencyId, ExchRate)
		SELECT @PostRun, @CompId, @WrkStnDate, @WrkStnDate, 'AR - ' + @InvcFinch, 'AR', 'AR FINCH'
			, d.GLAcctReceivables, @FiscalPeriod, @FiscalYear, NULL, NULL, -5
			, SUM(CASE WHEN ci.CurrencyId IS NULL 
					THEN f.NewFinch 
					ELSE ROUND(f.NewFinchBase * CASE WHEN ISNULL(ci.ExchangeRate, 0) = 0 THEN 1.0 ELSE ci.ExchangeRate END, ISNULL(ci.[Prec], 2))
					END)
			, SUM(f.NewFinchBase) , 0
			, SUM(CASE WHEN ci.CurrencyId IS NULL 
					THEN f.NewFinch 
					ELSE ROUND(f.NewFinchBase * CASE WHEN ISNULL(ci.ExchangeRate, 0) = 0 THEN 1.0 ELSE ci.ExchangeRate END, ISNULL(ci.[Prec], 2))
					END)
			, 0, ISNULL(ci.CurrencyId, f.CurrencyId)
			, MIN(CASE WHEN ci.CurrencyId IS NULL 
				THEN f.ExchRate
				ELSE CASE WHEN ISNULL(ci.ExchangeRate, 0) = 0 THEN 1.0 ELSE ci.ExchangeRate END
				END)
		FROM #FinCharges f
		LEFT JOIN dbo.tblArDistCode d ON f.DistCode = d.DistCode 
		LEFT JOIN dbo.tblGlAcctHdr g ON d.GlAcctReceivables = g.AcctId 
		LEFT JOIN #CurrencyInfo ci on g.CurrencyId = ci.CurrencyId
		GROUP BY d.GLAcctReceivables, ISNULL(ci.CurrencyId, f.CurrencyId)
		HAVING SUM(f.NewFinchBase) <> 0


		--create invoices for the finance charges
		INSERT INTO dbo.tblArOpenInvoice (PostRun, CustId, InvcNum, DistCode
			, RecType, [Status], TransDate, NetDueDate, GLPeriod, FiscalYear
			, Amt, AmtFgn, CurrencyId, ExchRate) 
		SELECT @PostRun, f.CustId, @InvcFinch, f.DistCode
			, 4, 0, @WrkStnDate, @WrkStnDate, @FiscalPeriod, @FiscalYear 
			, f.NewFinchBase, f.NewFinch, f.CurrencyId, f.ExchRate
		FROM #FinCharges f


		--add the new finance charges into history
		INSERT INTO dbo.tblArHistFinch (CustID, FinchAmt, FinchDate, Postrun, FiscalYear
			, GLPeriod, SumHistPeriod, CurrencyId, FinchAmtFgn, ExchRate
			, GLAcctFinch, GLAcctReceivables) 
		SELECT f.CustId, f.NewFinchBase, @WrkStnDate, @PostRun, @FiscalYear
			, @FiscalPeriod, @FiscalPeriod, f.CurrencyId, f.NewFinch, f.ExchRate 
			, @GlAcctFinch, d.GLAcctReceivables
		FROM #FinCharges f 
		LEFT JOIN dbo.tblArDistCode d ON f.DistCode = d.DistCode 


		--update the unpaid and new finance charge amounts for the customers
		UPDATE dbo.tblArCust SET UnpaidFinch = UnpaidFinch + dbo.tblArCust.NewFinch, dbo.tblArCust.NewFinch = 0 
		FROM dbo.tblArCust 
		INNER JOIN #FinCharges f on dbo.tblArCust.CustId = f.CustId
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_FinanceCharge_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_FinanceCharge_proc';

