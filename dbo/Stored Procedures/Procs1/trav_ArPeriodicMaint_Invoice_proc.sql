
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_Invoice_proc
AS

SET NOCOUNT ON
BEGIN TRY
--MOD:Finance Charge Enhancements
--MOD:Deposits Invoices
--http://webfront:801/view.php?id=239655

	DECLARE @PostRun pPostRun, @WrkStnDate datetime
	DECLARE @InvcBalFwrd pInvoiceNum
	DECLARE @InvcFinch pInvoiceNum
	DECLARE @FiscalYear smallint, @FiscalPeriod smallint
	DECLARE @BaseCurrencyPrec smallint
	DECLARE @UpdateInvoiceStatus bit, @SummarizeBFInvoices bit, @DeletePaidInvoiceDate datetime
	

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @InvcBalFwrd = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'InvcBalFwrd'
	SELECT @InvcFinch = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'InvcFinch'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @BaseCurrencyPrec = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BaseCurrencyPrec'
	SELECT @UpdateInvoiceStatus = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UpdateInvoiceStatus'
	SELECT @SummarizeBFInvoices = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'SummarizeBFInvoices'
	SELECT @DeletePaidInvoiceDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DeletePaidInvoiceDate'
	

	IF @PostRun IS NULL OR @WrkStnDate IS NULL 
	OR @InvcFinch IS NULL OR @InvcBalFwrd IS NULL
	OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL
	OR @BaseCurrencyPrec IS NULL 
	OR @UpdateInvoiceStatus IS NULL OR @SummarizeBFInvoices IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--================
	--Consolidate Balance Forward customer invoices
	--================
	IF @SummarizeBFInvoices = 1
	BEGIN
		--list of summarized invoices for balance forward customers
		CREATE TABLE #BFInvoiceSummary
		(
			CustId pCustId, 
			DistCode pDistCode,
			CurrencyId pCurrency, 
			ExchRate pDecimal,
			Amount pDecimal, 
			AmountFgn pDecimal, 
			UNIQUE CLUSTERED (CustId)
		)

		CREATE TABLE #BFFinChgInvoice
		(
			CustId pCustId,
			InvoiceNum pInvoiceNum,
			PRIMARY KEY (CustId, InvoiceNum)
		)
		
		--identify any finance change invoice numbers (to be excluded from summarization)
		INSERT INTO #BFFinChgInvoice (CustId, InvoiceNum)
		SELECT c.CustId, o.InvcNum
		FROM dbo.tblArCust c
		INNER JOIN dbo.tblArOpenInvoice o ON c.CustId = o.CustId 
		WHERE c.AcctType = 1 AND o.RecType = 4 --BF cust/Fin Chg Invoice
		GROUP BY c.CustId, o.InvcNum
		
		
		--summarize the invoices for balance forward customers
		--(excluding finance charge invoices)
		INSERT INTO #BFInvoiceSummary (CustId, DistCode, CurrencyId, ExchRate, Amount, AmountFgn) 
		SELECT c.CustId, c.DistCode, c.CurrencyId
			, CASE WHEN ISNULL(ci.ExchangeRate, 0) = 0 THEN 1.0 ELSE ci.ExchangeRate END
			, SUM(ROUND((SIGN(o.RecType) * o.AmtFgn) / CASE WHEN ISNULL(ci.ExchangeRate, 0) = 0 THEN 1.0 ELSE ci.ExchangeRate END, @BaseCurrencyPrec)) 
			, SUM(ROUND(SIGN(o.RecType) * o.AmtFgn, ISNULL(ci.[Prec], 2))) 
		FROM dbo.tblArOpenInvoice o 
		INNER JOIN dbo.tblArCust c ON o.CustId = c.CustId 
		LEFT JOIN #BFFinChgInvoice f ON o.CustId = f.CustId AND o.InvcNum = f.InvoiceNum
		LEFT JOIN #CurrencyInfo ci on c.CurrencyId = ci.CurrencyId
		WHERE c.AcctType = 1 
			AND f.InvoiceNum IS NULL --exclude Fin Chg Invoice numbers
			AND o.RecType<>5
		GROUP BY c.CustId, c.DistCode, c.CurrencyId, ci.ExchangeRate


		--delete the existing open invoice records for balance forward customers
		DELETE dbo.tblArOpenInvoice 
		FROM dbo.tblArOpenInvoice 
		INNER JOIN #BFInvoiceSummary ON dbo.tblArOpenInvoice.CustId = #BFInvoiceSummary.CustId 
		LEFT JOIN #BFFinChgInvoice f ON dbo.tblArOpenInvoice.CustId = f.CustId AND dbo.tblArOpenInvoice.InvcNum = f.InvoiceNum
		WHERE f.InvoiceNum IS NULL --exclude Fin Chg Invoice numbers
		AND tblArOpenInvoice.RecType<>5
	  
		--append the summarized Open Invoices for balance forward customers
		INSERT INTO dbo.tblArOpenInvoice (Amt, AmtFgn, CustId, TransDate, RecType, InvcNum, [Status]
			, DistCode, CurrencyId, ExchRate, NetDueDate, GLPeriod, FiscalYear, SourceApp, PostRun) 
		SELECT Amount, AmountFgn, CustId, @WrkStnDate, 1, @InvcBalFwrd, 0
			, DistCode, CurrencyId, ExchRate, @WrkStnDate, @FiscalPeriod, @FiscalYear, 0, @PostRun
		FROM #BFInvoiceSummary
		WHERE AmountFgn <> 0
	END

	--================
	--Update invoice status
	--================
	IF @UpdateInvoiceStatus = 1
	BEGIN
		--list of invoice totals by customer id
		CREATE TABLE #InvoiceTotal
		(
			CustId pCustId NULL, 
			InvcNum pInvoiceNum NULL, 
			AmountFgn pDecimal, 
			RecType smallint  
			UNIQUE CLUSTERED (CustId, InvcNum,RecType)
		)
		
		--summarize the open invoices 
		INSERT INTO #InvoiceTotal (CustId, InvcNum, AmountFgn,RecType) 
		SELECT CustId, InvcNum
			, SUM(CASE WHEN RecType < 0 Then -AmtFgn ELSE AmtFgn END) AmountFgn,(CASE RecType WHEN 5 THEN 5 ELSE 1 END) RecType
		FROM dbo.tblArOpenInvoice
		WHERE [Status] <> 4
		GROUP BY CustId, InvcNum,CASE RecType WHEN 5 THEN 5 ELSE 1 END    

		--update the status to 'paid' for those with no remaining balance
		UPDATE dbo.tblArOpenInvoice SET [Status] = 4 
		FROM dbo.tblArOpenInvoice 
		INNER JOIN #InvoiceTotal t 
			ON t.CustId = dbo.tblArOpenInvoice.CustId AND t.InvcNum = dbo.tblArOpenInvoice.InvcNum 
		WHERE t.AmountFgn = 0
		AND t.RecType = CASE dbo.tblArOpenInvoice.RecType WHEN 5 THEN 5 ELSE 1 END 
	END
	
	--================
	--Delete paid invoices prior to the date
	--================
	IF @DeletePaidInvoiceDate IS NOT NULL
	BEGIN
		DELETE dbo.tblArOpenInvoice 
		FROM (SELECT CustId, InvcNum ,(CASE RecType WHEN 5 THEN 5 ELSE 1 END) RecType
				FROM dbo.tblArOpenInvoice 
				WHERE [Status] = 4 
				GROUP BY InvcNum, CustID ,CASE RecType WHEN 5 THEN 5 ELSE 1 END
				HAVING MAX(TransDate) < @DeletePaidInvoiceDate) t 
		WHERE dbo.tblArOpenInvoice.CustId = t.CustId 
			AND dbo.tblArOpenInvoice.InvcNum = t.InvcNum 
			AND [Status] = 4 AND TransDate < @DeletePaidInvoiceDate
			AND t.RecType = CASE dbo.tblArOpenInvoice.RecType WHEN 5 THEN 5 ELSE 1 END 
	END

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_Invoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_Invoice_proc';

