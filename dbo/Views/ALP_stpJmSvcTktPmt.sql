
CREATE VIEW dbo.ALP_stpJmSvcTktPmt AS 
SELECT TicketId, BankID, PmtAmt, CheckNum, PmtMethodId, CcHolder, CcNum, CcExpire, CcAuth, Note, CurrencyID FROM dbo.ALP_tblJmSvcTktPmt