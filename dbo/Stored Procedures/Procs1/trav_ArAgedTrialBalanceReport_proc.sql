
CREATE PROCEDURE [dbo].[trav_ArAgedTrialBalanceReport_proc]
@InvcCutoffOpt bit, --Invoice cutoff option (0=by date/1=by gl period & fiscal year)
@InvcCutoffDate datetime, 
@InvcCutoffFiscalPeriod smallint,
@InvcCutoffFiscalYear smallint,
@PayCutoffOpt bit, --Payment cutoff option (0=by date/1=by gl period & fiscal year)
@PayCutoffDate datetime, 
@PayCutoffFiscalPeriod smallint,
@PayCutoffFiscalYear smallint,
@AgingDate datetime, --base date for the aging dates
@AgingDays1 smallint = 30, --number of days between the AgingDate and the date for aging bracket 1
@AgingDays2 smallint = 60, --number of days between the AgingDate and the date for aging bracket 2
@AgingDays3 smallint = 90, --number of days between the AgingDate and the date for aging bracket 3
@AgingDays4 smallint = 120, --number of days between the AgingDate and the date for aging bracket 4
@DistCodeFrom pDistCode = '',
@DistCodeThru pDistCode = 'zzzzzz',
@PrintAllInBase bit = 1, --option to print all invoices in base currency
@BaseCurrencyId pCurrency = 'USD', --base currency Id
@AgeBy tinyint = 0, --0;TransDate;1;DueDate;2DiscDueDate
@PrintBy tinyint = 0, --Default print by to CustId
@IncludeBalanceForward bit = 0, --option to include balance forward customers
@IncludeCurrentCustomer bit = 1, --option to include non-overdue customers
@IncludeZeroBalanceCustomer bit = 1, --option to include zero balance customers
@IncludeSaleInvoice bit = 1,  --Default AR/SO invoices
@IncludeProjectInvoice bit = 1,  --Project invoices     
@IncludeServiceInvoice bit = 1, --Service invoices 
@BaseCurrencyPrecision smallint = 4,
@IncludeRegularInvcType bit=1 ,  
@IncludeProformaInvcType bit=1  
AS
SET NOCOUNT ON
BEGIN TRY

