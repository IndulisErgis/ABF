
CREATE PROCEDURE dbo.trav_ApAgedTrialBalanceReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD', --Base currency WHEN @PrintAllInBase = 1
@AgeBy tinyint = 0, -- 0, Invoice Date; 1, Due Date
@TransactionCutoffOption tinyint = 0, --Transaction cutoff option (0=by date/1=by gl period & fiscal year) 
@TransactionCutoffDate datetime = '20081204', 
@TransactionCutoffGlPeriod smallint = 12,
@TransactionCutoffFiscalYear smallint = 2008,
@PaymentCutoffDate datetime = '20081104',
@PaymentCutoffGlPeriod smallint = 11,
@PaymentCutoffFiscalYear smallint = 2008,
@PaymentCutoffOption tinyint = 0, --Payment cutoff option (0=by date/1=by gl period & fiscal year)
@AgingDate datetime = '20081204', 
@PastDueDate1 datetime = '20081104', 
@PastDueDate2 datetime = '20081005', 
@PastDueDate3 datetime = '20080905', 
@PastDueDate4 datetime = '20080806',
@PastDue bit = 0

AS
BEGIN TRY

	CREATE TABLE #ApAgedTrialBal
	(VendorId pVendorId, VendDistCode pDistcode, 
	 City nvarchar(30), Region nvarchar(10), Country pCountry, VendorClass nvarchar(6), 
	 Phone nvarchar(15),InvoiceNum pInvoiceNum, Status Tinyint, InvcDate Datetime,
	 GrossAmtDue pDecimal, PriorityCode nvarchar(1), AmtFuture pDecimal, AmtCurrent pDecimal, 
	 AmtDue1 pDecimal, AmtDue2 pDecimal, AmtDue3 pDecimal, AmtDue4 pDecimal, Type nchar(3),
	 NetDueDate Datetime, DiscDueDate Datetime, CheckNum pCheckNum, CheckDate Datetime,DiscAmt pDecimal, DistCode pDistcode)

	-- Open Invoice 
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, 
		InvoiceNum, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, 
		AmtDue3, AmtDue4, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode)
	SELECT v.VendorID,v.DistCode,v.City,v.Region,v.Country,v.VendorClass,v.Phone,
		i.InvoiceNum,i.Status, i.InvoiceDate, 
		CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END ,v.PriorityCode,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) > @AgingDate THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate1 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) <= @AgingDate  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate2 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate1  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate3 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate2  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate4 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate3  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate4 THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN i.BaseGrossAmtDue < 0 THEN 'Deb' ELSE 'Inv' END, 
		i.NetDueDate, i.DiscDueDate, i.CheckNum, i.CheckDate, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode
	WHERE i.Status < 3 
	 AND (((( i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate ) OR ( i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate )) And @TransactionCutoffOption = 0) 
	  Or (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod  And @TransactionCutoffOption = 1))
	 AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Check record for paid invoice with invoice date before transaction cutoff date and check date between payment cutoff date and transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, 
		InvoiceNum, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, 
		AmtDue3, AmtDue4, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode)
	SELECT v.VendorID,v.DistCode,v.City,v.Region,v.Country,v.VendorClass,v.Phone,
		i.InvoiceNum,i.Status,i.CheckDate, -1 *  (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ,v.PriorityCode,
		0,0,0,0,0,0, 'Pmt', 
		i.CheckDate, i.DiscDueDate, i.CheckNum, i.CheckDate, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode
	WHERE i.Status IN (3,4) 
	 AND (((( i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate ) OR ( i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate )) And @TransactionCutoffOption = 0) 
	  Or (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod  And @TransactionCutoffOption = 1))
	 AND (((i.CheckDate >= @PaymentCutoffDate And @PaymentCutoffOption = 0)
	  Or (i.CheckYear* 1000 + i.CheckPeriod >= @PaymentCutoffFiscalYear * 1000 + @PaymentCutoffGlPeriod And @PaymentCutoffOption = 1))
	  AND ((i.CheckDate <= @TransactionCutoffDate And @TransactionCutoffOption = 0)
	  Or (i.CheckYear* 1000 + i.CheckPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod And @TransactionCutoffOption = 1)))
	 AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Invoice record for paid invoice with invoice date before transaction cutoff date and check date between payment cutoff date and transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, 
		InvoiceNum, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, 
		AmtDue3, AmtDue4, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode)
	SELECT v.VendorID,v.DistCode,v.City,v.Region,v.Country,v.VendorClass,v.Phone,
		i.InvoiceNum,i.Status, i.InvoiceDate, CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END ,v.PriorityCode,
		0,0,0,0,0,0, CASE WHEN i.BaseGrossAmtDue < 0 THEN 'Deb' ELSE 'Inv' END, 
		i.NetDueDate, i.DiscDueDate, i.CheckNum, i.CheckDate, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode
	WHERE i.Status IN (3,4) 
	 AND (((( i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate ) OR ( i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate )) And @TransactionCutoffOption = 0) 
	  Or (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod  And @TransactionCutoffOption = 1))
	 AND (((i.CheckDate >= @PaymentCutoffDate And @PaymentCutoffOption = 0)
	  Or (i.CheckYear* 1000 + i.CheckPeriod >= @PaymentCutoffFiscalYear * 1000 + @PaymentCutoffGlPeriod And @PaymentCutoffOption = 1))
	  AND ((i.CheckDate <= @TransactionCutoffDate And @TransactionCutoffOption = 0)
	  Or (i.CheckYear* 1000 + i.CheckPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod And @TransactionCutoffOption = 1)))
	 AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Invoice record for paid invoice with invoice date before transaction cutoff date and check date after transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, 
		InvoiceNum, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, 
		AmtDue3, AmtDue4, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode)
	SELECT v.VendorID,v.DistCode,v.City,v.Region,v.Country,v.VendorClass,v.Phone,
		i.InvoiceNum,0, i.InvoiceDate, 
		CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END ,v.PriorityCode,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) > @AgingDate THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate1 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) <= @AgingDate  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate2 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate1  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate3 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate2  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) >= @PastDueDate4 AND (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate3  THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN (CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END) < @PastDueDate4 THEN 
		(CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN i.BaseGrossAmtDue < 0 THEN 'Deb' ELSE 'Inv' END, 
		i.NetDueDate, i.DiscDueDate, i.CheckNum, i.CheckDate, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode
	WHERE i.Status IN (3,4) 
	 AND (((( i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate < = @TransactionCutoffDate ) OR ( i.VoidCreatedDate IS NULL AND i.InvoiceDate < = @TransactionCutoffDate )) And @TransactionCutoffOption = 0) 
	  Or (i.FiscalYear * 1000 + i.GlPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod  And @TransactionCutoffOption = 1))
	 AND ((i.CheckDate > @TransactionCutoffDate And @TransactionCutoffOption = 0)
	  Or (i.CheckYear* 1000 + i.CheckPeriod > @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod And @TransactionCutoffOption = 1))
	 AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	-- Check record for paid invoice with invoice date after transaction cutoff date and check date between payment cutoff date AND transaction cutoff date.
	INSERT INTO #ApAgedTrialBal(VendorId, VendDistCode, City, Region, Country, VendorClass, Phone, 
		InvoiceNum, [Status], InvcDate, GrossAmtDue, PriorityCode, AmtFuture, AmtCurrent, AmtDue1, AmtDue2, 
		AmtDue3, AmtDue4, [Type], NetDueDate, DiscDueDate, CheckNum, CheckDate, DiscAmt, DistCode)
	SELECT v.VendorID,v.DistCode,v.City,v.Region,v.Country,v.VendorClass,v.Phone,
		i.InvoiceNum,i.Status, i.CheckDate, 
		-1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ,v.PriorityCode,
		CASE WHEN i.CheckDate > @AgingDate THEN 
		-1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN i.CheckDate >= @PastDueDate1 AND i.CheckDate <= @AgingDate  THEN 
		-1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN i.CheckDate >= @PastDueDate2 AND i.CheckDate < @PastDueDate1  THEN 
		-1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN i.CheckDate >= @PastDueDate3 AND i.CheckDate < @PastDueDate2  THEN 
		-1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN i.CheckDate >= @PastDueDate4 AND i.CheckDate < @PastDueDate3  THEN 
		-1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,
		CASE WHEN i.CheckDate < @PastDueDate4 THEN 
		-1 * (CASE WHEN @PrintAllInBase = 1 THEN i.BaseGrossAmtDue ELSE i.GrossAmtDueFgn END) ELSE 0 END,'Pmt', 
		i.CheckDate, i.DiscDueDate, i.CheckNum, i.CheckDate, CASE WHEN @PrintAllInBase = 1 THEN i.DiscAmt ELSE i.DiscAmtFgn END, i.DistCode 
	FROM #tmpVendorList t INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON i.VendorID = v.VendorID 
		INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode
	WHERE i.Status IN (3,4) 
	 AND (((( i.VoidCreatedDate IS NOT NULL AND i.VoidCreatedDate > @TransactionCutoffDate ) OR ( i.VoidCreatedDate IS NULL AND i.InvoiceDate > @TransactionCutoffDate )) And @TransactionCutoffOption = 0) 
	  Or (i.FiscalYear * 1000 + i.GlPeriod > @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod  And @TransactionCutoffOption = 1))
	 AND (((i.CheckDate >= @PaymentCutoffDate And @PaymentCutoffOption = 0)
	  Or (i.CheckYear* 1000 + i.CheckPeriod >= @PaymentCutoffFiscalYear * 1000 + @PaymentCutoffGlPeriod And @PaymentCutoffOption = 1))
	  AND ((i.CheckDate <= @TransactionCutoffDate And @TransactionCutoffOption = 0)
	  Or (i.CheckYear* 1000 + i.CheckPeriod <= @TransactionCutoffFiscalYear * 1000 + @TransactionCutoffGlPeriod And @TransactionCutoffOption = 1)))
	 AND (@PrintAllInBase = 1 OR i.CurrencyId = @ReportCurrency)

	IF @PastDue = 1 
		 SELECT a.*, l.Name as VendorName FROM #ApAgedTrialBal a inner join #tmpVendorList l on a.VendorId=l.VendorId WHERE a.VendorId IN
		 (SELECT i.VendorId FROM #tmpVendorList t INNER JOIN dbo.tblApOpenInvoice i (NOLOCK) ON t.VendorID = i.VendorID 
			INNER JOIN #tmpDistCodeList d ON i.DistCode = d.DistCode
			WHERE i.BaseGrossAmtDue > 0 AND Status <> 4 
			GROUP BY i.VendorId 
			HAVING MIN((CASE @AgeBy WHEN 0 THEN i.InvoiceDate ELSE i.NetDueDate END)) < @PastDueDate1)
	ELSE
	  SELECT a.*, l.Name as VendorName FROM #ApAgedTrialBal a inner join #tmpVendorList l on a.VendorId=l.VendorId
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApAgedTrialBalanceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApAgedTrialBalanceReport_proc';

