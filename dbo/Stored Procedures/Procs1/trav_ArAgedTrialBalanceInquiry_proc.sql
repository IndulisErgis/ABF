
CREATE PROCEDURE [dbo].[trav_ArAgedTrialBalanceInquiry_proc]
@TransactionCutoffOption bit = 0, --Invoice cutoff option (0=by date/1=by fiscal period & fiscal year)
@TransactionCutoffDate datetime = '20090810', 
@TransactionCutoffFiscalPeriod smallint = 8,
@TransactionCutoffFiscalYear smallint = 2009,
@PaymentCutoffOption bit = 0, --Payment cutoff option (0=by date/1=by fiscal period & fiscal year)
@PaymentCutoffDate datetime = '20090810', 
@PaymentCutoffFiscalPeriod smallint = 8,
@PaymentCutoffFiscalYear smallint = 2009,
@PastDueDate1 datetime = '20090711', --the date for aging bracket 1
@PastDueDate2 datetime = '20090611', --the date for aging bracket 2
@PastDueDate3 datetime = '20090512', --the date for aging bracket 3
@PastDueDate4 datetime = '20090412', --the date for aging bracket 4
@DistCodeFrom pDistCode = '',
@DistCodeThru pDistCode = 'zzzzzz',
@PrintAllInBase bit = 1, --option to print all invoices in base currency
@ReportCurrency pCurrency = 'USD', --report currency Id
@AgeBy tinyint = 0, --0;TransDate;1;DueDate;2DiscDueDate
@IncludeCurrentCustomer bit = 1, --option to include non-overdue customers
@IncludeSaleInvoice bit = 1,  --Default AR/SO invoices
@IncludeProjectInvoice bit = 1,  --Project invoices     
@IncludeServiceInvoice bit = 1, --Service invoices 
@BaseCurrencyPrecision smallint = 2,
@IncludeRegularInvcType bit=1 ,
@IncludeProformaInvcType bit=1 
AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #ArAgedTrialBal 
(
	[CustId] [pCustID] NOT NULL ,   
	[InvcNum] [pInvoiceNum] NULL ,
	[AmountDue] [pDecimal] NOT NULL DEFAULT (0) ,
	[Unapplied] [pDecimal] NOT NULL DEFAULT (0) ,
	[AmtCurrent] [pDecimal] NOT NULL DEFAULT (0) ,
	[AmtDue1] [pDecimal] NOT NULL DEFAULT (0) ,
	[AmtDue2] [pDecimal] NOT NULL DEFAULT (0) ,
	[AmtDue3] [pDecimal] NOT NULL DEFAULT (0) ,
	[AmtDue4] [pDecimal] NOT NULL DEFAULT (0)
) 

CREATE TABLE #ArInvoice
(
	CustId pCustId NOT NULL, 
	InvcNum pInvoiceNum NOT NULL, 
	MinAgingDate datetime NULL, 
	MaxRecType smallint NULL,
	Unapplied pDecimal NOT NULL DEFAULT (0), 
	AmtCurrent pDecimal NOT NULL DEFAULT (0), 
	AmtDue1 pDecimal NOT NULL DEFAULT (0), 
	AmtDue2 pDecimal NOT NULL DEFAULT (0), 
	AmtDue3 pDecimal NOT NULL DEFAULT (0), 
	AmtDue4 pDecimal NOT NULL DEFAULT (0),
	UnappliedFgn pDecimal NOT NULL DEFAULT (0), 
	AmtCurrentFgn pDecimal NOT NULL DEFAULT (0), 
	AmtDue1Fgn pDecimal NOT NULL DEFAULT (0), 
	AmtDue2Fgn pDecimal NOT NULL DEFAULT (0), 
	AmtDue3Fgn pDecimal NOT NULL DEFAULT (0), 
	AmtDue4Fgn pDecimal NOT NULL DEFAULT (0),
	AmountDue pDecimal NOT NULL DEFAULT (0),
	AmountDueFgn pDecimal NOT NULL DEFAULT (0)
)

