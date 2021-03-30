
CREATE VIEW dbo.pvtArPmtHist
AS
SELECT BankID, FiscalYear, GLPeriod, PmtMethodId, InvcNum, CustId, PmtDate, CheckNum, PmtAmt
FROM dbo.tblArHistPmt
WHERE VoidYn = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArPmtHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArPmtHist';

