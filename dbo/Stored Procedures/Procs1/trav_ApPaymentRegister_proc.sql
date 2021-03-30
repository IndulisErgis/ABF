
CREATE PROCEDURE dbo.trav_ApPaymentRegister_proc
@BatchId pBatchId,
@BaYn Bit = 0,
@BaseCurrency pCurrency = 'USD',
@CurrencyPrecision tinyint = 2,
@BankCurrencyPrecision TINYINT

AS
SET NOCOUNT ON
BEGIN TRY

--PET:http://webfront:801/view.php?id=236829
--PET:http://webfront:801/view.php?id=232165
--PET:http://webfront:801/view.php?id=236682
	CREATE TABLE #tmpApGainsLossJrnl
	(
		VendorId pVendorId NULL, 
		[Status] tinyint NULL default (0), 
		InvoiceDate datetime, 
		InvoiceNum pInvoiceNum NULL, 
		CurrencyId pCurrency NULL, 
		PmtCurrencyId pCurrency NULL, 
		GrossAmtDuefgn pDecimal NULL default (0), 
		GrossAmtDueInv pDecimal NULL default (0), 
		PmtExchRate pDecimal NULL default (1), 
		ExchRate pDecimal NULL default (1), 
		GrossAmtDue pDecimal NULL default (0), 
		GLAccGainLoss pGlAcct NULL, 
		CalcGainLoss pDecimal NULL default (0), 
		GlPeriod smallint, FiscalYear smallint,  
		CurrBase pCurrency NULL, BatchId pBatchId
	)

	IF @BaYn = 1 
	BEGIN

		SELECT CASE WHEN v.Name <> v.PayToName THEN ISNULL(v.Name,'')
			+ CASE WHEN ISNULL(v.Name,'') = '' OR ISNULL(v.PayToName,'') = ''
			THEN '' ELSE '/' END + ISNULL(v.PayToName,'') ELSE v.Name END AS [Name]
			, CASE WHEN i.Ten99InvoiceYN = 1 THEN 'Y' ELSE 'N' END AS [Ten99InvoiceYN]
			,CASE WHEN i.Status <>3 THEN c.Checknum ELSE i.Checknum END AS CheckNumber
			,i.InvoiceDate,CASE WHEN i.Status = 3 THEN i.CheckDate ELSE NULL END CheckDate
			,i.NetDueDate,CASE WHEN i.PmtCurrencyId = @BaseCurrency THEN i.DiscTaken ELSE i.DiscTakenFgn END DiscTakenFgn,
			i.VendorID,i.InvoiceNum,i.BankID, i.PmtExchRate,i.CurrencyId,i.PmtCurrencyId, 
			CASE WHEN i.Status <> 3 THEN ISNULL(c.PmtDeliType,0) ELSE i.Status END AS [Status],-- 0,Check; 1,EFT; 2,Credit Card; 3,Prepaid
			CASE WHEN i.PmtCurrencyId <> @BaseCurrency THEN i.GrossAmtDueFgn
				ELSE CASE WHEN i.CurrencyId <> @BaseCurrency THEN ROUND(((i.GrossAmtDueFgn - i.DiscTakenFgn)/ i.PmtExchRate + i.DiscTaken), @BankCurrencyPrecision) ELSE i.GrossAmtDue END END GrossAmtDueFgn,
			CASE WHEN i.Status <> 3 THEN c.Checknum ELSE i.Checknum END AS FormatCheckNumber, i.[Counter]
		FROM (dbo.tblApPrepChkInvc i LEFT JOIN dbo.tblApVendor  v  ON i.VendorID = v.VendorID) 
			LEFT JOIN dbo.trav_ApPrepareCheck_Check_BA_view c ON i.VendorID = c.VendorID AND i.GrpID = c.GrpID AND c.BatchID = i.BatchID
		WHERE i.BatchID = @BatchId AND (i.CurrencyId <> @BaseCurrency OR (i.CurrencyId = @BaseCurrency AND i.PmtCurrencyId = @BaseCurrency )) --Foreign invoice or base currecy invoice paid with base currency 
		UNION ALL
		SELECT CASE WHEN v.Name <> v.PayToName THEN ISNULL(v.Name,'')
			+ CASE WHEN ISNULL(v.Name,'') = '' OR ISNULL(v.PayToName,'') = ''
			THEN '' ELSE '/' END + ISNULL(v.PayToName,'') ELSE v.Name END AS [Name]
			, CASE WHEN i.Ten99InvoiceYN = 1 THEN 'Y' ELSE 'N' END AS [Ten99InvoiceYN]
			,CASE WHEN i.Status <>3 THEN c.Checknum ELSE i.Checknum END AS CheckNumber
			,i.InvoiceDate,CASE WHEN i.Status = 3 THEN i.CheckDate ELSE NULL END CheckDate
			,i.NetDueDate, i.DiscTaken * i.PmtExchRate AS DiscTakenFgn,
			i.VendorID,i.InvoiceNum,i.BankID, i.PmtExchRate,i.CurrencyId,i.PmtCurrencyId, 
			CASE WHEN i.Status <> 3 THEN ISNULL(c.PmtDeliType,0) ELSE i.Status END AS [Status],-- 0,Check; 1,EFT; 2,Credit Card; 3,Prepaid
			ROUND( (i.GrossAmtDue * i.PmtExchRate), @BankCurrencyPrecision) AS GrossAmtDueFgn,
			CASE WHEN i.Status <> 3 THEN c.Checknum ELSE i.Checknum END AS FormatCheckNumber, i.[Counter]
		FROM (dbo.tblApPrepChkInvc i LEFT JOIN dbo.tblApVendor  v  ON i.VendorID = v.VendorID) 
			LEFT JOIN dbo.trav_ApPrepareCheck_Check_BA_view c ON i.VendorID = c.VendorID AND i.GrpID = c.GrpID AND c.BatchID = i.BatchID
		WHERE i.BatchID = @BatchId AND (i.CurrencyId = @BaseCurrency AND i.PmtCurrencyId <> @BaseCurrency ) --base currecy invoice paid with foreign currency
		
	END
	ELSE
	BEGIN
		SELECT CASE WHEN v.Name <> v.PayToName THEN ISNULL(v.Name,'')
			+ CASE WHEN ISNULL(v.Name,'') = '' OR ISNULL(v.PayToName,'') = ''
			THEN '' ELSE '/' END + ISNULL(v.PayToName,'') ELSE v.Name END AS [Name]
			, CASE WHEN i.Ten99InvoiceYN = 1 THEN 'Y' ELSE 'N' END AS [Ten99InvoiceYN]
			,CASE WHEN i.Status <>3 THEN c.Checknum ELSE i.Checknum END AS CheckNumber
			,i.InvoiceDate,CASE WHEN i.Status = 3 THEN i.CheckDate ELSE NULL END CheckDate
			,i.NetDueDate,CASE WHEN i.PmtCurrencyId = @BaseCurrency THEN i.DiscTaken ELSE i.DiscTakenFgn END DiscTakenFgn,
			i.VendorID,i.InvoiceNum,i.Status,i.CurrencyId,i.PmtCurrencyId, 
			CASE WHEN i.PmtCurrencyId <> @BaseCurrency THEN i.GrossAmtDueFgn
				ELSE CASE WHEN i.CurrencyId <> @BaseCurrency THEN ROUND(((i.GrossAmtDueFgn - i.DiscTakenFgn)/ i.PmtExchRate + i.DiscTaken), @BankCurrencyPrecision) ELSE i.GrossAmtDue END END GrossAmtDueFgn,
			i.BankID, PmtExchRate, 
			CASE WHEN i.Status <> 3 THEN c.Checknum ELSE i.Checknum END AS FormatCheckNumber, i.[Counter]
		FROM (dbo.tblApPrepChkInvc i LEFT JOIN dbo.tblApVendor  v  ON i.VendorID = v.VendorID) 
			LEFT JOIN dbo.tblApPrepChkCheck c ON i.VendorID = c.VendorID AND i.GrpID = c.GrpID AND c.BatchID = i.BatchID
		WHERE i.BatchID = @BatchId AND (i.CurrencyId <> @BaseCurrency OR (i.CurrencyId = @BaseCurrency AND i.PmtCurrencyId = @BaseCurrency )) --Foreign invoice or base currecy invoice paid with base currency 
		UNION ALL
		SELECT CASE WHEN v.Name <> v.PayToName THEN ISNULL(v.Name,'')
			+ CASE WHEN ISNULL(v.Name,'') = '' OR ISNULL(v.PayToName,'') = ''
			THEN '' ELSE '/' END + ISNULL(v.PayToName,'') ELSE v.Name END AS [Name]
			, CASE WHEN i.Ten99InvoiceYN = 1 THEN 'Y' ELSE 'N' END AS [Ten99InvoiceYN]
			,CASE WHEN i.Status <>3 THEN c.Checknum ELSE i.Checknum END AS CheckNumber
			,i.InvoiceDate,CASE WHEN i.Status = 3 THEN i.CheckDate ELSE NULL END CheckDate
			,i.NetDueDate, i.DiscTaken * i.PmtExchRate DiscTakenFgn,
			i.VendorID,i.InvoiceNum,i.Status,i.CurrencyId,i.PmtCurrencyId, 
			ROUND((i.GrossAmtDue * i.PmtExchRate), @BankCurrencyPrecision) AS GrossAmtDueFgn,
			i.BankID, PmtExchRate, 
			CASE WHEN i.Status <> 3 THEN c.Checknum ELSE i.Checknum END AS FormatCheckNumber, i.[Counter]
		FROM (dbo.tblApPrepChkInvc i LEFT JOIN dbo.tblApVendor  v  ON i.VendorID = v.VendorID) 
			LEFT JOIN dbo.tblApPrepChkCheck c ON i.VendorID = c.VendorID AND i.GrpID = c.GrpID AND c.BatchID = i.BatchID
		WHERE i.BatchID = @BatchId AND (i.CurrencyId = @BaseCurrency AND i.PmtCurrencyId <> @BaseCurrency ) --base currecy invoice paid with foreign currency
	END

	--Gains/Losses
	INSERT INTO #tmpApGainsLossJrnl
	--Invoices
	SELECT i.VendorId, i.Status, i.InvoiceDate, i.InvoiceNum, i.CurrencyId, i.PmtCurrencyId, (i.GrossAmtDueFgn - i.DiscTakenFgn) AS GrossAmtDuefgn, 
		(i.GrossAmtDue-i.DiscTaken) AS GrossAmtDueInv, i.PmtExchRate, i.ExchRate, 
		ROUND(ROUND(((i.GrossAmtDueFgn)/i.PmtExchRate), @CurrencyPrecision) - ROUND(((i.DiscTakenFgn)/i.PmtExchRate), @CurrencyPrecision) , @CurrencyPrecision) AS GrossAmtDue,
		CASE WHEN ((((i.GrossAmtDueFgn-i.DiscTakenFgn)/i.PmtExchRate) - (i.GrossAmtDue-i.DiscTaken)) < 0) 
		THEN g.RealGainAcct ELSE g.RealLossAcct END GLAccGainLoss, 
		-ROUND((ROUND(((i.GrossAmtDueFgn)/i.PmtExchRate), @CurrencyPrecision) - ROUND(((i.DiscTakenFgn)/i.PmtExchRate), @CurrencyPrecision))  - ((i.GrossAmtDue) - ROUND(((i.DiscTakenFgn)/i.ExchRate), @CurrencyPrecision)), @CurrencyPrecision) AS CalcGainLoss,
		i.GlPeriod, i.FiscalYear, @BaseCurrency, i.BatchId
	FROM dbo.tblApPrepChkInvc i INNER JOIN #tmpGainLossAccounts g ON i.CurrencyId = g.CurrencyId
	WHERE i.BatchId = @BatchId AND i.CurrencyID <> @BaseCurrency
		AND i.Status = 0 AND i.ExchRate <> ISNULL(i.PmtExchRate,1) 
	UNION ALL
	--Prepaid
	SELECT i.VendorId, i.Status, i.InvoiceDate, i.InvoiceNum, i.CurrencyId, i.PmtCurrencyId, (i.GrossAmtDueFgn - i.DiscTakenFgn) AS GrossAmtDuefgn, 
		(BaseGrossAmtDue) - ROUND(DiscAmtFgn/ExchRate,@CurrencyPrecision) AS GrossAmtDueInv, i.PmtExchRate, i.ExchRate, 
		ROUND(CheckAmtFgn/PmtExchRate, @CurrencyPrecision),i.GLAccGainLoss, -i.CalcGainLoss, i.GlPeriod, i.FiscalYear, @BaseCurrency,i.BatchId
	FROM tblApPrepChkInvc i 
	WHERE i.BatchId = @BatchId AND i.CurrencyID <> @BaseCurrency AND i.Status = 3 AND i.CalcGainLoss <> 0

	SELECT * FROM  #tmpApGainsLossJrnl 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentRegister_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentRegister_proc';

