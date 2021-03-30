
CREATE PROCEDURE dbo.trav_PsTransPost_BankRec_proc
AS
BEGIN TRY
	DECLARE @CurrBase pCurrency, @DescrDeposit nvarchar(30), @ReferDeposit nvarchar(15), @FiscalYear smallint, @FiscalPeriod smallint

	--Retrieve global values
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @DescrDeposit = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'DescrDeposit'
	SELECT @ReferDeposit = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'ReferDeposit'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'

	IF @CurrBase IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Set default for globals that were not provided
	SELECT @DescrDeposit = CASE WHEN ISNULL(@DescrDeposit, '') = '' THEN 'PS Deposit' ELSE @DescrDeposit END
		, @ReferDeposit = CASE WHEN ISNULL(@ReferDeposit, '') = '' THEN 'PS Deposit' ELSE @ReferDeposit END

              
	--insert records for payments in which Type < 3 (Cash or Check) or Type = 6 (Direct Debit) */
	--Transaction payment
	INSERT dbo.tblBrMaster (SourceID, BankID, CurrencyId, TransDate, TransType, ExchRate, Amount, AmountFgn, ClearedYn, Descr, Reference, 
		SourceApp,FiscalYear, GlPeriod) 
	SELECT t.LocID, m.BankId, @CurrBase, p.PmtDate, 2, 1, SUM(p.AmountBase), Sum(p.AmountBase), --Standard: only supports base currency external transactions
		0, @DescrDeposit, @ReferDeposit, 'PS', @FiscalYear, @FiscalPeriod
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblPsTransHeader h ON p.HeaderID = h.ID 
		INNER JOIN #PsTransList i ON h.ID = i.ID
		INNER JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		INNER JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId
	WHERE p.VoidDate IS NULL AND (p.PmtType < 3 OR p.PmtType = 6)
	GROUP BY t.LocID, m.BankId, p.PmtDate

	--Misc payment
	INSERT dbo.tblBrMaster (SourceID, BankID, CurrencyId, TransDate, TransType, ExchRate, Amount, AmountFgn, ClearedYn, Descr, Reference, 
		SourceApp,FiscalYear, GlPeriod) 
	SELECT t.LocID, m.BankId, @CurrBase, p.PmtDate, 2, 1, SUM(p.AmountBase), Sum(p.AmountBase), --Standard: only supports base currency external transactions
		0, @DescrDeposit, @ReferDeposit, 'PS', @FiscalYear, @FiscalPeriod
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		INNER JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId
	WHERE p.HeaderID IS NULL AND p.VoidDate IS NULL AND (p.PmtType < 3 OR p.PmtType = 6)
	GROUP BY t.LocID, m.BankId, p.PmtDate

	--update the bank account balance
	UPDATE dbo.tblSmBankAcct 
	SET GlAcctBal = dbo.tblSmBankAcct.GlAcctBal + t.PmtAmt
	FROM dbo.tblSmBankAcct INNER JOIN (SELECT m.BankId, SUM(p.AmountBase) PmtAmt --Standard: only supports base currency external transactions
		FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
			INNER JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		GROUP BY m.BankId) t ON dbo.tblSmBankAcct.BankId = t.BankId	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_BankRec_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_BankRec_proc';

