
CREATE PROCEDURE dbo.trav_ApPaymentPost_Bank_proc
AS
BEGIN TRY
DECLARE	@BAYn bit,@CurrBase pCurrency,@PrecCurr tinyint

	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @BAYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BAYn'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	
	IF @BAYn IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	IF @BAYn = 1 -- Payment to a credit card vendor
	BEGIN
		UPDATE dbo.tblSmBankAcct SET GlAcctBal = GlAcctBal + t.GlAcctBalTot
		FROM dbo.tblSmBankAcct INNER JOIN (SELECT s.BankId,SUM(CASE WHEN s.CurrencyId <> @CurrBase THEN CASE WHEN c.CurrencyId <> @CurrBase THEN GrossAmtDueFgn-DiscTakenfgn 
												ELSE ROUND((GrossAmtDue - DiscTaken) * c.PmtExchRate, ISNULL(t.CurrDecPlaces,@PrecCurr)) END 
												ELSE GrossAmtDue-DiscTaken END) AS GlAcctBalTot
											FROM dbo.tblApVendor v INNER JOIN dbo.tblApPrepChkInvc c ON v.VendorID = c.VendorID 
												INNER JOIN #PostTransList b ON  c.BatchId = b.TransId 
												INNER JOIN dbo.tblSmBankAcct s ON v.VendorId = s.VendorId 
												LEFT JOIN #tmpCurrencyList t ON c.PmtCurrencyId = t.CurrencyId
											WHERE s.AcctType = 1 
											GROUP BY s.BankId) t 
		ON dbo.tblSmBankAcct.BankId = t.BankId
	END

	UPDATE dbo.tblSmBankAcct SET GlAcctBal = GlAcctBal 
		+ (SELECT CASE WHEN SUM(t.Amount) IS NOT NULL 
			THEN CASE WHEN dbo.tblSmBankAcct.CurrencyID <> @CurrBase THEN SUM(t.Amountfgn) ELSE SUM(t.Amount) END 
			ELSE 0 END FROM #ApPaymentPostLog t WHERE t.BankId = dbo.tblSmBankAcct.BankId AND (t.[Order] = 3 OR t.[Order] = 4)) 
	FROM #ApPaymentPostLog

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Bank_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Bank_proc';

