
CREATE PROCEDURE dbo.trav_BrTransPost_MainLog_proc
AS
BEGIN TRY

	DECLARE @BaseCurrencyLog bit,@CurrBase pCurrency

	SELECT @BaseCurrencyLog = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BaseCurrencyLog'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @BaseCurrencyLog IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	IF (@BaseCurrencyLog = 1)
	BEGIN 
	INSERT #BrTransPostMainLog (CurrencyId, Total, Deposits, Disbursements, Adjustments, Transfers, Voids, FiscalYear, BankId, AcctType)
		SELECT @CurrBase, COUNT(h.TransId)
			, SUM(CASE WHEN h.TransType = 2 THEN h.Amount ELSE 0 END)
			, SUM(CASE WHEN h.TransType = -1 AND h.VoidYn = 0 THEN h.Amount ELSE 0 END)
			, SUM(CASE WHEN h.TransType = 4 THEN h.Amount ELSE 0 END)
			, SUM(CASE WHEN h.TransType = -3 THEN h.Amount ELSE 0 END)
			, SUM(CASE WHEN h.TransType = -1 AND h.VoidYn = 1 THEN h.Amount * -1 ELSE 0 END)
			, h.FiscalYear, h.BankID, MIN(b.AcctType)
		FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId
			INNER JOIN dbo.tblSmBankAcct b ON h.BankID = b.BankId
		GROUP BY h.BankID,h.FiscalYear
	END
	ELSE
	BEGIN
		INSERT #BrTransPostMainLog (CurrencyId, Total, Deposits, Disbursements, Adjustments
			, Transfers, Voids, FiscalYear, BankId, AcctType)
			SELECT h.CurrencyId, COUNT(h.TransId)
				, SUM(CASE WHEN h.TransType = 2 THEN h.AmountFgn ELSE 0 END)
				, SUM(CASE WHEN h.TransType = -1 AND h.VoidYn = 0 THEN h.AmountFgn ELSE 0 END)
				, SUM(CASE WHEN h.TransType = 4 THEN h.AmountFgn ELSE 0 END)
				, SUM(CASE WHEN h.TransType = -3 THEN h.AmountFgn ELSE 0 END)
				, SUM(CASE WHEN h.TransType = -1 AND h.VoidYn = 1 THEN h.AmountFgn * -1 ELSE 0 END)
				, h.FiscalYear, h.BankID, MIN(b.AcctType)
			FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId
				INNER JOIN dbo.tblSmBankAcct b ON h.BankID = b.BankId
			GROUP BY h.CurrencyId, h.BankID,h.FiscalYear
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_MainLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_MainLog_proc';

