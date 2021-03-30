
CREATE PROCEDURE [dbo].[trav_ArInvoiceAging_proc]
@AgingDate datetime, --base date for the aging dates
@InvcFinch pInvoiceNum, --Finance charge invoice number
@AgeUnappliedCredits bit = 0 --option to age unapplied payments
AS
SET NOCOUNT ON
BEGIN TRY
--MOD:Finance Charge Enhancements

	DECLARE @Day1 datetime, @Day2 datetime, @Day3 datetime, @Day4 datetime
	DECLARE @MaxInvcAgingDate datetime, @MaxPmtAgingDate datetime

	--expects the list of invoices to age to be provided via the #AgeInvoiceList table
	--CREATE TABLE #AgeInvoiceList 
	--(
	--	CustId pCustId, InvcNum pInvoiceNum, RecType smallint, AgingDate datetime, AmountDue pDecimal default(0)
	--) 

	CREATE TABLE #InvoiceAgingBuckets
	(
		CustId pCustId, 
		InvcNum pInvoiceNum, 
		MinAgingDate datetime NULL, 
		MaxRecType smallint, 
		UnappliedCredit pDecimal DEFAULT(0), 
		UnpaidFinch pDecimal DEFAULT(0),
		AmtCurrent pDecimal DEFAULT(0), 
		AmtDue1 pDecimal DEFAULT(0), 
		AmtDue2 pDecimal DEFAULT(0), 
		AmtDue3 pDecimal DEFAULT(0), 
		AmtDue4 pDecimal DEFAULT(0), 
		PRIMARY KEY (CustId, InvcNum)
	)


	--Set each aging dates based upon the initial aging date
	SELECT @Day1 = DATEADD(DAY, -30, @AgingDate)
		, @Day2 = DATEADD(DAY, -60, @AgingDate)
		, @Day3 = DATEADD(DAY, -90, @AgingDate)
		, @Day4 = DATEADD(DAY, -120, @AgingDate)


	--initialize the list of aged values for invoices with an outstanding balance
	INSERT INTO #InvoiceAgingBuckets (CustId, InvcNum) 
	SELECT CustId, InvcNum 
	FROM #AgeInvoiceList 
	GROUP BY CustId, InvcNum
	HAVING SUM(SIGN(RecType) * AmountDue) <> 0


	--capture the max invoice and payment dates for calculating the MinAgingDates
	SELECT @MaxInvcAgingDate = MAX(AgingDate) FROM #AgeInvoiceList WHERE RecType > 0 AND NOT(AgingDate IS NULL)
	SELECT @MaxPmtAgingDate = MAX(AgingDate) FROM #AgeInvoiceList WHERE RecType < 0 AND NOT(AgingDate IS NULL)
	SELECT @MaxInvcAgingDate = COALESCE(@MaxInvcAgingDate, GETDATE()), @MaxPmtAgingDate = COALESCE(@MaxPmtAgingDate, GETDATE())


	--process invoices/payments by Min aging date and max rec typ so that over payments on invoices are aged with the invoice
	UPDATE #InvoiceAgingBuckets 
		SET MinAgingDate = m.MinAgingDate, MaxRecType = m.MaxRecType
		FROM #InvoiceAgingBuckets 
		INNER JOIN (SELECT CustId, InvcNum, Max(RecType) MaxRecType, CASE WHEN Max(RecType) > 0 THEN Min(InvcDate) ELSE Min(PmtDate) END MinAgingDate
				FROM (SELECT CustId, InvcNum, ISNULL(RecType, 1) RecType
						, CASE WHEN ISNULL(RecType, 1) > 0 THEN AgingDate ELSE @MaxInvcAgingDate END InvcDate
						, Case When ISNULL(RecType, 1) < 0 THEN AgingDate ELSE @MaxPmtAgingDate END PmtDate
						FROM #AgeInvoiceList) d	GROUP BY CustId, InvcNum) m
		ON #InvoiceAgingBuckets.CustId = m.CustId AND #InvoiceAgingBuckets.InvcNum = m.InvcNum


	--separate amounts into aging buckets
	UPDATE #InvoiceAgingBuckets
		SET UnappliedCredit = ISNULL(s.UnappliedCredit, 0), UnpaidFinch = ISNULL(s.UnpaidFinch, 0), AmtCurrent = ISNULL(s.AmtCurrent, 0)
			, AmtDue1 = ISNULL(s.AmtDue1, 0), AmtDue2 = ISNULL(s.AmtDue2, 0), AmtDue3 = ISNULL(s.AmtDue3, 0), AmtDue4 = ISNULL(s.AmtDue4, 0)
		FROM #InvoiceAgingBuckets INNER JOIN (SELECT i.CustId, i.InvcNum
			, SUM(CASE WHEN i.MaxRecType = 4 THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) UnpaidFinch
			, SUM(CASE WHEN (i.maxrectype < 0 AND @AgeUnappliedCredits <> 1) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) UnappliedCredit
			, SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate >= @Day1 THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtCurrent
			, SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate BETWEEN @Day2 AND DateAdd(Day, -1, @Day1) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue1
			, SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate BETWEEN @Day3 AND DateAdd(Day, -1, @Day2) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue2
			, SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate BETWEEN @Day4 AND DateAdd(Day, -1, @Day3) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue3
			, SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate < @Day4  THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue4
			FROM #InvoiceAgingBuckets i INNER JOIN #AgeInvoiceList o ON i.CustId = o.CustId AND i.InvcNum = o.InvcNum
			GROUP BY i.CustId, i.InvcNum) s
		ON #InvoiceAgingBuckets.CustId = s.CustId AND #InvoiceAgingBuckets.InvcNum = s.InvcNum


	--return the aged balances by customer and invoice number
	SELECT CustId, InvcNum
		, ISNULL(UnappliedCredit, 0) UnappliedCredit
		, ISNULL(UnpaidFinch, 0) UpaidFinch
		, ISNULL(AmtCurrent, 0) AmtCurrent 
		, ISNULL(AmtDue1, 0) AmtDue1
		, ISNULL(AmtDue2, 0) AmtDue2
		, ISNULL(AmtDue3, 0) AmtDue3
		, ISNULL(AmtDue4, 0) AmtDue4
		FROM #InvoiceAgingBuckets	


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArInvoiceAging_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArInvoiceAging_proc';

