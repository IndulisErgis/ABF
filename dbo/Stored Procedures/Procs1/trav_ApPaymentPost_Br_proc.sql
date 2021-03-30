
CREATE PROCEDURE dbo.trav_ApPaymentPost_Br_proc
AS
BEGIN TRY
DECLARE	@BAYn bit,@CurrBase pCurrency, @PrecCurr tinyint

	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @BAYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BAYn'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @BAYn IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	

	IF @BAYn = 1 -- Payment to a credit card vendor
	BEGIN
		-- Payment
		INSERT INTO dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, SourceApp, Amount, AmountFgn
		,TransDate, ClearedYn, CurrencyID, ExchRate, FiscalYear, GlPeriod) 
		SELECT s.BankId, 2, c.CheckNum, l.BankId,l.BankId, 'AP', CheckAmt
				, CASE WHEN c.CurrencyID <>  @CurrBase  THEN CheckAmtFgn ELSE CheckAmt END
				, c.CheckDate, 0, s.CurrencyId
				, CASE WHEN c.CurrencyID <>@CurrBase THEN  ISNULL(l.PmtExchRate, 1) ELSE 1 END, l.FiscalYear, l.GlPeriod
		FROM dbo.tblApPrepChkCheck c INNER Join dbo.tblApPrepChkCntl l on c.BatchId = l.BatchID  
			INNER JOIN #PostTransList b ON  c.BatchId = b.TransId 
			INNER JOIN dbo.tblApVendor v ON c.VendorID = v.VendorID 
			INNER JOIN dbo.tblSmBankAcct s ON v.VendorId = s.VendorId 
		WHERE CheckAmt <> 0 AND s.AcctType = 1

		--Prepaid
		INSERT INTO dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, SourceApp, Amount, AmountFgn
			,TransDate, ClearedYn, CurrencyID, ExchRate, FiscalYear, GlPeriod) 
		SELECT s.BankId, 2, c.CheckNum, c.BankId, c.BankId, 'AP'
			, SUM(ROUND((GrossAmtDueFgn-DiscTakenfgn) / c.PmtExchRate, @PrecCurr))
			, CASE WHEN s.CurrencyID <> @CurrBase THEN SUM(CheckAmtFgn) 
				ELSE SUM(ROUND((GrossAmtDueFgn-DiscTakenfgn) / c.PmtExchRate, @PrecCurr)) END
			, c.CheckDate, 0, s.CurrencyId
			, CASE WHEN s.CurrencyId <> @CurrBase THEN c.PmtExchRate ELSE 1.0 END
			, c.FiscalYear, c.GlPeriod 
		FROM dbo.tblApVendor v INNER JOIN dbo.tblApPrepChkInvc c ON v.VendorID = c.VendorID 
	   INNER JOIN #PostTransList b ON  c.BatchId = b.TransId 
		INNER JOIN dbo.tblSmBankAcct s ON v.VendorId = s.VendorId 
		WHERE CheckAmt <> 0 AND c.Status = 3  AND s.AcctType = 1 
		GROUP BY s.BankId,c.BankId,c.CheckNum,c.CheckDate,s.CurrencyId, c.PmtExchRate
			, c.FiscalYear, c.GlPeriod
		
		--ACH	PET: 241113
		INSERT INTO dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, SourceApp, Amount, AmountFgn
			,TransDate, ClearedYn, CurrencyID, ExchRate, FiscalYear, GlPeriod, ACHBatch) 
		SELECT l.BankId, -1, c.CheckNum, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.[Name] ELSE v.PayToName END, c.VendorID, 
			'AP', -CheckAmt, CASE WHEN c.CurrencyID <>  @CurrBase  THEN -CheckAmtFgn ELSE -CheckAmt END
			, c.CheckDate, 0, c.CurrencyId, CASE WHEN c.CurrencyID <>@CurrBase THEN  ISNULL(l.PmtExchRate, 1) ELSE 1  END,
			l.FiscalYear, l.GlPeriod, CASE c.DeliveryType WHEN 1 THEN CAST(l.Counter AS bigint) * POWER(10,9) + ISNULL(l.ACHBatch,0) ELSE NULL END  
		FROM dbo.tblApPrepChkCheck c INNER JOIN dbo.tblApPrepChkCntl l on c.BatchId = l.BatchID  
			INNER JOIN #PostTransList b ON  c.BatchId = b.TransId 
			INNER JOIN dbo.tblApVendor v ON c.VendorID = v.VendorID 
		WHERE CheckAmt <> 0

	END
	ELSE
	BEGIN
		 /* update Bank Reconciliation table (tblBrMaster) */
		INSERT INTO dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, SourceApp, Amount, AmountFgn
			,TransDate, ClearedYn, CurrencyID, ExchRate, FiscalYear, GlPeriod) 
		SELECT l.BankId, -1, c.CheckNum, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.[Name] ELSE v.PayToName END, c.VendorID, 'AP', -CheckAmt
			, CASE WHEN c.CurrencyID <>  @CurrBase  THEN -CheckAmtFgn ELSE -CheckAmt END, c.CheckDate, 0, c.CurrencyId
			, CASE WHEN c.CurrencyID <>@CurrBase THEN  ISNULL(l.PmtExchRate, 1) ELSE 1 END, l.FiscalYear, l.GlPeriod
		FROM dbo.tblApPrepChkCheck c INNER JOIN dbo.tblApPrepChkCntl l on c.BatchId = l.BatchID  
			INNER JOIN #PostTransList b ON  c.BatchId = b.TransId 
			INNER JOIN dbo.tblApVendor v ON c.VendorID = v.VendorID 
		WHERE CheckAmt <> 0
	END
	
	 /* update Bank Reconciliation table (tblBrMaster) with prepaid info */
	INSERT INTO dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, SourceApp, Amount, AmountFgn
		,TransDate, ClearedYn, CurrencyID, ExchRate, FiscalYear, GlPeriod) 
	SELECT c.BankId, -1, c.CheckNum, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.[Name] ELSE v.PayToName END, c.VendorID, 'AP'
		, -SUM(ROUND((GrossAmtDueFgn-DiscTakenfgn) / c.PmtExchRate, @PrecCurr))
		, CASE WHEN c.PmtCurrencyID <> @CurrBase THEN -SUM(CheckAmtFgn) 
			ELSE -SUM(ROUND((GrossAmtDueFgn-DiscTakenfgn) / c.PmtExchRate, @PrecCurr)) END
		, c.CheckDate, 0, c.PmtCurrencyId
		, CASE WHEN c.PmtCurrencyID <> @CurrBase THEN c.PmtExchRate ELSE 1.0 END
		, c.FiscalYear, c.GlPeriod 
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApPrepChkInvc c ON v.VendorID = c.VendorID 
   INNER JOIN #PostTransList b ON  c.BatchId = b.TransId 
	WHERE CheckAmt <> 0 AND c.Status = 3 
	GROUP BY c.BankId,c.VendorId,v.[Name],v.PayToName,c.CheckNum,c.CheckDate,c.CurrencyId,c.PmtCurrencyId, c.PmtExchRate
		, c.FiscalYear, c.GlPeriod, c.BatchId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Br_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Br_proc';

