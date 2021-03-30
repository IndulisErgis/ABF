
Create view dbo.trav_BrJrnlHeaderBank_view 
As

SELECT h.TransID, h.BankID, h.TransType, h.SourceID, h.Descr, h.TransDate, h.GLPeriod, h.FiscalYear, 
	h.Reference, h.CurrencyId, h.VoidYn, h.VoidReinstateStat, h.Ten99Yr, h.CreateTransaction, 
	h.CreateManualCheck, h.PayrollMonth, b.[Desc], b.Name, b.OurAcctNum, b.GlCashAcct, b.AcctType
FROM dbo.tblBrJrnlHeader h INNER JOIN dbo.tblSmBankAcct b ON h.BankId = b.BankId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BrJrnlHeaderBank_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_BrJrnlHeaderBank_view';

