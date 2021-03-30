--MOD:Deposit Invoices - Add parameters for Invoice Type option
CREATE PROCEDURE [dbo].[trav_ArSalesRepAgedTrialBalanceReport_proc]
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
@BaseCurrencyId pCurrency = 'USD', --base currency Id
@AgeBy tinyint = 0, --0;TransDate;1;DueDate;2DiscDueDate
@IncludeSaleInvoice bit = 1,  --Default AR/SO invoices
@IncludeProjectInvoice bit = 1,  --Project invoices     
@IncludeServiceInvoice bit = 1, --Service invoices 
@BaseCurrencyPrecision smallint = 2,
@IncludeRegularInvcType bit=1,    
@IncludeProformaInvcType bit=1    

AS
SET NOCOUNT ON

BEGIN TRY

	CREATE TABLE #CustomerList 
	(
		CustId pCustId, 
		PRIMARY KEY (CustId)
	)

	CREATE TABLE #AgeInvc 
	(
		RecordType tinyint, 		
		GrpId nvarchar(255), 
		CustId pCustId, 
		CustName nvarchar(255), 
		City nvarchar(255), 
		Region nvarchar(255), 
		Country pCountry, 
		Phone nvarchar(255), 
		DfltDistCode pDistCode, 
		CustomerCurrencyId pCurrency, 
		AcctType tinyint, 
		Contact nvarchar(255), 
		CreditLimit pDecimal, 
		SalesRepId pSalesRep, 
		SalesRepName nvarchar(255), 
		CurrencyId pCurrency, 
		InvcNum pInvoiceNum, 
		DistCode pDistCode,
		AgingDate datetime, 
		AmtDue pDecimal DEFAULT(0), 
		AmtDueBase pDecimal DEFAULT(0), 
		RecType smallint, 
		[Status] tinyint Null Default(0), 
		ProjId nvarchar(10) Null, 
		PhaseId nvarchar(10) Null, 
		SourceApp tinyint Null Default(0),
		UnappliedCredit pDecimal DEFAULT(0), 
		AmtCurrent pDecimal DEFAULT(0), 
		AmtDue1 pDecimal DEFAULT(0), 
		AmtDue2 pDecimal DEFAULT(0), 
		AmtDue3 pDecimal DEFAULT(0), 
		AmtDue4 pDecimal DEFAULT(0), 
		UnappliedCreditBase pDec DEFAULT(0), 
		AmtCurrentBase pDec DEFAULT(0), 
		AmtDue1Base pDecimal DEFAULT(0), 
		AmtDue2Base pDecimal DEFAULT(0), 
		AmtDue3Base pDecimal DEFAULT(0), 
		AmtDue4Base pDecimal DEFAULT(0)
	)

	CREATE TABLE #CommInvc
	(
		SalesRepId pSalesRep NULL, 
		CustId pCustId NULL, 
		InvcNum pInvoiceNum NULL, 
		AmtCommission pDecimal DEFAULT(0)
	)

	INSERT INTO #CommInvc (SalesRepId, CustId, InvcNum, AmtCommission) 
	SELECT i.SalesRepID, CustId, InvcNum
		, SUM(ROUND(((CASE PctOfDtl WHEN 0 THEN 0 WHEN 1 THEN (CASE WHEN (PayLines = 1) THEN AmtLines ELSE 0 END 
			+ CASE WHEN (PayTax = 1) THEN AmtTax ELSE 0 END + CASE WHEN (PayFreight = 1) THEN AmtFreight ELSE 0 END 
			+ CASE WHEN (PayMisc = 1) THEN AmtMisc ELSE 0 END) WHEN 2 THEN (CASE WHEN (PayLines = 1) THEN AmtLines ELSE 0 END 
			+ CASE WHEN (PayTax = 1) THEN AmtTax ELSE 0 END + CASE WHEN (PayFreight = 1) THEN AmtFreight ELSE 0 END 
			+ CASE WHEN (PayMisc = 1) THEN AmtMisc ELSE 0 END - AmtCogs) END 
				* (PctInvc / 100) * (CommRateDtl / 100)) - CommPaid), @BaseCurrencyPrecision)) AS Commission 
	FROM dbo.tblArCommInvc i 
		INNER JOIN #SalesRepList r On i.SalesRepId = r.SalesRepId 
	WHERE i.CustId IS NOT NULL -- null Cust Ids are always pd in full
	GROUP BY i.SalesRepID, CustId, InvcNum

	INSERT INTO #CommInvc (SalesRepId, CustId, InvcNum) 
	SELECT c.SalesRepId1, a.CustId, a.InvcNum 
	FROM dbo.tblArOpenInvoice a 
		INNER JOIN dbo.tblArCust c ON a.CustId = c.CustId 
		AND ((a.RecType<>5 AND @IncludeRegularInvcType=1) OR (a.RecType=5 AND  @IncludeProformaInvcType=1))    
		INNER JOIN #SalesRepList r ON c.SalesRepId1 = r.SalesRepId 
		LEFT JOIN #CommInvc i ON c.SalesRepId1 = i.SalesRepId AND c.CustId = i.CustId AND a.InvcNum = i.InvcNum 
	WHERE i.SalesRepId IS NULL AND c.SalesRepId1 IS NOT NULL 
	GROUP BY c.SalesRepId1, a.CustId, a.InvcNum

	--identify the list of customers to age invoices for
	INSERT INTO #CustomerList (CustId) SELECT CustId FROM #CommInvc GROUP BY CustId

	INSERT INTO #AgeInvc
	EXEC dbo.trav_ArAgedTrialBalanceReport_proc @InvcCutoffOpt, @InvcCutoffDate, @InvcCutoffFiscalPeriod, @InvcCutoffFiscalYear
	, @PayCutoffOpt, @PayCutoffDate, @PayCutoffFiscalPeriod, @PayCutoffFiscalYear
	, @AgingDate, @AgingDays1, @AgingDays2, @AgingDays3, @AgingDays4, '', 'zzzzzz', 1
	, @BaseCurrencyId, @AgeBy, 0, 0, 1, 0
	, @IncludeSaleInvoice, @IncludeProjectInvoice, @IncludeServiceInvoice, @BaseCurrencyPrecision
	, @IncludeRegularInvcType, @IncludeProformaInvcType  

	SELECT a.RecordType, a.CustId, a.CustName, i.SalesRepId, r.Name AS SalesRepName
		, a.InvcNum, a.AgingDate, a.AmtDue, a.RecType, a.[Status], a.ProjId, a.PhaseId
		, a.UnappliedCredit, a.AmtCurrent, a.AmtDue1, a.AmtDue2, a.AmtDue3, a.AmtDue4
		, CASE WHEN a.RecordType = 1 THEN i.AmtCommission ELSE 0 END AS AmtCommission 
	FROM #CommInvc i 
		INNER JOIN #AgeInvc a ON i.CustId = a.CustId AND i.InvcNum = a.InvcNum 
		LEFT JOIN dbo.tblArSalesRep r ON i.SalesRepId = r.SalesRepId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSalesRepAgedTrialBalanceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSalesRepAgedTrialBalanceReport_proc';

