
CREATE PROCEDURE dbo.trav_ArPeriodicMaint_CustomerBalanceLog_proc
AS

SET NOCOUNT ON
BEGIN TRY

	SELECT c.CustId CustomerId, c.CurrencyId, isnull(oi.Amount, 0) InvoiceAmount
		, (c.UnpaidFinch + c.CurAmtDue + c.BalAge1 + c.BalAge2 + c.BalAge3 + c.BalAge4 - c.UnapplCredit) CustomerAmount
	FROM dbo.tblArCust c
	LEFT JOIN (
		SELECT CustId, Sum(CASE WHEN RecType < 0 THEN -AmtFgn ELSE AmtFgn END) Amount
		FROM dbo.tblArOpenInvoice  
		WHERE [Status] <> 4 AND RecType<>5
		GROUP BY CustId ) oi
	ON c.CustId = oi.CustId
	WHERE ISNULL(oi.Amount, 0) <> (c.UnpaidFinch + c.CurAmtDue + c.BalAge1 + c.BalAge2 + c.BalAge3 + c.BalAge4 - c.UnapplCredit)
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_CustomerBalanceLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPeriodicMaint_CustomerBalanceLog_proc';

