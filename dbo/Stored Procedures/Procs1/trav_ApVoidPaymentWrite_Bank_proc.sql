
CREATE PROCEDURE dbo.trav_ApVoidPaymentWrite_Bank_proc
AS
BEGIN TRY
	DECLARE @PrecCurr tinyint,@CurrBase pCurrency

	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @PrecCurr IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Bank
	UPDATE dbo.tblSmBankAcct SET GlAcctBal = CASE WHEN dbo.tblSmBankAcct.CurrencyID <> @CurrBase THEN GlAcctBal - SumAmountFgn   
		ELSE GlAcctBal - SumAmount END   
	FROM dbo.tblSmBankAcct 
	INNER JOIN (Select BankId, sum(ROUND(AmountFgn/ExchRate,@PrecCurr)) SumAmount, sum(AmountFgn) SumAmountFgn
		From #GlPostLogs WHERE [Grouping] = 30
		Group By BankId) t
		ON dbo.tblSmBankAcct.BankId = t.BankId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Bank_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Bank_proc';

