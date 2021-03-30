
CREATE PROCEDURE dbo.ALP_qryJmSvcTktAppendPmtHeader
@ID int
As
SET NOCOUNT ON
INSERT INTO tblArCashRcptHeader ( PmtAmt, BankID, CheckNum, CustId, PmtMethodId, CcHolder, CcNum, CcExpire, CcAuth, [Note], 
	CurrencyID, InvcTransID, DepositID, GLPeriod, FiscalYear, SumHistPeriod, InvcAppID, GLAcct, AgingPd )
SELECT ALP_tblJmSvcTktPmt.PmtAmt, ALP_tblJmSvcTktPmt.BankID, ALP_tblJmSvcTktPmt.CheckNum, ALP_tblJmSvcTkt.CustId, ALP_tblJmSvcTktPmt.PmtMethodId, 
	ALP_tblJmSvcTktPmt.CcHolder, ALP_tblJmSvcTktPmt.CcNum, ALP_tblJmSvcTktPmt.CcExpire, ALP_tblJmSvcTktPmt.CcAuth, ALP_tblJmSvcTktPmt.Note, 
	ALP_tblJmSvcTktPmt.CurrencyID, ALP_tblArTransHeader_view.TransId, ALP_tblArTransHeader_view.BatchId, ALP_tblArTransHeader_view.GLPeriod, 
	ALP_tblArTransHeader_view.FiscalYear, ALP_tblArTransHeader_view.SumHistPeriod, 'AR' AS Expr1, tblArPmtMethod.GLAcctDebit, Null AS Expr2
FROM (ALP_tblJmSvcTkt INNER JOIN ALP_tblArTransHeader_view ON ALP_tblJmSvcTkt.TicketId = ALP_tblArTransHeader_view.AlpJobNum) 
	INNER JOIN (ALP_tblJmSvcTktPmt INNER JOIN tblArPmtMethod ON ALP_tblJmSvcTktPmt.PmtMethodId = tblArPmtMethod.PmtMethodID) 
	ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktPmt.TicketId
WHERE ALP_tblJmSvcTkt.TicketId = @ID