CREATE TABLE #ArOpenInvoice 
(
	CustId pCustId NOT NULL, 
	SalesRepID pSalesRep null,
	Region nvarchar(10) null,
	CurrencyID pCurrency,
	DistCode pDistCode null,   
	InvcNum pInvoiceNum NOT NULL, 
	RecType smallint NOT NULL, 
	[Status] tinyint NOT NULL, 
	TransDate datetime NULL, 
	AgingDate datetime ,
	NetDueDate datetime ,
	DiscDueDate datetime NULL,
	CheckNum pCheckNum NULL,
	DiscAmt pDecimal default(0),
	DiscAmtFgn pDecimal default(0), 
	AmountDue pDecimal default(0),
	AmountDueFgn pDecimal default(0),
	GlPeriod smallint,
	FiscalYear smallint,
	SourceApp tinyint
)
	
INSERT INTO #ArOpenInvoice (CustID, SalesRepID, Region, CurrencyID, DistCode, InvcNum, RecType, [Status], TransDate 
	, AgingDate, NetDueDate, DiscDueDate, CheckNum, DiscAmt, DiscAmtFgn, AmountDue, AmountDueFgn, GlPeriod 
	, FiscalYear, SourceApp)
SELECT c.CustID, c.SalesRepID1, c.Region, o.CurrencyID, o.DistCode, o.InvcNum, o.RecType, o.Status, CONVERT(nvarchar(8), o.TransDate, 112)
	, (CASE WHEN @AgeBy = 0 THEN (CASE WHEN o.TransDate IS NULL THEN NULL ELSE o.TransDate END)
	  ELSE (CASE WHEN @AgeBy = 1 THEN (CASE WHEN o.NetDueDate IS NULL THEN o.TransDate ELSE o.NetDueDate END)
	  ELSE (CASE WHEN @AgeBy = 2 THEN (CASE WHEN o.DiscDueDate IS NULL THEN o.TransDate ELSE o.DiscDueDate END) 
	  END)END)END), o.NetDueDate, o.DiscDueDate, o.CheckNum, o.DiscAmt, o.DiscAmtFgn
	, CASE WHEN o.RecType > 0 THEN o.Amt ELSE -o.Amt END
	, CASE WHEN o.RecType > 0 THEN o.AmtFgn ELSE -o.AmtFgn END 
	, o.GlPeriod, o.FiscalYear, SourceApp
FROM #tmpCustomerList l INNER JOIN dbo.tblArOpenInvoice o (nolock) ON l.CustId = o.CustId
	AND ((o.RecType<>5 AND @IncludeRegularInvcType=1)  
	OR (o.RecType=5 AND  @IncludeProformaInvcType=1))
	INNER JOIN dbo.tblArCust c (nolock) ON o.CustId = c.CustId
WHERE (@PrintAllInBase = 1 OR o.CurrencyId = @ReportCurrency)  
	AND (@DistCodeFrom IS NULL OR o.DistCode >= @DistCodeFrom) And (@DistCodeThru IS NULL OR o.DistCode <= @DistCodeThru)
	AND ((o.TransDate < DATEADD(day, 1, @TransactionCutoffDate )And @TransactionCutoffOption = 0) 
		OR ((o.FiscalYear * 1000 + o.GlPeriod <= @TransactionCutoffFiscalyear * 1000 + @TransactionCutoffFiscalPeriod) 
		AND @TransactionCutoffOption = 1)) 
	AND ((((o.SourceApp = 0 OR o.SourceApp = 1 OR o.SourceApp = 4) and @IncludeSaleInvoice = 1)) 
		OR (((o.SourceApp = 3) and @IncludeProjectInvoice = 1)) 
		OR (((o.SourceApp = 2) and @IncludeServiceInvoice = 1)))
	AND c.AcctType = 0 

INSERT INTO #ArInvoice (CustId, InvcNum)    
	SELECT CustId, InvcNum FROM #ArOpenInvoice GROUP BY CustId, InvcNum
	HAVING Sum(AmountDueFgn) <> 0

