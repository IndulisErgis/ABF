
CREATE PROCEDURE [dbo].[trav_ArPrintStatements_proc]
@CutoffDate datetime, 
@ClosingDate datetime, 
@StatementDate datetime, 
@InvcFinch pInvoiceNum, --Finance charge invoice number
@PrintStatements tinyint = 0, -- 0 = All, 1 = With Activity, 2 = Nonzero balances, 3 = Positive balances, 4 = 30+, 5 = 60+, 6 = 90+
@ApplyUnappliedCreditToOldest bit = 1,
@InvoiceSort tinyint = 1 -- Invoice Sort option (0 = Invoice number, 1 = Invoice Date)
AS
SET NOCOUNT ON
BEGIN TRY

	--expects the list of customers to be provided via the #CustomerList table
	--CREATE TABLE #CustomerList (CustId pCustId, PRIMARY KEY (CustId))

	--setup a temp table for the invoices to age
	CREATE TABLE #AgeInvoiceList 
	(
		CustId pCustId, 
		InvcNum pInvoiceNum, 
		RecType smallint, 
		AgingDate datetime, 
		AmountDue pDecimal default(0)
	) 

	--setup a table to capture the aged invoice detail
	CREATE TABLE #InvoiceAging
	(
		CustId pCustId, 
		InvcNum pInvoiceNum, 
		UnappliedCredit pDecimal DEFAULT(0), 
		UnpaidFinch pDecimal DEFAULT(0),
		AmtCurrent pDecimal DEFAULT(0), 
		AmtDue1 pDecimal DEFAULT(0), 
		AmtDue2 pDecimal DEFAULT(0), 
		AmtDue3 pDecimal DEFAULT(0), 
		AmtDue4 pDecimal DEFAULT(0), 
		PRIMARY KEY (CustId, InvcNum)
	)

	--setup a table to capture invoice activity
	CREATE TABLE #InvoiceActivity
	(
		[Counter] INT,
		CustId pCustId, 
		CurrencyId pCurrency,
		InvcNum pInvoiceNum, 
		TransDate datetime, 
		RecType smallint, 
		CheckNum nvarchar(25) NULL, 
		Charges pDecimal DEFAULT(0), 
		Credits pDecimal DEFAULT(0),
		AmountDue pDecimal DEFAULT(0), 
		GroupType tinyint NOT NULL,
		PRIMARY KEY ([Counter])
	)

	--setup a table for the customer summary
	CREATE TABLE #CustomerSummary
	(
		CustId pCustId, 
		AcctType tinyint,
		YTDFinch pDecimal DEFAULT(0),
		UnpaidFinch pDecimal DEFAULT(0),
		AmtCurrent pDecimal DEFAULT(0), 
		AmtDue1 pDecimal DEFAULT(0), 
		AmtDue2 pDecimal DEFAULT(0), 
		AmtDue3 pDecimal DEFAULT(0), 
		AmtDue4 pDecimal DEFAULT(0), 
		UnappliedCredit pDecimal DEFAULT(0), 
		PRIMARY KEY (CustId)
	)


	--=========================
	--Balance Forward Customers
	--=========================

	--populate the customer summary with any balance forward customers
	INSERT INTO #CustomerSummary (CustId, AcctType, YTDFinch, UnpaidFinch
		, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4, UnappliedCredit)
	SELECT l.CustId, AcctType, 0, ISNULL(c.NewFinch, 0) + ISNULL(c.UnpaidFinch, 0)
		, ISNULL(c.CurAmtDue, 0), ISNULL(c.BalAge1, 0), ISNULL(c.BalAge2, 0)
		, ISNULL(c.BalAge3, 0), ISNULL(c.BalAge4, 0), ISNULL(c.UnapplCredit, 0)
	FROM #CustomerList l
	INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId
	WHERE c.AcctType = 1
		AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3)

	--rollup the available UnappliedCredit for each balance forward customer
	--	(flip the sign on any existing credit and move any negative bucketed balances into the credit column)
	IF EXISTS (SELECT * FROM #CustomerSummary WHERE AcctType = 1)
	BEGIN
		UPDATE #CustomerSummary SET UnappliedCredit = -UnappliedCredit
			
		UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtCurrent, AmtCurrent = 0 WHERE AmtCurrent < 0

		UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue1, AmtDue1 = 0 WHERE AmtDue1 < 0

		UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue2, AmtDue2 = 0 WHERE AmtDue2 < 0

		UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue3, AmtDue3 = 0 WHERE AmtDue3 < 0

		UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue4, AmtDue4 = 0 WHERE AmtDue4 < 0

		UPDATE #CustomerSummary SET UnappliedCredit = UnpaidFinch + UnappliedCredit, UnpaidFinch = 0 WHERE UnpaidFinch < 0

		--distribute the UnappliedCredit 
		IF @ApplyUnappliedCreditToOldest = 1
		BEGIN
			UPDATE #CustomerSummary SET UnpaidFinch = UnpaidFinch + UnappliedCredit, UnappliedCredit = UnpaidFinch + UnappliedCredit WHERE UnappliedCredit < 0

			UPDATE #CustomerSummary SET AmtDue4 = AmtDue4 + UnappliedCredit, UnappliedCredit = AmtDue4 + UnappliedCredit WHERE UnappliedCredit < 0
		 
			UPDATE #CustomerSummary SET AmtDue3 = AmtDue3 + UnappliedCredit, UnappliedCredit = AmtDue3 + UnappliedCredit WHERE UnappliedCredit < 0
		 
			UPDATE #CustomerSummary SET AmtDue2 = AmtDue2 + UnappliedCredit, UnappliedCredit = AmtDue2 + UnappliedCredit WHERE UnappliedCredit < 0
		 
			UPDATE #CustomerSummary SET AmtDue1 = AmtDue1 + UnappliedCredit, UnappliedCredit = AmtDue1 + UnappliedCredit WHERE UnappliedCredit < 0
		 
			UPDATE #CustomerSummary SET AmtCurrent = AmtCurrent + UnappliedCredit, UnappliedCredit = AmtCurrent + UnappliedCredit WHERE UnappliedCredit < 0
		END
		ELSE   --DO NOT APPLY TO OLDEST FIRST
		BEGIN
			UPDATE #CustomerSummary SET AmtCurrent = AmtCurrent + UnappliedCredit, UnappliedCredit = AmtCurrent + UnappliedCredit WHERE UnappliedCredit < 0 AND AmtCurrent > 0

			UPDATE #CustomerSummary SET AmtDue1 = AmtDue1 + UnappliedCredit, UnappliedCredit = AmtDue1 + UnappliedCredit WHERE UnappliedCredit < 0
		 
			UPDATE #CustomerSummary SET AmtDue2 = AmtDue2 + UnappliedCredit, UnappliedCredit = AmtDue2 + UnappliedCredit WHERE UnappliedCredit < 0

			UPDATE #CustomerSummary SET AmtDue3 = AmtDue3 + UnappliedCredit, UnappliedCredit = AmtDue3 + UnappliedCredit WHERE UnappliedCredit < 0
		 
			UPDATE #CustomerSummary SET AmtDue4 = AmtDue4 + UnappliedCredit, UnappliedCredit = AmtDue4 + UnappliedCredit WHERE UnappliedCredit < 0
		 
			UPDATE #CustomerSummary SET UnpaidFinch = UnpaidFinch + UnappliedCredit, UnappliedCredit = UnpaidFinch + UnappliedCredit WHERE UnappliedCredit < 0

			-- put remaining UnappliedCredit into curamt 
			UPDATE #CustomerSummary SET AmtCurrent = AmtCurrent + UnappliedCredit, UnappliedCredit = AmtCurrent + UnappliedCredit WHERE UnappliedCredit < 0 AND AmtCurrent > 0
		END

		--adjust each bucket for over applied UnappliedCredit
		UPDATE #CustomerSummary
			SET AmtCurrent = CASE WHEN AmtCurrent > 0 THEN AmtCurrent ELSE 0 END
			, AmtDue1 = CASE WHEN AmtDue1 > 0 THEN AmtDue1 ELSE 0 END
			, AmtDue2 = CASE WHEN AmtDue2 > 0 THEN AmtDue2 ELSE 0 END
			, AmtDue3 = CASE WHEN AmtDue3 > 0 THEN AmtDue3 ELSE 0 END
			, AmtDue4 = CASE WHEN AmtDue4 > 0 THEN AmtDue4 ELSE 0 END
			, UnpaidFinch = CASE WHEN UnpaidFinch > 0 THEN UnpaidFinch ELSE 0 END
			, UnappliedCredit = CASE WHEN UnappliedCredit < 0 THEN ABS(UnappliedCredit) ELSE 0 END
	END


	--=========================
	--Open Invoice Customers
	--=========================

	--build the list of invoices to age for open invoice customers
	--	non-held invoices for open invoice customers 
	INSERT INTO #AgeInvoiceList (CustId, InvcNum, RecType, AgingDate, AmountDue)
		SELECT i.CustId, i.InvcNum, i.RecType, CONVERT(nvarchar(8), i.TransDate, 112), i.AmtFgn
		FROM #CustomerList l
		INNER JOIN dbo.tblArOpenInvoice i on l.CustId = i.CustId
		INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId
		WHERE c.AcctType = 0 AND i.TransDate < DATEADD(day, 1, @CutoffDate) AND i.[Status] <> 1
			AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice

	--issue an aging of the identified invoices
	INSERT INTO #InvoiceAging
	EXEC dbo.trav_ArInvoiceAging_proc @StatementDate, @InvcFinch, 1


	--populate the customer summary with any open invoice customers
	--	use aged balances for open invoice customers
	--  capture the YTD finance charges from history
	INSERT INTO #CustomerSummary (CustId, AcctType, YTDFinch, UnpaidFinch
		, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4, UnappliedCredit)
	SELECT l.CustId, AcctType, 0, ISNULL(c.NewFinch, 0) + ISNULL(b.UnpaidFinch, 0) 
		, ISNULL(b.AmtCurrent, 0), ISNULL(b.AmtDue1, 0), ISNULL(b.AmtDue2, 0)
		, ISNULL(b.AmtDue3, 0), ISNULL(b.AmtDue4, 0), ISNULL(b.UnappliedCredit, 0)
	FROM #CustomerList l
	INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId
	LEFT JOIN (SELECT CustId, SUM(UnappliedCredit) UnappliedCredit
		, SUM(UnpaidFinch) UnpaidFinch, SUM(AmtCurrent) AmtCurrent
		, SUM(AmtDue1) AmtDue1, SUM(AmtDue2) AmtDue2, SUM(AmtDue3) AmtDue3, SUM(AmtDue4) AmtDue4
		FROM #InvoiceAging
		GROUP BY CustId) b ON l.CustId = b.CustId
	WHERE c.AcctType = 0
		AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3)


	--===================
	--All customers types
	--===================
	--capture the invoice activity for all customers
	--	exclude gain/loss entries - cutoff date doesn't apply to balance forward customers
	INSERT INTO #InvoiceActivity ([Counter], CustId, CurrencyId
		, InvcNum, TransDate, RecType, CheckNum, Charges, Credits, AmountDue, GroupType)
	SELECT i.[Counter], i.CustId, i.CurrencyId
		, i.InvcNum, CONVERT(nvarchar(8), i.TransDate, 112), i.RecType
		, CASE WHEN i.Rectype = 1 OR i.Rectype = -1 THEN i.CustPONum ELSE CheckNum END AS CheckNum
		, CASE WHEN i.RecType > 0 THEN AmtFgn ELSE 0 END AS Charges
		, CASE WHEN i.RecType < 0 THEN AmtFgn ELSE 0 END AS Credits
		, SIGN(i.RecType) * AmtFgn AS AmountDue, 0
	FROM #CustomerList l
	INNER JOIN dbo.tblArOpenInvoice i ON l.CustId = i.CustId
	INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId 
	WHERE ((i.TransDate < DATEADD(day, 1, @CutoffDate) AND c.AcctType = 0) OR c.AcctType = 1) 
		AND i.[Status] = 0 AND i.Rectype <> -3 --exclude gain/loss invoices
		AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice
	UNION ALL
	SELECT i.[Counter], i.CustId, i.CurrencyId
		, i.InvcNum, CONVERT(nvarchar(8), i.TransDate, 112), i.RecType
		, CASE WHEN i.AmtFgn > 0 THEN i.CustPONum ELSE CheckNum END AS CheckNum
		, CASE WHEN i.AmtFgn > 0 THEN AmtFgn ELSE 0 END AS Charges
		, CASE WHEN i.AmtFgn < 0 THEN -AmtFgn ELSE 0 END AS Credits
		, AmtFgn AS AmountDue, 1
	FROM #CustomerList l
	INNER JOIN dbo.tblArOpenInvoice i ON l.CustId = i.CustId
	INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId 
	WHERE ((i.TransDate < DATEADD(day, 1, @CutoffDate) AND c.AcctType = 0) OR c.AcctType = 1) 
		AND i.[Status] = 0 AND i.Rectype = 5 --Only pro forma invoice
		AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3)


	--lookup the fiscal year and period based upon the cutoff date
	DECLARE @FiscalYear smallint, @FiscalPeriod smallint

	SELECT @FiscalYear = GlYear, @FiscalPeriod = GlPeriod
	FROM dbo.tblSmPeriodConversion 
	WHERE @CutoffDate BETWEEN BegDate AND EndDate

	--  capture the YTD finance charges from history
	UPDATE #CustomerSummary SET YTDFinch = ISNULL(finch.YTDFinch, 0)
	FROM (SELECT f.CustId, SUM(f.FinchAmtFgn) YTDFinch 
		FROM dbo.tblArHistFinch f
		WHERE f.FiscalYear = @FiscalYear AND f.GlPeriod <= @FiscalPeriod
		GROUP BY f.CustId) finch
	WHERE #CustomerSummary.CustId = finch.CustId


	--==============
	--return results
	--==============	

	--retrieve the customer balance resultset
	SELECT @StatementDate AS StatementDate, @ClosingDate AS ClosingDate, @CutoffDate AS CutoffDate
		, c.CustId, c.CurrencyId, c.CustName, c.Attn, c.Addr1, c.Addr2, c.City, c.Region, c.PostalCode, c.Country
		, c.TaxExemptId, (c.CreditLimit - c.CurAmtDue) AS RemainingCredit
		, c.CalcFinch, s.YTDFinch, c.NewFinch, s.UnpaidFinch AS Finch
		, (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) AS TotalAmountDue
		, (s.AmtCurrent - s.UnappliedCredit) AS CurrentAmountDue
		, s.AmtDue1 AS Balance31To60
		, s.AmtDue2 AS Balance61To90
		, (s.AmtDue3 + s.AmtDue4) AS BalanceOver90
		, t.[Desc] AS [Description]
		, CAST(CASE WHEN (s.AmtDue3 + s.AmtDue4) > 0 THEN 3  
			ELSE CASE WHEN s.AmtDue2 > 0 THEN 2
				ELSE CASE WHEN s.AmtDue1 > 0 THEN 1
					ELSE 0 END
				END
			END AS tinyint) AS OldestBalanceId
	FROM #CustomerSummary s
	INNER JOIN dbo.tblArCust c ON s.CustId = c.CustId
	LEFT JOIN dbo.tblArTermsCode t ON c.TermsCode = t.TermsCode 
	WHERE (@PrintStatements = 0) 
		OR (@PrintStatements = 1 AND EXISTS(SELECT * FROM #InvoiceActivity a WHERE a.CustId = s.CustId)) 
		OR (@PrintStatements = 2 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) <> 0) 
		OR (@PrintStatements = 3 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) > 0) 
		OR (@PrintStatements = 4 AND (s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0) 
		OR (@PrintStatements = 5 AND (s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0) 
		OR (@PrintStatements = 6 AND (s.AmtDue3 + s.AmtDue4) > 0) 
	ORDER BY s.CustId	

	--retrieve the invoice detail
	SELECT s.CustId, i.TransDate AS InvoiceDate, i.InvcNum AS InvoiceNo, i.RecType
		, i.CheckNum AS CheckNo, i.Charges, i.Credits, i.Charges - i.Credits AS Balance
		, CASE WHEN @InvoiceSort = 0 THEN i.InvcNum ELSE CONVERT(nvarchar, i.TransDate, 112) END AS GrpId
		, t.InvoiceCount, i.GroupType
	FROM #CustomerSummary s
	INNER JOIN #InvoiceActivity i ON s.CustId = i.CustId
	INNER JOIN (SELECT a.CustId, a.InvcNum, a.GroupType, COUNT(1) AS InvoiceCount
		FROM #InvoiceActivity a
		GROUP BY a.CustId, a.InvcNum, a.GroupType) t
		ON i.CustId = t.CustId AND i.InvcNum = t.InvcNum AND i.GroupType = t.GroupType
	WHERE (@PrintStatements = 0) 
		OR (@PrintStatements = 1 AND EXISTS(SELECT * FROM #InvoiceActivity a WHERE a.CustId = s.CustId)) 
		OR (@PrintStatements = 2 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) <> 0) 
		OR (@PrintStatements = 3 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) > 0) 
		OR (@PrintStatements = 4 AND (s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0) 
		OR (@PrintStatements = 5 AND (s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0) 
		OR (@PrintStatements = 6 AND (s.AmtDue3 + s.AmtDue4) > 0) 
	ORDER BY i.CustId, CASE WHEN @InvoiceSort = 0 THEN i.InvcNum ELSE CONVERT(nvarchar, i.TransDate, 112) END	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrintStatements_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrintStatements_proc';

