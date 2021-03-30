
CREATE PROCEDURE [dbo].[trav_SmBankAcctBalance_proc]
@BankId [pBankId],
@BrGlYn [bit],
@AsOfFiscalPeriod [smallint] = NULL, --optional; Returns current balance when not provided
@AsOfFiscalYear [smallint] = NULL  --optional; Returns current balance when not provided
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @BankAcctBalance pCurrDecimal, @AccountType tinyint, @GlAcct pGlAcct
	DECLARE @GlAcctBalance pCurrDecimal
	DECLARE @BalType smallint

	--Retrieve the Bank Account Balance and GL Account Information
	SELECT @BankAcctBalance = b.GlAcctBal, @GlAcct = b.GLCashAcct, @AccountType = b.AcctType 
		FROM dbo.tblSmBankAcct b
		WHERE b.BankId = @BankId

	SELECT @BankAcctBalance = ISNULL(@BankAcctBalance, 0), @GlAcctBalance = 0

	--GL Balance is 0 when not interfaced
	IF @BrGlYn = 1
	BEGIN
		--Use the current Fiscal Year To Date if AsOf Year value is not provided (ignore provided Period if no year given)
		IF @AsOfFiscalYear is null
			SELECT @AsOfFiscalYear = [CurYear], @AsOfFiscalPeriod = null FROM dbo.tblGlAcctMask WHERE CompId = DB_NAME()

		--Determine the AsOf balance starting with period 0 beginning balance for the given Fiscal Year
		SELECT @GlAcctBalance = ISNULL(SUM(h.Actual), 0)
			FROM dbo.tblGlAcctDtl h 
			WHERE h.AcctId = @GlAcct AND h.[Year] = @AsOfFiscalYear AND h.[Period] <= ISNULL(@AsOfFiscalPeriod, h.[Period])

		--include any unposted journal entries thru the AsOf period and year for the given fiscal year only
		--(Unposted entries prior to the AsOf year must be posted to master)
		SELECT @GlAcctBalance = @GlAcctBalance + ISNULL(SUM(CASE WHEN h.[BalType] < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END), 0)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlJrnl j ON h.AcctId = j.AcctId 
			WHERE (h.AcctId = @GlAcct) AND (j.PostedYn = 0) 
				AND j.[Year] = @AsOfFiscalYear AND j.[Period] <= ISNULL(@AsOfFiscalPeriod, j.[Period])

		SELECT @BalType = [BalType] FROM dbo.tblGlAcctHdr WHERE (AcctId = @GlAcct)

		--Flip the sign for credit card type bank accounts
		IF (@AccountType = 1)
		BEGIN
			SET @GlAcctBalance = -@GlAcctBalance
		END
		--Flip the sign for credit GL Accounts
		IF (@BalType < 0)
		BEGIN
			SET @GlAcctBalance = -@GlAcctBalance
		END
	END

	--return the account balance
	SELECT @BankAcctBalance AS [BankAcctBalance], @GlAcctBalance AS [GLAcctBalance]

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmBankAcctBalance_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmBankAcctBalance_proc';

