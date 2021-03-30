
CREATE PROCEDURE dbo.trav_ApPaymentPost_Vendor_proc
AS
BEGIN TRY

--PET:http://webfront:801/view.php?id=233654
--PET:http://webfront:801/view.php?id=236682
--PET:http://webfront:801/view.php?id=237492
	DECLARE @PrecCurr tinyint, @CurrBase pCurrency

	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @PrecCurr IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #ApPmtPost0 
	(
		VendorID nvarchar(10) NOT NULL, 
		SumOfGrossAmtDue decimal(28,10), 
		SumOfGrossAmtDueFgn decimal(28,10), 
		SumOfPrePay decimal(28,10), 
		SumOfPrePayFgn decimal(28,10), 
		PRIMARY KEY (VendorID)
	)

	CREATE TABLE #temp1 
	(
		VendorID nvarchar(10) NOT NULL, 
		CheckNum nvarchar(10) NULL, 
		FormatCheckNum nvarchar(10) NULL, 
		CheckAmt decimal(28,10) NULL, 
		CheckAmtFgn decimal(28,10) NULL, 
		CheckDate datetime NULL, 
		Status tinyint NULL
	)

	INSERT INTO  #ApPmtPost0 
		SELECT VendorID, 0, 0, 0, 0 
	FROM dbo.tblApPrepChkInvc
	INNER JOIN #PostTransList b ON dbo.tblApPrepChkInvc.BatchId = b.TransId
	GROUP BY VendorID

	/* create missing entries in tblApVendorHistDetail */
	INSERT INTO dbo.tblApVendorHistDetail (VendorID, FiscalYear, GLPeriod) 
	SELECT t.VendorID, t.FiscalYear, t.GlPeriod 
	FROM (SELECT v.VendorID, v.FiscalYear, v.GlPeriod FROM dbo.tblApPrepChkInvc v INNER JOIN #PostTransList b 
			ON v.BatchId = b.TransId GROUP BY v.VendorID, v.FiscalYear, v.GlPeriod) t
		LEFT JOIN dbo.tblApVendorHistDetail h ON t.VendorID = h.VendorID AND t.FiscalYear = h.FiscalYear 
			AND t.GLPeriod = h.GLPeriod 
	WHERE h.VendorID IS NULL

	UPDATE dbo.tblApVendorHistDetail
		SET Pmt = dbo.tblApVendorHistDetail.Pmt + ISNULL(t.Pmt,0), PmtFgn = dbo.tblApVendorHistDetail.PmtFgn + ISNULL(t.PmtFgn,0), 
			DiscTaken = dbo.tblApVendorHistDetail.DiscTaken + ISNULL(t.DiscTaken,0), DiscTakenFgn = dbo.tblApVendorHistDetail.DiscTakenFgn + ISNULL(t.DiscTakenFgn,0), 
			DiscLost = dbo.tblApVendorHistDetail.DiscLost + ISNULL(t.DiscLost,0), DiscLostFgn = dbo.tblApVendorHistDetail.DiscLostFgn + ISNULL(t.DiscLostFgn,0),
			Ten99Pmt = dbo.tblApVendorHistDetail.Ten99Pmt + ISNULL(t.Ten99Pmt,0),Ten99PmtFgn = dbo.tblApVendorHistDetail.Ten99PmtFgn + ISNULL(t.Ten99PmtFgn,0)
	FROM dbo.tblApVendorHistDetail INNER JOIN 
		(SELECT p.VendorId,p.FiscalYear, p.GlPeriod, SUM(CASE WHEN p.CurrencyId = @CurrBase THEN p.GrossAmtDue - p.DiscTaken ELSE ROUND(((p.GrossAmtDueFgn - p.DiscTakenFgn) / p.PmtExchRate), @PrecCurr) END) Pmt,
			SUM(p.GrossAmtDuefgn - p.DiscTakenfgn) PmtFgn, SUM(p.DiscTaken) DiscTaken,
			SUM(p.DiscTakenfgn) DiscTakenfgn,SUM(p.DiscLost) DiscLost, SUM(p.DiscLostfgn) DiscLostfgn,
			SUM(CASE WHEN p.Ten99InvoiceYn = 1 THEN p.GrossAmtDueFgn - p.DiscTakenFgn ELSE 0 END) Ten99PmtFgn,
			SUM(CASE WHEN p.Ten99InvoiceYn = 1 THEN CASE WHEN p.CurrencyId = @CurrBase THEN p.GrossAmtDue - p.DiscTaken ELSE ROUND(((p.GrossAmtDueFgn - p.DiscTakenFgn) / p.PmtExchRate), @PrecCurr) END ELSE 0 END) Ten99Pmt
		FROM dbo.tblApPrepChkInvc p INNER JOIN #PostTransList b ON p.BatchId = b.TransId
		GROUP BY p.VendorId,p.FiscalYear, p.GlPeriod) t 
	ON dbo.tblApVendorHistDetail.VendorID = t.VendorID AND dbo.tblApVendorHistDetail.FiscalYear = t.FiscalYear 
			AND dbo.tblApVendorHistDetail.GLPeriod = t.GLPeriod 

	/* update Last Payment Info - make table - prepays */
	INSERT INTO #temp1 (VendorID, CheckNum, FormatCheckNum, CheckAmt, CheckAmtFgn, CheckDate, [Status])
	SELECT i.VendorID, i.CheckNum, i.CheckNum, SUM(i.CheckAmt), SUM(i.CheckAmtFgn), i.CheckDate, 3
	FROM dbo.tblApPrepChkInvc i INNER JOIN #PostTransList b ON i.BatchId = b.TransId
	WHERE i.Status = 3 AND i.CheckAmt > 0 
	GROUP BY i.VendorID, i.CheckNum, i.CheckDate

	INSERT INTO #temp1 (VendorID, CheckNum, FormatCheckNum, CheckAmt, CheckAmtFgn, CheckDate, [Status])
	SELECT c.VendorID, c.CheckNum, c.CheckNum, c.CheckAmt, c.CheckAmtfgn, c.CheckDate, 0 
	FROM dbo.tblApPrepChkCheck c INNER JOIN #PostTransList b ON c.BatchId = b.TransId
	ORDER BY c.CheckDate, c.CheckNum

	/* update Last Payment Info - update tblApVendor */
	UPDATE dbo.tblApVendor SET LastPmtDate = t.CheckDate, LastPmtAmt = t.CheckAmt
		, LastPmtAmtFgn = CASE WHEN dbo.tblApVendor.CurrencyId = @CurrBase THEN t.CheckAmt ELSE t.CheckAmtFgn END, LastCheckNum = t.CheckNum 
	FROM dbo.tblApVendor INNER JOIN 
		(SELECT c.VendorId,c.CheckDate,c.CheckAmt,c.CheckAmtFgn,c.CheckNum FROM #temp1 c INNER JOIN (SELECT VendorID, MAX(FormatCheckNum) FormatCheckNum FROM #temp1 GROUP BY VendorID) v ON c.VendorId = v.VendorId AND ISNULL(c.FormatCheckNum,'') = ISNULL(v.FormatCheckNum,'')) t
		ON dbo.tblApVendor.VendorID = t.VendorID 
	WHERE (t.CheckDate > dbo.tblApVendor.LastPmtDate OR dbo.tblApVendor.LastPmtDate IS NULL)
	
	/* update #ApPmtPost0 with Gross Due & Prepaid amts */
	UPDATE #ApPmtPost0 
	SET SumOfGrossAmtDue = SumOfGrossAmtDue 
		+ (SELECT CASE WHEN SUM(GrossAmtDue) IS NOT NULL THEN SUM(GrossAmtDue) 
			ELSE 0 END FROM dbo.tblApOpenInvoice WHERE VendorID = #ApPmtPost0.VendorID AND Status < 3)
		, SumOfPrePay = SumOfPrePay 
			+ (SELECT CASE WHEN SUM(GrossAmtDue) IS NOT NULL THEN SUM(GrossAmtDue) 
				ELSE 0 END FROM dbo.tblApOpenInvoice WHERE VendorID = #ApPmtPost0.VendorID AND Status = 3)
		, SumOfGrossAmtDueFgn = SumOfGrossAmtDueFgn 
			+ (SELECT CASE WHEN SUM(GrossAmtDueFgn) IS NOT NULL THEN SUM(GrossAmtDueFgn) 
				ELSE 0 END FROM dbo.tblApOpenInvoice WHERE VendorID = #ApPmtPost0.VendorID AND Status < 3)
		, SumOfPrePayFgn = SumOfPrePayFgn 
			+ (SELECT CASE WHEN SUM(GrossAmtDueFgn) IS NOT NULL THEN SUM(GrossAmtDueFgn) 
				ELSE 0 END FROM dbo.tblApOpenInvoice WHERE VendorID = #ApPmtPost0.VendorID AND Status = 3)

	/* update tblApVendor with Gross Due & Prepaid amts */
	UPDATE dbo.tblApVendor SET GrossDue = SumOfGrossAmtDue, Prepaid = SumOfPrepay
	, GrossDueFgn = SumOfGrossAmtDueFgn, PrepaidFgn = SumOfPrepayFgn 
	FROM #ApPmtPost0 
	WHERE #ApPmtPost0.VendorID = dbo.tblApVendor.VendorID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Vendor_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Vendor_proc';

