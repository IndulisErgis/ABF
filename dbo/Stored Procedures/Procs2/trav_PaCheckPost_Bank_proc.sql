
CREATE PROCEDURE [dbo].[trav_PaCheckPost_Bank_proc]
AS
BEGIN TRY
--PET:http://webfront:801/view.php?id=226643
--PET:http://webfront:801/view.php?id=226466
--PET:http://webfront:801/view.php?id=227656

	DECLARE @BankID nvarchar(10)
	SELECT @BankID = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'BankID'
	

	IF @BankID IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

  

     UPDATE dbo.tblSmBankAcct SET GlAcctBal = GlAcctBal -
  
         (SElect sum(v.SumNetPay) SumNetPay
		from
		(SELECT (COALESCE(c.NetPay, 0)) SumNetPay
				FROM dbo.tblPaCheck c 
            INNER JOIN #PostTransList b ON c.Id = b.TransId) v)
	WHERE dbo.tblSmBankAcct.BankId = @BankId
	
			



     
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_Bank_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_Bank_proc';

