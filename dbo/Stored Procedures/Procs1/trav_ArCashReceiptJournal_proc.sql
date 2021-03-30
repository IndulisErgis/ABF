
CREATE PROCEDURE dbo.trav_ArCashReceiptJournal_proc
@SortBy tinyint = 0, --0, Customer ID; 1, Fiscal Year/Fiscal Period/Account; 2, Bank Account - Deposit/Batch Code; 3, Deposit/Batch Code; 4, Payment Method
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null, 
@CustomerDepositAccount pGlAcct = NULL
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #Temp
	(
		DepositID pBatchId,
		RcptHeaderID int,
		CustId pCustId Null,
		BankID pBankId Null,
		InvcNum pInvoiceNum Null,
		DistCode pDistCode Null,
		Account pGlAcct Null,
		PmtDate datetime,
		AgingPd smallint, 
		GLPeriod smallint, 
		FiscalYear smallint, 
		PmtMethodId nvarchar(10),
		PmtAmt pDecimal default(0),
		[Difference] pDecimal default(0),
		CheckNum pCheckNum,
		InvcAmt pDecimal default(0), 
		InvcType smallint
	)

	--Build list of payments within given range
	INSERT INTO #Temp (DepositID, RcptHeaderID, CustId, BankID, InvcNum, DistCode, Account, PmtDate
		, AgingPd, GLPeriod, FiscalYear, PmtMethodId, PmtAmt, [Difference], CheckNum, InvcAmt, InvcType)
	SELECT r.DepositID, r.RcptHeaderID, r.CustId, r.BankID, c.InvcNum, c.DistCode
		, CASE WHEN p.PmtType IN (3, 7) THEN ISNULL(b.GlCashAcct, p.GLAcctDebit)	--CreditCard  = 3, External = 7
			WHEN r.CustId Is Null THEN r.GLAcct 
			WHEN c.InvcType = 1 THEN d.GlAcctReceivables 
			WHEN c.InvcType = 5 THEN @CustomerDepositAccount END
		, r.PmtDate, r.AgingPd, r.GLPeriod, r.FiscalYear, r.PmtMethodId
		, CASE WHEN @PrintAllInBase = 1 THEN c.PmtAmt ELSE c.PmtAmtFgn END
		, CASE WHEN @PrintAllInBase = 1 THEN c.[Difference] ELSE c.DifferenceFgn END
		, r.CheckNum, 0, c.InvcType
	FROM #tmpCashReceiptList t INNER JOIN dbo.tblArCashRcptHeader r ON t.RcptHeaderID = r.RcptHeaderID 
		INNER JOIN dbo.tblArCashRcptDetail c ON r.RcptHeaderID = c.RcptHeaderID 
		INNER JOIN dbo.tblArPmtMethod p ON r.PmtMethodId = p.PmtMethodId
		LEFT JOIN dbo.tblArDistCode d ON c.DistCode = d.DistCode 
		LEFT JOIN dbo.tblSmBankAcct b ON p.BankId = b.BankId
	WHERE (@PrintAllInBase = 1 OR r.CurrencyId = @ReportCurrency)
		AND (p.PmtType IN (3,4,5,7) OR (p.PmtType IN (1,2,6) AND r.BankId IN (SELECT BankId FROM #tmpBankAccountList))) 
		AND (r.OrderState = 0 OR r.OrderState & 4 =4)

	--Add gain/loss record
	INSERT INTO #Temp (DepositID, RcptHeaderID, CustId, BankID, InvcNum, DistCode, Account, PmtDate
		, AgingPd, GLPeriod, FiscalYear, PmtMethodId, PmtAmt, [Difference], CheckNum, InvcAmt, InvcType)
	SELECT r.DepositID, r.RcptHeaderID, r.CustId, r.BankID, c.InvcNum, c.DistCode
		, CASE WHEN p.PmtType IN (3, 7) THEN ISNULL(b.GlCashAcct, p.GLAcctDebit)	--CreditCard  = 3, External = 7
			WHEN r.CustId Is Null THEN r.GLAcct 
			WHEN c.InvcType = 1 THEN d.GlAcctReceivables 
			WHEN c.InvcType = 5 THEN @CustomerDepositAccount END
		, r.PmtDate, r.AgingPd, r.GLPeriod, r.FiscalYear, r.PmtMethodId
		, 0	, 0	, r.CheckNum, CASE WHEN @PrintAllInBase = 1 THEN c.CalcGainLoss ELSE 0 END, c.InvcType
	FROM #tmpCashReceiptList t INNER JOIN dbo.tblArCashRcptHeader r ON t.RcptHeaderID = r.RcptHeaderID 
		INNER JOIN dbo.tblArCashRcptDetail c ON r.RcptHeaderID = c.RcptHeaderID 
		INNER JOIN dbo.tblArPmtMethod p ON r.PmtMethodId = p.PmtMethodId
		LEFT JOIN dbo.tblArDistCode d ON c.DistCode = d.DistCode 
		LEFT JOIN dbo.tblSmBankAcct b ON p.BankId = b.BankId
	WHERE (@PrintAllInBase = 1 OR r.CurrencyId = @ReportCurrency)
		AND (p.PmtType IN (3,4,5,7) OR (p.PmtType IN (1,2,6) AND r.BankId IN (SELECT BankId FROM #tmpBankAccountList))) 
		AND (r.OrderState = 0 OR r.OrderState & 4 =4)
		AND c.CalcGainLoss <> 0

	--append invoices into table where payments exist for the given customer and invoice number
	INSERT INTO #Temp (DepositID, RcptHeaderID, CustId, BankID, InvcNum, DistCode, Account, PmtDate
		, AgingPd, GLPeriod, FiscalYear, PmtMethodId, PmtAmt, [Difference], CheckNum, InvcAmt)
	SELECT t.DepositID, t.RcptHeaderID, o.CustId, t.BankID, o.InvcNum, o.DistCode
		, t.Account, t.PmtDate, t.AgingPd, t.GLPeriod, t.FiscalYear, t.PmtMethodId
		, 0, 0, t.CheckNum
		, SIGN(o.RecType) * CASE WHEN @PrintAllInBase = 1 THEN  o.Amt ELSE o.AmtFgn END
	FROM (SELECT DISTINCT CustId, InvcNum, DepositID, RcptHeaderID, BankID, PmtDate, AgingPD, GlPeriod
		, FiscalYear, PmtMethodId, CheckNum, InvcType, Account FROM #Temp) t
		INNER JOIN dbo.tblArOpenInvoice o ON t.CustId = o.CustId AND t.InvcNum = o.InvcNum 
			AND t.InvcType = CASE o.RecType WHEN 5 THEN 5 ELSE 1 END

	--SELECT from temp table with grouping fields
	SELECT CASE @SortBy
			WHEN 0 THEN CustId
			WHEN 1 THEN substring('0000' + CAST(FiscalYear AS nvarchar), len('0000' + CAST(FiscalYear AS nvarchar)) - 3, 4) + substring('0000' + CAST(GLPeriod AS nvarchar), len('0000' + CAST(GLPeriod AS nvarchar)) - 3, 4)
			WHEN 2 THEN BankId
			WHEN 3 THEN DepositId
			WHEN 4 THEN PmtMethodId
			END AS GrpId1
		, CASE @SortBy
			WHEN 0 THEN InvcNum
			WHEN 1 THEN Account
			WHEN 2 THEN DepositId
			WHEN 3 THEN CAST(RcptHeaderId AS nvarchar)
			WHEN 4 THEN InvcNum
			END AS GrpId2
		, CASE @SortBy
			WHEN 0 THEN CAST(RcptHeaderId AS nvarchar)
			WHEN 1 THEN CAST(RcptHeaderId AS nvarchar)
			WHEN 2 THEN CAST(RcptHeaderId AS nvarchar)
			WHEN 3 THEN InvcNum
			WHEN 4 THEN CAST(RcptHeaderId AS nvarchar)
			END AS GrpId3
		, DepositID, RcptHeaderID, CustId, BankID, InvcNum, Account, PmtDate
		, AgingPd, GLPeriod, FiscalYear, PmtMethodId, CheckNum
		, SUM(PmtAmt) PmtAmt, SUM([Difference]) [Difference], SUM(InvcAmt) InvcAmt, SUM(InvcAmt - PmtAmt - [Difference]) Balance
	From #Temp
	GROUP BY DepositID, RcptHeaderID, CustId, BankID, InvcNum, Account, PmtDate
		, AgingPd, GLPeriod, FiscalYear, PmtMethodId, CheckNum

	--Gains/Losses, cash receipts
	--original invoice exchange rate is not returned for credit memos - could consider calculating it from payment & gain/loss accounts
	SELECT p.CurrencyId, p.InvcNum, p.InvcTransID, p.CustId, p.PmtDate, p.PmtAmt , p.PmtAmtFgn
		, (p.PmtAmt - p.CalcGainLoss) InvcAmt, i.InvcExchRate,CalcGainLoss, p.ExchRate, p.BatchID
	FROM (
			SELECT h.CustId, d.InvcNum, h.InvcTransID, h.PmtDate, d.PmtAmt, d.PmtAmtFgn, h.CurrencyId, h.ExchRate
			,d.CalcGainLoss, h.DepositID AS BatchID 
			FROM #tmpCashReceiptList t INNER JOIN dbo.tblArCashRcptHeader h (NOLOCK) ON t.RcptHeaderID = h.RcptHeaderID 
				INNER JOIN dbo.tblArCashRcptDetail d (NOLOCK)  ON h.RcptHeaderID = d.RcptHeaderID
			WHERE d.CalcGainLoss <> 0 AND ((h.InvcTransId IS NULL) OR (h.InvcTransId NOT IN (SELECT TransId FROM dbo.tblArTransHeader))) --exclude prepayments for unposted transactions
			AND (h.OrderState = 0 OR h.OrderState & 4 =4)
		 ) p
		LEFT JOIN 
		(
			SELECT o.CustId, o.InvcNum, o.TransID, o.ExchRate AS InvcExchRate
			FROM dbo.trav_ArOrgInvcInfo_view l --limit to most current invoice
				INNER JOIN dbo.tblArOpenInvoice o ON l.Counter = o.Counter
		) i	ON p.CustId = i.CustId AND p.InvcNum = i.InvcNum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptJournal_proc';

