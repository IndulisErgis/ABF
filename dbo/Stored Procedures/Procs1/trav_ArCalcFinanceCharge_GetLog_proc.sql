
CREATE PROCEDURE dbo.trav_ArCalcFinanceCharge_GetLog_proc
AS 

SET NOCOUNT ON
BEGIN TRY
		--PET:http://webfront:801/view.php?id=225002
		SELECT CustomerId, CustomerName, AccountType, UnpaidFinch, NonFinchAmt, FinchBase, CalcFinch, CurrencyId
		FROM #CalcFinchLog

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCalcFinanceCharge_GetLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCalcFinanceCharge_GetLog_proc';

