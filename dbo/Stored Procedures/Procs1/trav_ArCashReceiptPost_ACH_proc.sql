
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_ACH_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'

	IF @PostRun IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	Insert into dbo.tblArPaymentACH (BankID, CustID, CustomerName
		, CustomerBankName, CustomerRoutingCode, CustomerAccountNumber, CustomerAcctType
		, PaymentAmount, PaymentDate, PostRun, TransID, TransactionType)
	Select h.BankID, h.CustId, c.CustName
		, h.BankName, h.BankRoutingCode, h.BankAcctNum, 0 --only supporting checking acct type
		, Sum(Case When h.CurrencyId = bk.CurrencyId Then d.PmtAmtFgn Else d.PmtAmt End) --use fgn amount when pmt is in bank currency otherwise use base
		, h.PmtDate, @PostRun, Right(Cast(h.RcptHeaderId as nvarchar), 8), 27 --27=demand debit
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	Inner Join dbo.tblArPmtMethod pmt on h.PmtMethodId = pmt.PmtMethodId
	Inner Join dbo.tblSmBankAcct bk on h.BankId = bk.BankId
	Left Join dbo.tblArCust c on h.CustId = c.CustId
	Where pmt.PmtType = 6 --direct debits only
	Group By h.BankId, h.CustId, c.CustName
		, h.BankName, h.BankRoutingCode, h.BankAcctNum
		, h.PmtDate, h.RcptHeaderId
	Having Sum(d.PmtAmtFgn) <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_ACH_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_ACH_proc';

