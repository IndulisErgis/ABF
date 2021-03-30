
CREATE PROCEDURE dbo.trav_PaVoidCheck_Br_proc
AS
--PET:http://webfront:801/view.php?id=227706
--PET:http://webfront:801/view.php?id=242924

BEGIN TRY
	DECLARE @CurrBase pCurrency
	DECLARE @FiscalYear smallint
	DECLARE @FiscalPeriod smallint
	DECLARE @VoidDate datetime
	DECLARE @PayrollNumber int
       
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @VoidDate = Cast([Value] AS DateTime) FROM #GlobalValues WHERE [Key] = 'VoidDate'
	SELECT @PayrollNumber = Cast([Value] AS int) FROM #GlobalValues WHERE [Key] = 'PayrollNumber'
       
	IF @CurrBase IS NULL OR @VoidDate IS NULL
		OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL 
		OR @PayrollNumber IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--Void the Master entry
	UPDATE dbo.tblBrMaster SET dbo.tblBrMaster.[ClearedYn] = 1, dbo.tblBrMaster.[VoidStop] = 1
		, dbo.tblBrMaster.[Amount] = 0, dbo.tblBrMaster.[AmountFgn] = 0
		, dbo.tblBrMaster.[VoidDate] = @VoidDate, dbo.tblBrMaster.[VoidPd] = @FiscalPeriod, dbo.tblBrMaster.[VoidYear] = @FiscalYear
		, dbo.tblBrMaster.[VoidAmt] = -l.[NetPay], dbo.tblBrMaster.[VoidAmtFgn] = -l.[NetPay], dbo.tblBrMaster.[VoidTransID] = NULL
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblBrMaster ON l.[VoidBankId] = dbo.tblBrMaster.[BankID]
		AND l.[UseCheckNum] = dbo.tblBrMaster.[SourceID]
		AND l.[EmployeeId] = dbo.tblBrMaster.Reference 
		AND l.[CheckDate] = dbo.tblBrMaster.[TransDate]
	WHERE dbo.tblBrMaster.[ClearedYn] = 0
		AND l.[Status] = 0 
	
	
	--Adjust for any voided direct deposit amounts
	if exists (SELECT 1 FROM #VoidCheckLog WHERE [VoucherAmount] <> 0 AND [Status] = 0)
	BEGIN
		INSERT INTO dbo.tblBrMaster ([BankID], [TransType], [SourceID], [Descr]
			, [Reference], [SourceApp], [Amount], [AmountFgn], [TransDate]
			, [FiscalYear], [GlPeriod], [ClearedYn], [VoidStop], [CurrencyId], [ExchRate]
			, [VoidDate], [VoidPd], [VoidYear], [VoidAmt], [VoidAmtFgn]) 
		SELECT l.[VoidBankId], -1, 'ACH' + RIGHT('000000' + CAST(@PayrollNumber AS nvarchar), 6), 'Authorized Debit'
			, 'Payroll', 'PA', l.[VoucherAmount], l.[VoucherAmount], l.CheckDate
			, @FiscalYear, @FiscalPeriod, 1, 1, @CurrBase, 1
			, @VoidDate, @FiscalPeriod, @FiscalYear, l.[VoucherAmount], l.[VoucherAmount]
		FROM #VoidCheckLog l
		WHERE [VoucherAmount] <> 0
			AND l.[Status] = 0 
	END
	

	--Update the account balance
	UPDATE dbo.tblSmBankAcct SET [GLAcctBal] = [GLAcctBal] + s.[TotalNetPay]
	FROM (SELECT [VoidBankId], SUM([NetPay]) AS [TotalNetPay]
		FROM #VoidCheckLog
		WHERE [Status] = 0 
		GROUP BY [VoidBankId]
	) s
	WHERE dbo.tblSmBankAcct.[BankId] = s.[VoidBankId]
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_Br_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_Br_proc';

