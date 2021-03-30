
CREATE PROCEDURE dbo.trav_ApPaymentPost_History_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	/* update tblApPrepChkInvc with check num fromtblApPrepChkCheck */
	UPDATE dbo.tblApPrepChkInvc SET CheckNum = dbo.tblApPrepChkCheck.CheckNum
		, CheckDate = dbo.tblApPrepChkCheck.CheckDate 
	FROM dbo.tblApPrepChkCheck INNER JOIN #PostTransList b ON dbo.tblApPrepChkCheck.BatchId = b.TransId 
	WHERE  dbo.tblApPrepChkCheck.VendorID = dbo.tblApPrepChkInvc.VendorID 
		AND dbo.tblApPrepChkCheck.GrpID = dbo.tblApPrepChkInvc.GrpID 
		AND dbo.tblApPrepChkCheck.BatchID = dbo.tblApPrepChkInvc.BatchID AND dbo.tblApPrepChkInvc.Status <> 3

	/* update tblApCheckHist with check info from tblApPrepChkInvc */
	INSERT INTO dbo.tblApCheckHist (PostRun, VendorID, InvoiceNum, Ten99InvoiceYN, DistCode, InvoiceDate
		, GrossAmtDue, BaseGrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn
		, CheckNum, CheckDate, CurrencyID, GLCashAcct, GLDiscAcct, PmtType, DiscDueDate, NetDueDate
		, ExchRate, BankId, VoidBankId, CheckRun, DiscLost, DiscTaken, FiscalYear, GlPeriod
		, TermsCode ,DiscTakenFgn, DiscLostFgn, SumHistPeriod, PayToName, PayToAttn
		, PayToAddr1, PayToAddr2, PayToCity, PayToRegion, PayToCountry, PayToPostalCode
		, PmtCurrencyId, PmtExchRate, NetPaidCalc, DiscAmtCalc,DeliveryType,BankAcctNum,RoutingCode,GLAcctAP,GLAcctGainLoss,BankAccountType) 
	SELECT @PostRun, c.VendorID, c.InvoiceNum, c.Ten99InvoiceYN, c.DistCode, c.InvoiceDate
		, CASE WHEN c.CurrencyID <> @CurrBase AND c.ExchRate <> ISNULL(c.PmtExchRate,1) 
			THEN ROUND(ROUND(c.GrossAmtDueFgn / c.PmtExchRate, @PrecCurr) 
			- ROUND(c.DiscTakenFgn / c.PmtExchRate, @PrecCurr) 
			+ ROUND(c.DiscTakenFgn / c.ExchRate, @PrecCurr), @PrecCurr) ELSE c.GrossAmtDue END
		, c.BaseGrossAmtDue
		, CASE WHEN c.CurrencyID <> @CurrBase AND c.ExchRate <> ISNULL(c.PmtExchRate,1)
			THEN ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr) 
			ELSE CASE WHEN c.CurrencyID = @CurrBase THEN c.DiscTaken ELSE ROUND((c.DiscTakenFgn / c.PmtExchRate), @PrecCurr) END END
		, c.GrossAmtDueFgn, c.DiscTakenFgn, COALESCE(c.CheckNum, ' '), c.CheckDate, c.CurrencyId
		, c.GlCashAcct, c.GlDiscAcct, c.Status, c.DiscDueDate, c.NetDueDate, c.ExchRate
		, c.BankId, c.BankId, GETDATE(), c.DiscLost, c.DiscTaken, c.FiscalYear, c.GlPeriod
		, c.TermsCode, c.DiscTakenFgn, c.DiscLostFgn, c.GlPeriod
		, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.Name ELSE v.PayToName END
		, v.PayToAttention
		, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.Addr1 ELSE v.PayToAddr1 END
		, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.Addr2 ELSE v.PayToAddr2 END
		, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.City ELSE v.PayToCity END
		, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.Region ELSE v.PayToRegion END
		, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.Country ELSE v.PayToCountry END
		, CASE WHEN ISNULL(v.PayToName,'') = '' THEN v.PostalCode ELSE v.PayToPostalCode END
		, c.PmtCurrencyId, c.PmtExchRate
		, CASE WHEN c.CurrencyID <> @CurrBase AND c.ExchRate <> ISNULL(c.PmtExchRate,1) 
			THEN CASE WHEN c.Status = 3 THEN c.BaseGrossAmtDue - c.DiscTaken  
			ELSE c.GrossAmtDue - c.DiscTaken END ELSE c.GrossAmtDue - c.DiscTaken END
		, c.DiscTaken,CASE WHEN k.[Counter] IS NULL THEN v.DeliveryType ELSE k.DeliveryType END, CASE WHEN k.[Counter] IS NULL THEN v.BankAcctNum ELSE k.BankAcctNum END,
		CASE WHEN k.[Counter] IS NULL THEN v.RoutingCode ELSE k.RoutingCode END,d.PayablesGLAcct,
		CASE WHEN c.Status = 3 AND c.CalcGainLoss <> 0 THEN c.GLAccGainLoss 
			WHEN c.CurrencyID <> @CurrBase AND c.Status = 0 AND c.ExchRate <> c.PmtExchRate THEN 
			CASE WHEN ((c.GrossAmtDueFgn-c.DiscTakenfgn) / c.PmtExchRate) - ((c.GrossAmtDuefgn-c.DiscTakenfgn) / c.ExchRate) < 0 THEN t.RealGainAcct 
				ELSE t.RealLossAcct END
		END, CASE WHEN k.[Counter] IS NULL THEN v.BankAccountType ELSE k.BankAccountType END
	FROM dbo.tblApPrepChkInvc c 
		INNER JOIN dbo.tblApDistCode d ON c.DistCode = d.DistCode 
		LEFT JOIN dbo.tblGlAcctHdr g ON d.PayablesGLAcct =  g.AcctId 
		INNER  JOIN dbo.tblApVendor v ON c.VendorID = v.VendorID
		LEFT JOIN dbo.tblApPrepChkCheck k ON c.VendorID = k.VendorID AND c.GrpID = k.GrpID AND c.BatchID = k.BatchID
		INNER JOIN #PostTransList b ON c.BatchId = b.TransId 
		INNER JOIN #GainLossAccounts t ON c.CurrencyId = t.CurrencyId 
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_History_proc';

