
CREATE PROCEDURE dbo.trav_PaCheckPost_Br_proc
AS
BEGIN TRY

--PET:http://webfront:801/view.php?id=226466
--PET:http://webfront:801/view.php?id=226993
--PET:http://webfront:801/view.php?id=227220
--PET:http://webfront:801/view.php?id=227186

 DECLARE @PostRun pPostRun, @PostYear smallint, @PdEnd datetime, 
 @GlPeriod tinyint, @DateOnCheck datetime, @CurrBase nvarchar(6), @BankID nvarchar(10),
 @DD bit, @BrYN bit
       

        SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	    SELECT @GlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod'
        SELECT @PdEnd = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'PdEnd'
        SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
        SELECT @PostYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PostYear'
        SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
        SELECT @BankID = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'BankID'
		SELECT @DD = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'DD'
        SELECT @BrYN = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BrYN'
       
--net check amount must be calculated as the tblPaCheck.NetPay - SUM(tblPaCheckDistribution.CurrentAmount Where tblPaCheckDistribution.DirectDepositYn = 1)


    
       
	
   IF @PostRun IS NULL  OR @PdEnd IS NULL OR @DateOnCheck IS NULL OR @GlPeriod IS NULL Or @PostYear IS NULL

	BEGIN
		RAISERROR(90025,16,1)
	END




IF @BrYn = 1
	BEGIN

			
           	INSERT INTO dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, SourceApp
				, Amount, AmountFgn, TransDate, FiscalYear, GlPeriod, ClearedYn, CurrencyId, ExchRate) 
 
			SELECT @BankID, -1, c.CheckNumber, c.EmployeeId
				, c.EmployeeId, 'PA', 
				-- -(COALESCE(c.NetPay, 0)),
				--- -(COALESCE(c.NetPay, 0)),
				-(COALESCE(c.NetPay, 0) - COALESCE(s.SumCurrentAmount, 0)),
				-(COALESCE(c.NetPay, 0) - COALESCE(s.SumCurrentAmount, 0)),  
			   @DateOnCheck, @PostYear, @GLPeriod, 0, @CurrBase, 1 
             FROM dbo.tblPaCheck c 
            INNER JOIN #PostTransList b ON c.Id = b.TransId
			Left Join  
			(
			SELECT v.CheckId, Sum(v.CurrentAmount) SumCurrentAmount FROM dbo.tblPaCheckDistribution v 
            INNER JOIN #PostTransList b ON v.CheckId = b.TransId  WHERE v.DirectDepositYn=1 group by v.CheckId 
			) s
           on c.Id = s.CheckId WHERE (COALESCE(c.NetPay, 0) - COALESCE(s.SumCurrentAmount, 0)) > 0 

       
       
		END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_Br_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_Br_proc';

