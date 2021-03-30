
CREATE PROCEDURE dbo.trav_PaCheckPost_UpdateVoucher_proc 
AS
BEGIN TRY

--PET:http://webfront:801/view.php?id=227220
--PET:http://webfront:801/view.php?id=243071
--PET:http://problemtrackingsystem.osas.com/view.php?id=267470

        DECLARE @PostRun pPostRun, @CurrBase nvarchar(6), @DateOnCheck datetime, 
		@PostYear smallint, @GlPeriod smallint, @PrecCurr smallint, @BankID nvarchar(10),
        @BrYn bit, @Debit pDecimal, @Vouchers int, @PayrollNum nvarchar(6) 


        SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	    SELECT @BrYN = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BRYN'
        SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
        SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
        SELECT @BankID = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'BankID'
		SELECT @PostYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PostYear'
        SELECT @GlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod'
        SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
        SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
        SELECT @PayrollNum = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'PayrollNum'
       
  
       
	
   IF @PostRun IS NULL OR @DateOnCheck IS NULL OR @PostYear IS NULL OR @GlPeriod IS NULL OR @PayrollNum IS NULL 

	BEGIN
		RAISERROR(90025,16,1)
	END



INSERT INTO dbo.tblPaCheckHistDistribution( 
PostRun, d.CheckId, d.DistributionId, d.CurrentAmount, DirectDepositYN, TraceNumber, CF) 
                                                                                                                                                                                                                                                             
Select @PostRun, d.CheckId, d.DistributionId, d.CurrentAmount, d.DirectDepositYN, d.TraceNumber, d.CF 
from dbo.tblPaCheck c INNER JOIN #PostTransList b ON  c.Id = b.TransId 
Inner Join dbo.tblPaCheckDistribution d on c.Id = d.CheckId
WHERE d.DirectDepositYN = 1



--set @BrYn = 1


SELECT @Vouchers = Count(*) FROM dbo.tblPaCheckDistribution c 
INNER JOIN #PostTransList b ON c.CheckId = b.TransId  WHERE c.DirectDepositYn=1


IF (@BrYn=1 AND @Vouchers>0)
BEGIN
	SELECT @Debit=ROUND(Sum(c.CurrentAmount),@PrecCurr) FROM dbo.tblPaCheckDistribution c INNER JOIN #PostTransList b ON c.CheckId = b.TransId  WHERE c.DirectDepositYn=1



	INSERT INTO dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, SourceApp,
		Amount, AmountFgn, TransDate, FiscalYear, GlPeriod, ClearedYn, CurrencyID, ExchRate)
	VALUES (@BankID, -1, 'ACH' + RIGHT('000000' + CAST(@PayrollNum AS nvarchar), 6), 'Authorized Debit', 'Payroll', 'PA',
		-@Debit,-@Debit, @DateOnCheck, @PostYear, @GlPeriod, 0, @CurrBase, 1)

END



END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateVoucher_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateVoucher_proc';

