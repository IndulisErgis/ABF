
CREATE VIEW [dbo].[trav_ApPaymentHistory_view]
AS
	SELECT c.[Counter], v.VendorID, v.[Name], VendorHoldYN, VendorClass, v.DistCode, v.DivisionCode, 
		PriorityCode, v.[Status], v.CurrencyID, v.BankAcctNum, 
		c.GrossAmtDue, c.PostRun, c.InvoiceNum, c.InvoiceDate, c.CheckNum, c.CheckDate, 
		c.FiscalYear, c.GLPeriod, c.DiscDueDate, c.NetDueDate, b.BankId, b.[Desc]
	FROM   dbo.tblApVendor AS v INNER JOIN dbo.tblApCheckHist AS c ON v.VendorID = c.VendorId
			LEFT JOIN dbo.tblSmBankAcct b ON c.BankId = b.BankId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApPaymentHistory_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApPaymentHistory_view';