INSERT INTO #ArInvoice (CustId, InvcNum) 
	SELECT o.CustId, o.InvcNum     --pet 43276 mlc 5/12/04 - use max transdate/pd & year for payment cutoff processing - include invoices with any payments within the range
	FROM (Select RecType, CustId, InvcNum, Max(TransDate) TransDate
		, Max((FiscalYear * 1000) + GlPeriod) TranYearPd, Sum(AmountDueFgn) AmountDueFgn
		From #ArOpenInvoice Where RecType <> 5 Group By RecType, CustId, InvcNum) o 
	Inner Join (Select CustId, InvcNum From #ArOpenInvoice --pet 41242 mlc 10/22/02 - exclude zero amt invoices with no payments
			Where RecType < 0 Group By CustId, InvcNum) pmts
	on o.CustId = pmts.CustId and o.InvcNum = pmts.InvcNum
	left join dbo.tblArCust c on o.CustId = c.CustId
	WHERE (((RecType > 0)
		OR (TransDate >= @PaymentCutoffDate And @PaymentCutoffOption = 0)
		OR (TranYearPd >= ((@PaymentCutoffFiscalYear * 1000) + @PaymentCutoffFiscalPeriod) And @PaymentCutoffOption = 1))
		AND NOT EXISTS (SELECT * FROM #ArInvoice i 
				WHERE i.CustId = o.CustId AND i.InvcNum = o.InvcNum)) 
		GROUP BY o.CustId, o.InvcNum
		HAVING Sum(AmountDueFgn) = 0 
		
INSERT INTO #ArInvoice (CustId, InvcNum) 
	SELECT o.CustId, o.InvcNum     --pet 43276 mlc 5/12/04 - use max transdate/pd & year for payment cutoff processing - include invoices with any payments within the range
	FROM (Select SIGN(AmountDueFgn) AS RecType, CustId, InvcNum, Max(TransDate) TransDate
		, Max((FiscalYear * 1000) + GlPeriod) TranYearPd, Sum(AmountDueFgn) AmountDueFgn
		From #ArOpenInvoice Where RecType = 5 Group By SIGN(AmountDueFgn), CustId, InvcNum) o 
	Inner Join (Select CustId, InvcNum From #ArOpenInvoice --pet 41242 mlc 10/22/02 - exclude zero amt invoices with no payments
			Where RecType = 5 AND AmountDueFgn < 0 Group By CustId, InvcNum) pmts
	on o.CustId = pmts.CustId and o.InvcNum = pmts.InvcNum
	left join dbo.tblArCust c on o.CustId = c.CustId
	WHERE (((RecType > 0)
		OR (TransDate >= @PaymentCutoffDate And @PaymentCutoffOption = 0)
		OR (TranYearPd >= ((@PaymentCutoffFiscalYear * 1000) + @PaymentCutoffFiscalPeriod) And @PaymentCutoffOption = 1))
		AND NOT EXISTS (SELECT * FROM #ArInvoice i 
				WHERE i.CustId = o.CustId AND i.InvcNum = o.InvcNum)) 
		GROUP BY o.CustId, o.InvcNum
		HAVING Sum(AmountDueFgn) = 0 

--process invoices/payments by Min aging date and max rec typ so that over payments on invoices are aged with the invoice
UPDATE #ArInvoice 
SET MinAgingDate = m.MinAgingDate, MaxRecType = m.MaxRecType
From #ArInvoice                      
inner join (SELECT CustId, InvcNum, Max(RecType) MaxRecType
		, Case When Max(RecType) > 0 then Min(InvcDate) Else Min(PmtDate) End MinAgingDate
		From (SELECT CustId, InvcNum, RecType
			, Case When RecType > 0 Then AgingDate Else Null End InvcDate
			, Case When RecType < 0 Then AgingDate Else Null End PmtDate
			FROM #ArOpenInvoice) d
		Group By CustId, InvcNum) m
On #ArInvoice.CustId = m.CustId And #ArInvoice.InvcNum = m.InvcNum 

Update #ArInvoice
Set Unapplied = s.Unapplied, AmtCurrent = s.AmtCurrent
	, AmtDue1 = s.AmtDue1, AmtDue2 = s.AmtDue2, AmtDue3 = s.AmtDue3, AmtDue4 = s.AmtDue4

	, UnappliedFgn = s.UnappliedFgn, AmtCurrentFgn = s.AmtCurrentFgn
	, AmtDue1Fgn = s.AmtDue1Fgn, AmtDue2Fgn = s.AmtDue2Fgn, AmtDue3Fgn = s.AmtDue3Fgn, AmtDue4Fgn = s.AmtDue4Fgn
	, AmountDue = s.AmountDue, AmountDueFgn = s.AmountDueFgn
From #ArInvoice inner join (Select i.CustId, i.InvcNum
	, sum(o.AmountDue) AmountDue, sum(o.AmountDueFgn) AmountDueFgn
	, sum(case when i.maxrectype < 0 then o.AmountDue else 0 end) Unapplied
	, sum(case when i.maxrectype > 0 and i.MinAgingDate >= @PastDueDate1 then o.AmountDue else 0 end) AmtCurrent 
	, sum(case when i.maxrectype > 0 and i.MinAgingDate between @PastDueDate2 and dateadd(day,-1, @PastDueDate1) then o.AmountDue else 0 end) AmtDue1
	, sum(case when i.maxrectype > 0 and i.MinAgingDate between @PastDueDate3 and dateadd(day,-1, @PastDueDate2) then o.AmountDue else 0 end) AmtDue2
	, sum(case when i.maxrectype > 0 and i.MinAgingDate between @PastDueDate4 and dateadd(day,-1, @PastDueDate3) then o.AmountDue else 0 end) AmtDue3
	, sum(case when i.maxrectype > 0 and i.MinAgingDate < @PastDueDate4  then o.AmountDue else 0 end) AmtDue4

	, sum(case when i.maxrectype < 0 then o.AmountDueFgn else 0 end) UnappliedFgn
	, sum(case when i.maxrectype > 0 and i.MinAgingDate >= @PastDueDate1 then o.AmountDueFgn else 0 end) AmtCurrentFgn 
	, sum(case when i.maxrectype > 0 and i.MinAgingDate between @PastDueDate2 and dateadd(day,-1, @PastDueDate1) then o.AmountDueFgn else 0 end) AmtDue1Fgn
	, sum(case when i.maxrectype > 0 and i.MinAgingDate between @PastDueDate3 and dateadd(day,-1, @PastDueDate2) then o.AmountDueFgn else 0 end) AmtDue2Fgn
	, sum(case when i.maxrectype > 0 and i.MinAgingDate between @PastDueDate4 and dateadd(day,-1, @PastDueDate3) then o.AmountDueFgn else 0 end) AmtDue3Fgn
	, sum(case when i.maxrectype > 0 and i.MinAgingDate < @PastDueDate4  then o.AmountDueFgn else 0 end) AmtDue4Fgn
	From #ArInvoice i inner join #ArOpenInvoice o 
	on i.CustId = o.CustId and i.InvcNum = o.InvcNum 
	Group By i.CustId, i.InvcNum) s
	on #ArInvoice.CustId = s.CustId and #ArInvoice.InvcNum = s.InvcNum 

--Note: filtering is done after aging buckets are processed to 
--	ensure proper aging of payments applied to an invoice
--	when some applications are not included
--capture bucketed totals for filtered invoice detail
INSERT INTO #ArAgedTrialBal (CustId, InvcNum, Unapplied, AmtCurrent, AmtDue1, 
	AmtDue2, AmtDue3, AmtDue4, AmountDue)   
SELECT i.CustID, i.InvcNum 
	, CASE WHEN @PrintAllInBase = 1 THEN i.Unapplied ELSE i.UnappliedFgn END
	, CASE WHEN @PrintAllInBase = 1 THEN i.AmtCurrent ELSE i.AmtCurrentFgn END
	, CASE WHEN @PrintAllInBase = 1 THEN i.AmtDue1 ELSE i.AmtDue1Fgn END
	, CASE WHEN @PrintAllInBase = 1 THEN i.AmtDue2 ELSE i.AmtDue2Fgn END
	, CASE WHEN @PrintAllInBase = 1 THEN i.AmtDue3 ELSE i.AmtDue3Fgn END
	, CASE WHEN @PrintAllInBase = 1 THEN i.AmtDue4 ELSE i.AmtDue4Fgn END
	, CASE WHEN @PrintAllInBase = 1 THEN i.AmountDue ELSE i.AmountDueFgn END 	
FROM #ArInvoice i LEFT JOIN dbo.tblArCust c ON i.CustID = c.CustID --capture the customer name

--Balance Forward customer
INSERT INTO #ArAgedTrialBal (CustId, InvcNum, Unapplied, AmtCurrent, AmtDue1, 
	AmtDue2, AmtDue3, AmtDue4, AmountDue)  