--PET:http://webfront:801/view.php?id=237876
--MOD:Finance Charge Enhancements
--MOD:Deposit Invoices - Add parameters for Invoice Type option
--PET:http://webfront:801/view.php?id=239303
--PET:http://webfront:801/view.php?id=239492

	DECLARE @Day1 datetime, @Day2 datetime, @Day3 datetime, @Day4 datetime
	DECLARE @MaxInvcAgingDate datetime, @MaxPmtAgingDate datetime

	--expects the current exchange rates to be provided via the #CurrencyInfo table
	--CREATE TABLE #CurrencyInfo (CurrencyId pCurrency NOT NULL, ExchangeRate pDecimal NOT NULL, PRIMARY KEY (CurrencyId))

	--expects the list of customers to be provided via the #CustomerList table
	--CREATE TABLE #CustomerList (CustId pCustId, PRIMARY KEY (CustId))

	--table for all the invoices to process
	CREATE TABLE #AgeInvoiceList 
	(
		CustId pCustId, 
		InvcNum pInvoiceNum, 
		DistCode pDistCode,
		RecType smallint, 
		AgingDate datetime, 
		AmountDue pDecimal default(0),
		AmountDueBase pDecimal default(0),
		TransDate datetime,
		[Status] tinyint Null Default(0), 
		ProjId nvarchar(10) Null, 
		PhaseId nvarchar(10) Null, 
		SourceApp tinyint Null Default(0),
		FiscalYear smallint Default(0),
		FiscalPeriod smallint Default (0)
	) 

	--table to identify invoices that should be excluded from the report
	CREATE TABLE #ExcludeInvoiceList
	(
		CustId pCustId, 
		InvcNum pInvoiceNum,
		InvcType tinyint,
		PRIMARY KEY (CustId, InvcNum, InvcType)
	)

	--table to capture the aged invoice detail
	CREATE TABLE #InvoiceAgingBucket
	(
		CustId pCustId, 
		InvcNum pInvoiceNum, 
		DistCode pDistCode,
		MinAgingDate datetime NULL, 
		MaxRecType smallint, 
		UnappliedCredit pDecimal DEFAULT(0), 
		AmtCurrent pDecimal DEFAULT(0), 
		AmtDue1 pDecimal DEFAULT(0), 
		AmtDue2 pDecimal DEFAULT(0), 
		AmtDue3 pDecimal DEFAULT(0), 
		AmtDue4 pDecimal DEFAULT(0), 
		UnappliedCreditBase pDecimal DEFAULT(0), 
		AmtCurrentBase pDecimal DEFAULT(0), 
		AmtDue1Base pDecimal DEFAULT(0), 
		AmtDue2Base pDecimal DEFAULT(0), 
		AmtDue3Base pDecimal DEFAULT(0), 
		AmtDue4Base pDecimal DEFAULT(0), 
		PRIMARY KEY (CustId, InvcNum, DistCode)
	)

	--=========================
	--Open Invoice Customers
	--=========================
		
	--build the list of invoices to process for open invoice customers
	INSERT INTO #AgeInvoiceList (CustId, InvcNum, RecType, AmountDue, AmountDueBase, TransDate
		, AgingDate, DistCode, [Status], ProjId, PhaseId, SourceApp, FiscalYear, FiscalPeriod) 
		SELECT i.CustId, ISNULL(i.InvcNum, ''), i.RecType
		, CASE WHEN @PrintAllInBase = 1 THEN i.Amt ELSE i.AmtFgn END
		, i.Amt, CONVERT(nvarchar(8), i.TransDate, 112)
		, CONVERT(nvarchar(8), CASE @AgeBy 
			WHEN 0 THEN i.TransDate
			WHEN 1 THEN ISNULL(i.NetDueDate, i.TransDate)
			ELSE ISNULL(i.DiscDueDate, i.TransDate)
		END, 112)
		, CASE WHEN @PrintBy = 4 THEN i.DistCode ELSE c.DistCode END --use customer default dist code when not printing by distcode
		, i.[Status], i.ProjId, i.PhaseId, i.SourceApp, i.FiscalYear, i.GlPeriod
		FROM #CustomerList l
		INNER JOIN dbo.tblArOpenInvoice i on l.CustId = i.CustId
		AND ((i.RecType<>5 AND @IncludeRegularInvcType=1)OR (i.RecType=5 AND  @IncludeProformaInvcType=1)) 
		INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId
		WHERE c.AcctType = 0 
		AND i.DistCode BETWEEN @DistCodeFrom AND @DistCodeThru --always apply filter to invoice distcode
		AND ((i.TransDate < DATEADD(day, 1, @InvcCutoffDate) And @InvcCutoffOpt = 0)
			OR (((i.FiscalYear * 1000) + i.GlPeriod) <= ((@InvcCutoffFiscalYear * 1000) + @InvcCutoffFiscalPeriod) And @InvcCutoffOpt = 1))
		AND ( ((i.SourceApp = 0 OR i.SourceApp = 1 OR i.SourceApp = 4) AND @IncludeSaleInvoice = 1) --filter source prior to aging so balances reflect specific source
			OR ((i.SourceApp = 3) AND @IncludeProjectInvoice = 1) 
			OR ((i.SourceApp = 2) AND @IncludeServiceInvoice = 1) )

	
	--isolate the invoices that should be excluded from the aging
	--	invoices with a zero balance and no payments as of/after the payment cutoff
	INSERT INTO #ExcludeInvoiceList (CustId, InvcNum, InvcType)
	SELECT CustId, InvcNum, 1
	FROM #AgeInvoiceList
	WHERE RecType <> 5
	GROUP BY CustId, InvcNum
	HAVING SUM(SIGN(RecType) * (AmountDue + AmountDueBase)) = 0 --ensure a zero balance
		AND SUM(CASE WHEN RecType < 0 
			AND ((TransDate >= @PayCutoffDate And @PayCutoffOpt = 0) 
			OR (((FiscalYear * 1000) + FiscalPeriod) >= ((@PayCutoffFiscalYear * 1000) + @PayCutoffFiscalPeriod) And @PayCutoffOpt = 1))
		THEN 1 
		ELSE 0 
		END) = 0 --no payments as of/after the payment cutoff
	
	INSERT INTO #ExcludeInvoiceList (CustId, InvcNum, InvcType)
	SELECT CustId, InvcNum, 5
	FROM #AgeInvoiceList
	WHERE RecType = 5
	GROUP BY CustId, InvcNum
	HAVING SUM(SIGN(RecType) * (AmountDue + AmountDueBase)) = 0 --ensure a zero balance
		AND SUM(CASE WHEN AmountDue < 0 
			AND ((TransDate >= @PayCutoffDate And @PayCutoffOpt = 0) 
			OR (((FiscalYear * 1000) + FiscalPeriod) >= ((@PayCutoffFiscalYear * 1000) + @PayCutoffFiscalPeriod) And @PayCutoffOpt = 1))
		THEN 1 
		ELSE 0 
		END) = 0 --no payments as of/after the payment cutoff
	
	--initialize the list of aged values
	INSERT INTO #InvoiceAgingBucket (CustId, InvcNum, DistCode) 
	SELECT i.CustId, i.InvcNum, i.DistCode 
	FROM #AgeInvoiceList i
	LEFT JOIN #ExcludeInvoiceList e ON i.CustId = e.CustId AND i.InvcNum = e.InvcNum AND ((i.RecType <> 5 AND e.InvcType = 1) OR i.RecType = e.InvcType)
	WHERE e.CustId IS NULL
	GROUP BY i.CustId, i.InvcNum, i.DistCode


	--capture the max invoice and payment dates for calculating the MinAgingDates
	SELECT @MaxInvcAgingDate = MAX(AgingDate) FROM #AgeInvoiceList WHERE RecType > 0 AND NOT(AgingDate IS NULL)
	SELECT @MaxPmtAgingDate = MAX(AgingDate) FROM #AgeInvoiceList WHERE RecType < 0 AND NOT(AgingDate IS NULL)
	SELECT @MaxInvcAgingDate = COALESCE(@MaxInvcAgingDate, GETDATE()), @MaxPmtAgingDate = COALESCE(@MaxPmtAgingDate, GETDATE())


	--process invoices/payments by Min aging date and max rec typ so that over payments on invoices are aged with the invoice
	UPDATE #InvoiceAgingBucket 
		SET MinAgingDate = m.MinAgingDate, MaxRecType = m.MaxRecType
		FROM #InvoiceAgingBucket 
		INNER JOIN (SELECT CustId, InvcNum, DistCode, Max(RecType) MaxRecType, CASE WHEN Max(RecType) > 0 THEN Min(InvcDate) ELSE Min(PmtDate) END MinAgingDate
				FROM (SELECT CustId, InvcNum, DistCode, ISNULL(RecType, 1) RecType
						, CASE WHEN ISNULL(RecType, 1) > 0 THEN AgingDate ELSE @MaxInvcAgingDate END InvcDate
						, Case When ISNULL(RecType, 1) < 0 THEN AgingDate ELSE @MaxPmtAgingDate END PmtDate
						FROM #AgeInvoiceList) d	GROUP BY CustId, InvcNum, DistCode) m
		ON #InvoiceAgingBucket.CustId = m.CustId AND #InvoiceAgingBucket.InvcNum = m.InvcNum AND #InvoiceAgingBucket.DistCode = m.DistCode


	--Set each aging dates based upon the initial aging date
	SELECT @Day1 = DATEADD(DAY, -@AgingDays1, @AgingDate)
		, @Day2 = DATEADD(DAY, -@AgingDays2, @AgingDate)
		, @Day3 = DATEADD(DAY, -@AgingDays3, @AgingDate)
		, @Day4 = DATEADD(DAY, -@AgingDays4, @AgingDate)


	--separate amounts into aging buckets
	UPDATE #InvoiceAgingBucket
		SET UnappliedCredit = ISNULL(s.UnappliedCredit, 0), AmtCurrent = ISNULL(s.AmtCurrent, 0)
			, AmtDue1 = ISNULL(s.AmtDue1, 0), AmtDue2 = ISNULL(s.AmtDue2, 0), AmtDue3 = ISNULL(s.AmtDue3, 0), AmtDue4 = ISNULL(s.AmtDue4, 0)
			, UnappliedCreditBase = ISNULL(s.UnappliedCreditBase, 0), AmtCurrentBase = ISNULL(s.AmtCurrentBase, 0)
			, AmtDue1Base = ISNULL(s.AmtDue1Base, 0), AmtDue2Base = ISNULL(s.AmtDue2Base, 0), AmtDue3Base = ISNULL(s.AmtDue3Base, 0), AmtDue4Base = ISNULL(s.AmtDue4Base, 0)
		FROM #InvoiceAgingBucket INNER JOIN (SELECT i.CustId, i.InvcNum, i.DistCode

			, SUM(CASE WHEN (i.maxrectype < 0) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) UnappliedCredit
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate >= @Day1 THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtCurrent
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate BETWEEN @Day2 AND DateAdd(Day, -1, @Day1) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue1
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate BETWEEN @Day3 AND DateAdd(Day, -1, @Day2) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue2
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate BETWEEN @Day4 AND DateAdd(Day, -1, @Day3) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue3
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate < @Day4  THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue4

			, SUM(CASE WHEN (i.maxrectype < 0) THEN SIGN(o.RecType) * o.AmountDueBase ELSE 0 END) UnappliedCreditBase
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate >= @Day1 THEN SIGN(o.RecType) * o.AmountDueBase ELSE 0 END) AmtCurrentBase
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate BETWEEN @Day2 AND DateAdd(Day, -1, @Day1) THEN SIGN(o.RecType) * o.AmountDueBase ELSE 0 END) AmtDue1Base
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate BETWEEN @Day3 AND DateAdd(Day, -1, @Day2) THEN SIGN(o.RecType) * o.AmountDueBase ELSE 0 END) AmtDue2Base
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate BETWEEN @Day4 AND DateAdd(Day, -1, @Day3) THEN SIGN(o.RecType) * o.AmountDueBase ELSE 0 END) AmtDue3Base
			, SUM(CASE WHEN (i.maxrectype > 0) AND i.MinAgingDate < @Day4  THEN SIGN(o.RecType) * o.AmountDueBase ELSE 0 END) AmtDue4Base
			FROM #InvoiceAgingBucket i INNER JOIN #AgeInvoiceList o ON i.CustId = o.CustId AND i.InvcNum = o.InvcNum AND i.DistCode = o.DistCode
			GROUP BY i.CustId, i.InvcNum, i.DistCode) s
		ON #InvoiceAgingBucket.CustId = s.CustId AND #InvoiceAgingBucket.InvcNum = s.InvcNum AND #InvoiceAgingBucket.DistCode = s.DistCode


	--=========================
	--Balance Forward Customers
	--=========================
	IF @IncludeBalanceForward = 1
	BEGIN
		--create aging bucket records for balance forward customers
		--	calclate the base currency amounts using the current exchange rate
		INSERT INTO #InvoiceAgingBucket (CustId, InvcNum, DistCode, MinAgingDate, MaxRecType
			, UnappliedCredit, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4 
			, UnappliedCreditBase, AmtCurrentBase, AmtDue1Base, AmtDue2Base, AmtDue3Base, AmtDue4Base)
		SELECT c.CustId, 'BalFwd', c.DistCode , @AgingDate, 1
			, CASE WHEN @PrintAllInBase = 1 
				THEN -ROUND(ISNULL(c.UnapplCredit, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
				ELSE -ISNULL(c.UnapplCredit, 0) 
			END
			, CASE WHEN @PrintAllInBase = 1 
				THEN ROUND((ISNULL(c.CurAmtDue, 0) + ISNULL(c.UnpaidFinch, 0)) / e.ExchangeRate, @BaseCurrencyPrecision)
				ELSE ISNULL(c.CurAmtDue, 0) + ISNULL(c.UnpaidFinch, 0)
			END
			, CASE WHEN @PrintAllInBase = 1 
				THEN ROUND(ISNULL(c.BalAge1, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
				ELSE ISNULL(c.BalAge1, 0)
			END
			, CASE WHEN @PrintAllInBase = 1 
				THEN ROUND(ISNULL(c.BalAge2, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
				ELSE ISNULL(c.BalAge2, 0)
			END
			, CASE WHEN @PrintAllInBase = 1 
				THEN ROUND(ISNULL(c.BalAge3, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
				ELSE ISNULL(c.BalAge3, 0)
			END
			, CASE WHEN @PrintAllInBase = 1 
				THEN ROUND(ISNULL(c.BalAge4, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
				ELSE ISNULL(c.BalAge4, 0)
			END
			, -ROUND(ISNULL(c.UnapplCredit, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
			, ROUND((ISNULL(c.CurAmtDue, 0) + ISNULL(c.UnpaidFinch, 0)) / e.ExchangeRate, @BaseCurrencyPrecision)
			, ROUND(ISNULL(c.BalAge1, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
			, ROUND(ISNULL(c.BalAge2, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
			, ROUND(ISNULL(c.BalAge3, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
			, ROUND(ISNULL(c.BalAge4, 0) / e.ExchangeRate, @BaseCurrencyPrecision)
			FROM #CustomerList l
			INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId
			INNER JOIN #CurrencyInfo e ON c.CurrencyId = e.CurrencyId
			WHERE c.AcctType = 1 
	END
	

	--=========================
	--Apply report specific options
	--=========================
	--remove zero balance customers
	IF @IncludeZeroBalanceCustomer = 0 
		DELETE #InvoiceAgingBucket
		WHERE CustId IN (SELECT CustID FROM #InvoiceAgingBucket 
			GROUP BY CustId 
			HAVING SUM(AmtCurrent + AmtDue1 + AmtDue2 + AmtDue3 + AmtDue4 + UnappliedCredit) = 0)

	--remove non-pastdue customers
	IF @IncludeCurrentCustomer = 0
		DELETE #InvoiceAgingBucket
			WHERE CustId IN (SELECT CustID FROM #InvoiceAgingBucket 
				GROUP BY CustId 
				HAVING SUM(AmtDue1 + AmtDue1Base + AmtDue2 + AmtDue2Base + AmtDue3 + AmtDue3Base + AmtDue4 + AmtDue4Base) = 0) --all aged buckets must be zero

	--==============
	--return results
	--==============	
	--create a flat-compound resultset RecordType of 0 for invoice detail / RecordType of 1 for aged invoice totals
	SELECT 0 RecordType
		, Case @PrintBy
			When 0 Then c.CustId
			When 1 Then c.CustName
			When 2 Then c.SalesRepId1
			When 3 Then c.Region
			When 4 Then a.DistCode
			End As GrpId
		, c.CustId, c.CustName, c.City, c.Region, c.Country, c.Phone, c.DistCode AS DfltDistCode, c.CurrencyId AS CustomerCurrencyId
		, c.AcctType, c.Contact, c.CreditLimit, c.SalesRepId1 AS SalesRepId, s.[Name] AS SalesRepName
		, CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE c.CurrencyId END AS CurrencyId
		, a.InvcNum, a.DistCode, o.AgingDate, SIGN(RecType) * o.AmountDue AS AmtDue, SIGN(RecType) * o.AmountDueBase AS AmtDueBase
		, o.RecType, o.[Status], o.ProjId, o.PhaseId, o.SourceApp
		, 0 AS UnappliedCredit, 0 AS AmtCurrent, 0 AS AmtDue1, 0 AS AmtDue2, 0 AS AmtDue3, 0 AS AmtDue4 
		, 0 AS UnappliedCreditBase, 0 AS AmtCurrentBase, 0 AS AmtDue1Base, 0 AS AmtDue2Base, 0 AS AmtDue3Base, 0 AS AmtDue4Base
	FROM #InvoiceAgingBucket a
	INNER JOIN #AgeInvoiceList o ON a.CustId = o.CustId AND a.InvcNum = o.InvcNum AND a.DistCode = o.DistCode
	INNER JOIN dbo.tblArCust c ON o.CustId = c.CustId
	LEFT JOIN dbo.tblArSalesRep s ON c.SalesRepId1 = s.SalesRepID
		
	UNION ALL

	SELECT 1 RecordType
		, Case @PrintBy
			When 0 Then c.CustId
			When 1 Then c.CustName
			When 2 Then c.SalesRepId1
			When 3 Then c.Region
			When 4 Then a.DistCode
			End As GrpId
		, c.CustId, c.CustName, c.City, c.Region, c.Country, c.Phone, c.DistCode AS DfltDistCode, c.CurrencyId AS CustomerCurrencyId
		, c.AcctType, c.Contact, c.CreditLimit, c.SalesRepId1 AS SalesRepId, s.[Name] AS SalesRepName
		, CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE c.CurrencyId END AS CurrencyId
		, a.InvcNum, a.DistCode, NULL AS AgingDate
		, CASE WHEN c.AcctType = 1 THEN a.UnappliedCredit + a.AmtCurrent + a.AmtDue1 + a.AmtDue2 + a.AmtDue3 + a.AmtDue4 ELSE 0 END AS AmtDue --return invoice total for balfwd only
		, CASE WHEN c.AcctType = 1 THEN a.UnappliedCreditBase + a.AmtCurrentBase + a.AmtDue1Base + a.AmtDue2Base + a.AmtDue3Base + a.AmtDue4Base ELSE 0 END AS AmtDueBase
		, 0 AS RecType, NULL AS [Status], NULL AS ProjId, NULL AS PhaseId, NULL AS SourceApp
		, a.UnappliedCredit, a.AmtCurrent, a.AmtDue1, a.AmtDue2, a.AmtDue3, a.AmtDue4 
		, a.UnappliedCreditBase, a.AmtCurrentBase, a.AmtDue1Base, a.AmtDue2Base, a.AmtDue3Base, a.AmtDue4Base
	FROM #InvoiceAgingBucket a
	INNER JOIN dbo.tblArCust c ON a.CustId = c.CustId
	LEFT JOIN dbo.tblArSalesRep s ON c.SalesRepId1 = s.SalesRepID
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAgedTrialBalanceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAgedTrialBalanceReport_proc';

