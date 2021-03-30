
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_BankRec_proc
AS
BEGIN TRY
	DECLARE @CurrBase pCurrency, @DescrDeposit nvarchar(30), @ReferDeposit nvarchar(15)

	--Retrieve global values
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @DescrDeposit = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'DescrDeposit'
	SELECT @ReferDeposit = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'ReferDeposit'

	IF @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Set default for globals that were not provided
	SELECT @DescrDeposit = CASE WHEN ISNULL(@DescrDeposit, '') = '' THEN 'AR Deposit' ELSE @DescrDeposit END
		, @ReferDeposit = CASE WHEN ISNULL(@ReferDeposit, '') = '' THEN 'AR Deposit' ELSE @ReferDeposit END

              
	--insert records for payments in which Type < 3 (Cash or Check) or Type = 6 (Direct Debit) */
	INSERT dbo.tblBrMaster (SourceID, BankID, CurrencyId, TransDate, TransType, ExchRate
		, Amount, AmountFgn, ClearedYn, Descr, Reference, SourceApp,FiscalYear, GlPeriod) 
	SELECT h.DepositId, h.BankId, br.CurrencyId, h.PmtDate, 2
		, CASE WHEN br.CurrencyID = @CurrBase THEN 1 ELSE h.ExchRate END
		, SUM(d.PmtAmt)
		, Sum(CASE WHEN br.CurrencyID = @CurrBase THEN d.PmtAmt ELSE d.PmtAmtFgn END)
		, 0, @DescrDeposit, @ReferDeposit, 'AR', h.FiscalYear, h.GlPeriod
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN dbo.tblArPmtMethod pmt ON h.PmtMethodId = pmt.PmtMethodId
	INNER JOIN dbo.tblSmBankAcct br ON pmt.BankID = br.BankID 
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	WHERE h.BankID IS NOT NULL AND (pmt.PmtType < 3 OR pmt.PmtType = 6)
	GROUP BY h.DepositId, h.BankID, br.CurrencyID, h.FiscalYear, h.GlPeriod, h.ExchRate, h.PmtDate

	--insert records for payments in which Type = 3 (CreditCard) and Type = 7 (External)
	INSERT dbo.tblBrMaster (SourceID, BankID, CurrencyId, TransDate, TransType, ExchRate
		, Amount, AmountFgn, ClearedYn, Descr, Reference, SourceApp, FiscalYear, GlPeriod) 
	SELECT pmt.PmtMethodID, h.BankId, br.CurrencyId, h.PmtDate, 2, CASE WHEN br.CurrencyID = @CurrBase THEN 1 ELSE h.ExchRate END
		, d.PmtAmt, CASE WHEN br.CurrencyID = @CurrBase THEN d.PmtAmt ELSE d.PmtAmtFgn END
		, 0, c.CustName, h.CcAuth, 'AR', h.FiscalYear, h.GlPeriod
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN dbo.tblArPmtMethod pmt ON h.PmtMethodId = pmt.PmtMethodId
	INNER JOIN dbo.tblSmBankAcct br ON pmt.BankID = br.BankID 
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	LEFT JOIN dbo.tblArCust c ON h.CustId = c.CustId
	WHERE h.BankID IS NOT NULL AND pmt.PmtType IN (3, 7)

	--update the bank account balance
	UPDATE dbo.tblSmBankAcct 
		SET GlAcctBal = CASE WHEN dbo.tblSmBankAcct.CurrencyId = @CurrBase 
			THEN (dbo.tblSmBankAcct.GlAcctBal + t.PmtAmt) 
			ELSE (dbo.tblSmBankAcct.GlAcctBal + t.PmtAmtFgn) 
		END 
	FROM dbo.tblSmBankAcct 
	INNER JOIN (SELECT h.BankId
		, SUM(d.PmtAmt) PmtAmt
		, SUM(d.PmtAmtFgn) PmtAmtFgn
		FROM dbo.tblArCashRcptHeader h 
		INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
		INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
		GROUP BY h.BankId) t
	ON dbo.tblSmBankAcct.BankId = t.BankId	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_BankRec_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_BankRec_proc';