SELECT c.CustId, 'BalFwd', 
	CASE WHEN @PrintAllInBase = 1 THEN -ROUND(ISNULL(c.UnapplCredit, 0) / ISNULL(e.ExchangeRate,1), @BaseCurrencyPrecision) 
		ELSE -ISNULL(c.UnapplCredit, 0) END, 
	CASE WHEN @PrintAllInBase = 1 THEN ROUND((ISNULL(c.CurAmtDue, 0) + ISNULL(c.UnpaidFinch, 0)) / ISNULL(e.ExchangeRate,1), @BaseCurrencyPrecision)
		ELSE ISNULL(c.CurAmtDue, 0) + ISNULL(c.UnpaidFinch, 0) END, 
	CASE WHEN @PrintAllInBase = 1 THEN ROUND(ISNULL(c.BalAge1, 0) / ISNULL(e.ExchangeRate,1), @BaseCurrencyPrecision)
		ELSE ISNULL(c.BalAge1, 0) END, 
	CASE WHEN @PrintAllInBase = 1 THEN ROUND(ISNULL(c.BalAge2, 0) / ISNULL(e.ExchangeRate,1), @BaseCurrencyPrecision)
		ELSE ISNULL(c.BalAge2, 0) END, 
	CASE WHEN @PrintAllInBase = 1 THEN ROUND(ISNULL(c.BalAge3, 0) / ISNULL(e.ExchangeRate,1), @BaseCurrencyPrecision)
		ELSE ISNULL(c.BalAge3, 0) END, 
	CASE WHEN @PrintAllInBase = 1 THEN ROUND(ISNULL(c.BalAge4, 0) / ISNULL(e.ExchangeRate,1), @BaseCurrencyPrecision)
		ELSE ISNULL(c.BalAge4, 0) END,
	CASE WHEN @PrintAllInBase = 1 THEN ROUND((-ISNULL(c.UnapplCredit, 0) + ISNULL(c.CurAmtDue, 0) + ISNULL(c.UnpaidFinch, 0) + ISNULL(c.BalAge1, 0) + ISNULL(c.BalAge2, 0) + ISNULL(c.BalAge3, 0) + ISNULL(c.BalAge4, 0)) / ISNULL(e.ExchangeRate,1), @BaseCurrencyPrecision)
		ELSE (-ISNULL(c.UnapplCredit, 0) + ISNULL(c.CurAmtDue, 0) + ISNULL(c.UnpaidFinch, 0) + ISNULL(c.BalAge1, 0) + ISNULL(c.BalAge2, 0) + ISNULL(c.BalAge3, 0) + ISNULL(c.BalAge4, 0)) END
FROM #tmpCustomerList l INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId
	LEFT JOIN #CurrencyInfo e ON c.CurrencyId = e.CurrencyId
WHERE c.AcctType = 1 AND (@PrintAllInBase = 1 OR c.CurrencyId = @ReportCurrency)

SELECT c.CustId, c.CustName, InvcNum, Unapplied, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4
	, AmountDue, cst.GroupCode, cst.ClassId, cst.DistCode AS CustDistCode, cst.CreditLimit, cst.LastPayDate 
FROM #ArAgedTrialBal a 
	INNER JOIN #tmpCustomerList c ON a.CustId = c.CustId 
	INNER JOIN dbo.tblArCust cst ON c.CustId = cst.CustId 
WHERE @IncludeCurrentCustomer = 1 OR c.CustId IN 
	(
		SELECT CustId FROM #ArAgedTrialBal 
		GROUP BY CustId 
		HAVING SUM(AmtDue1 + AmtDue2 + AmtDue3 + AmtDue4) <> 0
	)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAgedTrialBalanceInquiry_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArAgedTrialBalanceInquiry_proc';

