
CREATE PROCEDURE dbo.trav_PsLayawayPost_ACH_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'

	IF @PostRun IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO dbo.tblArPaymentACH (BankID, CustID, CustomerName, CustomerBankName, CustomerRoutingCode, CustomerAccountNumber, CustomerAcctType, 
		PaymentAmount, PaymentDate, PostRun, TransID, TransactionType)
	SELECT m.BankID, p.CustID, c.CustName, p.BankName, p.BankRoutingCode, p.BankAcctNum, 0, --only supporting checking acct type
		p.AmountBase, --Standard: only supports base currency external transactions
		p.PmtDate, @PostRun, 'PS', 27 --27=demand debit
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		INNER JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId 
		LEFT JOIN dbo.tblArCust c ON p.CustID = c.CustId
	WHERE p.VoidDate IS NULL AND p.PmtType = 6 AND p.AmountBase <> 0--direct debits only

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_ACH_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_ACH_proc';

