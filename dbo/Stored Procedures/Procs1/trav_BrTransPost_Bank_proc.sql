
CREATE PROCEDURE dbo.trav_BrTransPost_Bank_proc
AS
BEGIN TRY

	DECLARE @CurrBase pCurrency

	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	/* update Bank Account balances with activity posted from Post2a */
	UPDATE dbo.tblSmBankAcct SET GlAcctBal = GlAcctBal + t.Amount 
	FROM dbo.tblSmBankAcct INNER JOIN 
		(SELECT h.BankId,SUM(h.AmountFgn * SIGN(h.TransType)) AS Amount 
			FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
			WHERE (h.VoidYn = 0 OR (h.VoidYn = 1 AND h.VoidReinstateStat IS NULL)) --MOD:Exclude externally voided payments
			GROUP BY h.BankId) t
		ON dbo.tblSmBankAcct.BankId = t.BankId

	/* update Bank Account balances with activity posted for "Transfer To" side of transfers */
	UPDATE dbo.tblSmBankAcct 
		SET GlAcctBal = CASE WHEN dbo.tblSmBankAcct.CurrencyID = @CurrBase 
			THEN (CASE WHEN DebitAmt <> 0 THEN DebitAmt + GlAcctBal ELSE GlAcctBal - CreditAmt END) 
				ELSE (CASE WHEN DebitAmtFgn <> 0 THEN DebitAmtFgn + GlAcctBal ELSE GlAcctBal - CreditAmtFgn END) END 
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
		INNER JOIN dbo.tblBrJrnlDetail d ON h.TransId = d.TransId 
		INNER JOIN dbo.tblSmBankAcct ON d.BankIDXferTo = dbo.tblSmBankAcct.BankId 
	WHERE d.BankIDXferTo IS NOT NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_Bank_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_Bank_proc';

