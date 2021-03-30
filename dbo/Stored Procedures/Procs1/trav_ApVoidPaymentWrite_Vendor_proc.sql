
CREATE PROCEDURE dbo.trav_ApVoidPaymentWrite_Vendor_proc
AS
BEGIN TRY

	DECLARE @PrecCurr tinyint, @Multicurr bit, @PrintLogInBaseCurrency bit,
		@CurrBase pCurrency

	SELECT @PrecCurr = CAST([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @PrintLogInBaseCurrency = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BaseCurrencyLog'
	SELECT @Multicurr = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @CurrBase = CAST([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @PrecCurr IS NULL OR @PrintLogInBaseCurrency IS NULL OR @Multicurr IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #VendorLastInfo 
	(VendorId pVendorId NOT NULL,
	 CheckNum pCheckNum NOT NULL,
	 CheckDate datetime NOT NULL)

	CREATE TABLE #CheckInfo
	(
	 VendorId pVendorId NOT NULL,
	 CheckNum pCheckNum NOT NULL,
	 CheckDate datetime NOT NULL,
	 PmtAmt pDecimal NOT NULL,
	 PmtAmtFgn pDecimal NOT NULL)

	/*update vendor history detail*/
	SELECT c.VendorID,FiscalYear,GlPeriod,  SUM(CASE WHEN c.CurrencyId = @CurrBase THEN c.GrossAmtDue - c.DiscTaken ELSE ROUND((GrossAmtDuefgn - DiscTakenfgn) / PmtExchRate, @PrecCurr) END) Pmt
		, SUM(DiscTaken) DiscTaken, SUM(GrossAmtDuefgn - DiscTakenfgn) Pmtfgn, SUM(DiscTakenfgn) DiscTakenfgn
		, SUM(DiscLost) DiscLost, SUM(DiscLostfgn) DiscLostfgn
		, SUM(CASE WHEN Ten99InvoiceYN = 1 THEN CASE WHEN c.CurrencyId = @CurrBase THEN c.GrossAmtDue - c.DiscTaken ELSE ROUND((GrossAmtDuefgn - DiscTakenfgn) / PmtExchRate, @PrecCurr) END ELSE 0 END) Ten99Pmt 
	INTO #tmpApVoidChecks 
	FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
	GROUP BY c.VendorID,FiscalYear,GlPeriod, t.[Status]
	HAVING t.[Status] = 0

	UPDATE dbo.tblApVendorHistDetail SET Pmt = dbo.tblApVendorHistDetail.Pmt - t.Pmt, Pmtfgn = dbo.tblApVendorHistDetail.Pmtfgn - t.Pmtfgn
		, DiscTaken = dbo.tblApVendorHistDetail.DiscTaken - t.DiscTaken, DiscTakenfgn = dbo.tblApVendorHistDetail.DiscTakenfgn - t.DiscTakenfgn
		, DiscLost = dbo.tblApVendorHistDetail.DiscLost - t.DiscLost, DiscLostfgn = dbo.tblApVendorHistDetail.DiscLostfgn - t.DiscLostfgn
		, Ten99Pmt = dbo.tblApVendorHistDetail.Ten99Pmt - t.Ten99Pmt
	FROM dbo.tblApVendorHistDetail INNER JOIN #tmpApVoidChecks t ON dbo.tblApVendorHistDetail.VendorID = t.VendorID 
			AND dbo.tblApVendorHistDetail.FiscalYear = t.FiscalYear AND dbo.tblApVendorHistDetail.GLPeriod = t.GlPeriod 

	/*update vendor*/
	UPDATE dbo.tblApVendor SET GrossDue = SumOfGrossAmtDue, GrossDuefgn = SumOfGrossAmtDuefgn,
		Prepaid = t.Prepaid, Prepaidfgn = t.Prepaidfgn 
	FROM dbo.tblApVendor INNER JOIN 
	(SELECT VendorID, SUM(CASE WHEN Status < 3 THEN GrossAmtDue ELSE 0 END) SumOfGrossAmtDue, 
	SUM(CASE WHEN Status < 3 THEN GrossAmtDuefgn ELSE 0 END) SumOfGrossAmtDuefgn,
	SUM(CASE WHEN Status = 3 THEN GrossAmtDue ELSE 0 END) Prepaid, 
	SUM(CASE WHEN Status = 3 THEN GrossAmtDuefgn ELSE 0 END) Prepaidfgn
	FROM dbo.tblApOpenInvoice
	WHERE Status < 4 AND VendorId IN (SELECT c.VendorId FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter AND t.[Status] = 0)
	GROUP BY VendorID) t
	ON dbo.tblApVendor.VendorID = t.VendorID

	INSERT INTO #CheckInfo (VendorId,CheckNum,CheckDate,PmtAmt,PmtAmtFgn)
	SELECT h.VendorId,CheckNum,CheckDate,GrossAmtDue - DiscAmt,GrossAmtDueFgn - DiscAmtFgn
	FROM dbo.tblApCheckHist h
	WHERE VendorId IN (SELECT c.VendorId FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter AND t.[Status] = 0)
		AND VoidYn = 0  

	INSERT INTO #VendorLastInfo (VendorId,CheckNum,CheckDate) 
	SELECT h.VendorId,MAX(h.CheckNum),h.CheckDate
	FROM #CheckInfo h INNER JOIN (SELECT VendorId,MAX(CheckDate) CheckDate
		FROM #CheckInfo GROUP BY VendorId) t 
		ON h.VendorId = t.VendorId and h.CheckDate = t.CheckDate 
	GROUP BY h.VendorId,h.CheckDate

	UPDATE dbo.tblApVendor 
		SET LastPmtDate = v.CheckDate, 
			LastPmtAmt = ISNULL(h.PmtAmt,0),
			LastPmtAmtfgn = ISNULL(h.PmtAmtFgn,0),
			LastCheckNum = v.CheckNum
	FROM dbo.tblApVendor LEFT JOIN #VendorLastInfo v ON dbo.tblApVendor.VendorId = v.VendorId 
		LEFT JOIN #CheckInfo h ON v.VendorId = h.VendorId AND v.CheckNum = h.CheckNum AND v.CheckDate = h.CheckDate 
	WHERE dbo.tblApVendor.VendorId IN (SELECT c.VendorId FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter AND t.[Status] = 0)	

	INSERT INTO #ApVoidPaymentLog(VendorId,InvoiceNumber,InvoiceDate,CheckDate,FiscalYear,UseCheckNumber,GrossAmountDue,DiscountTaken,CurrencyId, VoidBankId,[Status], VendorName)
	SELECT c.VendorId, c.InvoiceNum AS InvoiceNumber, c.InvoiceDate, c.CheckDate, c.FiscalYear , 
		CASE WHEN c.CheckNum = '' THEN NULL ELSE c.CheckNum END AS UseCheckNumber, 
		CASE WHEN @PrintLogInBaseCurrency = 1 THEN 
			CASE WHEN @Multicurr = 1 AND c.CurrencyId <> @CurrBase 
				THEN (CASE WHEN  PmtType = 3 THEN  ROUND((GrossAmtDueFgn) / PmtExchRate, @PrecCurr) ELSE BaseGrossAmtDue END) 
			ELSE GrossAmtDue END 
		ELSE c.GrossAmtDueFgn END AS GrossAmountDue,
		CASE WHEN @PrintLogInBaseCurrency = 1 THEN DiscTaken ELSE DiscTakenFgn END AS DiscountTaken,
		CASE WHEN @PrintLogInBaseCurrency = 1 THEN @CurrBase ELSE c.CurrencyID END AS CurrencyId, c.VoidBankId, t.[status],v.Name
	FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter
	INNER JOIN dbo.tblApVendor v ON c.VendorID = v.VendorID
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Vendor_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Vendor_proc';

