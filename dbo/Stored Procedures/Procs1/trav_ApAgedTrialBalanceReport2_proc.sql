
CREATE PROCEDURE dbo.trav_ApAgedTrialBalanceReport2_proc
@TransactionCutoffOption tinyint, -- Transaction cutoff option (0 = by date, 1 = by gl period & fiscal year)
@TransactionCutoffDate datetime, 
@TransactionCutoffGlPeriod smallint, 
@TransactionCutoffFiscalYear smallint, 
@PaymentCutoffOption tinyint, -- Payment cutoff option (0 = by date, 1 = by gl period & fiscal year)
@PaymentCutoffDate datetime, 
@PaymentCutoffGlPeriod smallint, 
@PaymentCutoffFiscalYear smallint, 
@PastDue bit, 
@PrintBy tinyint, -- Sort By (0 = Vendor ID, 1 = Vendor Name, 2 = Class Code, 3 = Priority Code, 4 = Distribution Code)
@PrintAllInBase bit, 
@ReportCurrency pCurrency, -- Base Currency when @PrintAllInBase = 1
@AgeBy tinyint, -- 0 = Invoice Date, 1 = Due Date
@AgingDate datetime, 
@PastDueDate1 datetime, 
@PastDueDate2 datetime, 
@PastDueDate3 datetime, 
@PastDueDate4 datetime

AS
BEGIN TRY

	CREATE TABLE #ApAgedTrialBal
	(
		VendorId pVendorID, 
		VendDistCode pDistCode, 
		City nvarchar(30), 
		Region nvarchar(10), 
		Country pCountry, 
		VendorClass nvarchar(6), 
		Phone nvarchar(15), 
		InvoiceNum pInvoiceNum, 
		[Status] tinyint, 
		InvcDate datetime, 
		GrossAmtDue pDecimal, 
		PriorityCode nvarchar(1), 
		AmtFuture pDecimal, 
		AmtCurrent pDecimal, 
		AmtDue1 pDecimal, 
		AmtDue2 pDecimal, 
		AmtDue3 pDecimal, 
		AmtDue4 pDecimal, 
		[Type] nchar(3), 
		NetDueDate datetime, 
		DiscDueDate datetime, 
		CheckNum pCheckNum, 
		CheckDate datetime, 
		DiscAmt pDecimal, 
		DistCode pDistcode
	)

	-- Open Invoice
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, InvoiceNum
		, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4
		, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode) 
	SELECT v.VendorID, v.DistCode, v.City, v.Region, v.Country, v.VendorClass, v.Phone, i.InvoiceNum
		, i.[Status], i.InvoiceDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END
		, v.PriorityCode
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) > @AgingDate 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate1 
			AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) <= @AgingDate 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate2 
			AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate1 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate3 
			AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate2 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate4 
			AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate3 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate4 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN i.BaseGrossAmtDue < 0 THEN 'Deb' ELSE 'Inv' END
		, i.NetDueDate, i.DiscDueDate, i.CheckNum, i.CheckDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t 
		INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode 
	WHERE i.[Status] < 3 
		AND 
		(
			(
				(
					(i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate) 
						OR (i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate)
				) 
				AND @TransactionCutoffOption = 0
			) 
			OR (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
					AND @TransactionCutoffOption = 1)
		) 
		AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Check record for paid invoice with invoice date before transaction cutoff date and check date between payment cutoff date and transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, InvoiceNum
		, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4
		, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode) 
	SELECT v.VendorID, v.DistCode, v.City, v.Region, v.Country, v.VendorClass, v.Phone, i.InvoiceNum
		, i.[Status], i.CheckDate
		, -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END)
		, v.PriorityCode, 0, 0, 0, 0, 0, 0, 'Pmt', i.CheckDate, i.DiscDueDate, i.CheckNum, i.CheckDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t 
		INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode 
	WHERE i.[Status] IN (3, 4) 
		AND 
		(
			(
				(
					(i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate) 
						OR (i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate)
				) 
				AND @TransactionCutoffOption = 0
			) 
			OR (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
					AND @TransactionCutoffOption = 1)
		)
		AND 
		(
			(
				(i.CheckDate >= @PaymentCutoffDate AND @PaymentCutoffOption = 0)
					OR (i.CheckYear* 1000 + i.CheckPeriod >= @PaymentCutoffFiscalYear * 1000 + @PaymentCutoffGlPeriod 
							AND @PaymentCutoffOption = 1)
			)
			AND 
			(
				(i.CheckDate <= @TransactionCutoffDate AND @TransactionCutoffOption = 0)
					OR (i.CheckYear* 1000 + i.CheckPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
							AND @TransactionCutoffOption = 1)
			)
		)
		AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Invoice record for paid invoice with invoice date before transaction cutoff date and check date between payment cutoff date and transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, InvoiceNum
		, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4
		, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode) 
	SELECT v.VendorID, v.DistCode, v.City, v.Region, v.Country, v.VendorClass, v.Phone, i.InvoiceNum
		, i.[Status], i.InvoiceDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END
		, v.PriorityCode, 0, 0, 0, 0, 0, 0, CASE WHEN i.BaseGrossAmtDue < 0 THEN 'Deb' ELSE 'Inv' END
		, i.NetDueDate, i.DiscDueDate, i.CheckNum, i.CheckDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t 
		INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode 
	WHERE i.[Status] IN (3, 4) 
		AND 
		(
			(
				(
					(i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate) 
						OR (i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate)
				) AND @TransactionCutoffOption = 0
			) 
			OR (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
					AND @TransactionCutoffOption = 1)
			)
			AND
			(
				(
					(i.CheckDate >= @PaymentCutoffDate AND @PaymentCutoffOption = 0)
						OR (i.CheckYear* 1000 + i.CheckPeriod >= @PaymentCutoffFiscalYear * 1000 + @PaymentCutoffGlPeriod 
								AND @PaymentCutoffOption = 1)
				)
				AND 
				(
					(i.CheckDate <= @TransactionCutoffDate AND @TransactionCutoffOption = 0)
						OR (i.CheckYear* 1000 + i.CheckPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
								AND @TransactionCutoffOption = 1)
				)
		)
		AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Invoice record for paid invoice with invoice date before transaction cutoff date and check date after transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, InvoiceNum
		, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4
		, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode) 
	SELECT v.VendorID, v.DistCode, v.City, v.Region, v.Country, v.VendorClass, v.Phone, i.InvoiceNum
		, 0, i.InvoiceDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END
		, v.PriorityCode
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) > @AgingDate 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate1 
				AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) <= @AgingDate 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate2 
				AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate1 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate3 
				AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate2 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate4 
				AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate3 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate4 
			THEN (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN i.BaseGrossAmtDue < 0 THEN 'Deb' ELSE 'Inv' END
		, i.NetDueDate, i.DiscDueDate, i.CheckNum, i.CheckDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t 
		INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode 
	WHERE i.[Status] IN (3, 4) 
		AND 
		(
			(
				(
					(i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate) 
						OR (i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate)
				) AND @TransactionCutoffOption = 0
			) 
			OR (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
					AND @TransactionCutoffOption = 1)
		)
		AND 
		(
			(i.CheckDate > @TransactionCutoffDate AND @TransactionCutoffOption = 0)
				OR (i.CheckYear* 1000 + i.CheckPeriod > @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
						AND @TransactionCutoffOption = 1)
		)
		AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Check record for paid invoice with invoice date after transaction cutoff date and check date between payment cutoff date and transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, InvoiceNum
		, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4
		, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode) 
	SELECT v.VendorID, v.DistCode, v.City, v.Region, v.Country, v.VendorClass, v.Phone, i.InvoiceNum
		, i.[Status], i.CheckDate
		, -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END)
		, v.PriorityCode
		, CASE WHEN i.CheckDate > @AgingDate 
			THEN -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN i.CheckDate >= @PastDueDate1 AND i.CheckDate <= @AgingDate 
			THEN -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN i.CheckDate >= @PastDueDate2 AND i.CheckDate < @PastDueDate1 
			THEN -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN i.CheckDate >= @PastDueDate3 AND i.CheckDate < @PastDueDate2 
			THEN -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN i.CheckDate >= @PastDueDate4 AND i.CheckDate < @PastDueDate3 
			THEN -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END
		, CASE WHEN i.CheckDate < @PastDueDate4 
			THEN -1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) 
			ELSE 0 END, 'Pmt'
		, i.CheckDate, i.DiscDueDate, i.CheckNum, i.CheckDate
		, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t 
		INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode 
	WHERE i.[Status] IN (3, 4) 
		AND 
		(
			(
				(
					(i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate > @TransactionCutoffDate) 
						OR (i.VoidCreatedDate IS NULL AND i.InvoiceDate > @TransactionCutoffDate)
				) AND @TransactionCutoffOption = 0
			) 
			OR (i.FiscalYear * 1000 + i.GlPeriod > @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
					AND @TransactionCutoffOption = 1)
		)
		AND 
		(
			(
				(i.CheckDate >= @PaymentCutoffDate AND @PaymentCutoffOption = 0)
					OR (i.CheckYear* 1000 + i.CheckPeriod >= @PaymentCutoffFiscalYear * 1000 + @PaymentCutoffGlPeriod 
							AND @PaymentCutoffOption = 1)
			)
			AND 
			(
				(i.CheckDate <= @TransactionCutoffDate AND @TransactionCutoffOption = 0)
					OR (i.CheckYear* 1000 + i.CheckPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod 
							AND @TransactionCutoffOption = 1)
			)
		)
		AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	IF @PastDue = 1
	BEGIN
		SELECT a.*, l.Name AS VendorName
			, CASE @PrintBy 
				WHEN 0 THEN a.VendorId 
				WHEN 1 THEN l.Name 
				WHEN 2 THEN a.VendorClass 
				WHEN 3 THEN a.PriorityCode 
				WHEN 4 THEN a.DistCode 
				END AS GrpId
			, CAST(CONVERT(nvarchar(8), CASE WHEN @AgeBy = 0 THEN a.InvcDate ELSE a.NetDueDate END, 112) AS nvarchar) AS InvcDateSortBy 
		FROM #ApAgedTrialBal a 
			INNER JOIN #tmpVendorList l ON a.VendorId=l.VendorId 
		WHERE a.VendorId IN 
		(
			SELECT i.VendorId FROM #tmpVendorList t 
				INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
				INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode 
			WHERE i.BaseGrossAmtDue > 0 AND [Status] <> 4 
			GROUP BY i.VendorId 
			HAVING MIN((CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END)) < @PastDueDate1
		)
	END
	ELSE
	BEGIN
		SELECT a.*, l.Name AS VendorName
			, CASE @PrintBy 
				WHEN 0 THEN a.VendorId 
				WHEN 1 THEN l.Name 
				WHEN 2 THEN a.VendorClass 
				WHEN 3 THEN a.PriorityCode 
				WHEN 4 THEN a.DistCode 
				END AS GrpId
			, CAST(CONVERT(nvarchar(8), CASE WHEN @AgeBy = 0 THEN a.InvcDate ELSE a.NetDueDate END, 112) AS nvarchar) AS InvcDateSortBy 
		FROM #ApAgedTrialBal a INNER JOIN #tmpVendorList l ON a.VendorId = l.VendorId
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApAgedTrialBalanceReport2_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApAgedTrialBalanceReport2_proc';

