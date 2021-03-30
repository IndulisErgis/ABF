
CREATE VIEW dbo.pvtArOpenInvoice
AS

--http://webfront:801/view.php?id=227310
SELECT dbo.tblArOpenInvoice.CustId, dbo.tblArCust.CustName, dbo.tblArOpenInvoice.RecType
	, dbo.tblArOpenInvoice.InvcNum, dbo.tblArOpenInvoice.TransDate
	, dbo.tblArOpenInvoice.Amt, dbo.tblArOpenInvoice.DiscDueDate
	, dbo.tblArCust.SalesRepId1
	, CASE dbo.tblArOpenInvoice.[Status] 
		WHEN 0 THEN 'Rel' WHEN 1 THEN 'Hold' WHEN 4 THEN 'Paid' ELSE '' END AS [Status]
	, dbo.tblArOpenInvoice.DiscAmt, dbo.tblArOpenInvoice.CheckNum
FROM dbo.tblArOpenInvoice 
INNER JOIN dbo.tblArCust ON dbo.tblArOpenInvoice.CustId = dbo.tblArCust.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArOpenInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArOpenInvoice';

