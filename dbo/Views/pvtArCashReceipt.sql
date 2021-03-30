
CREATE VIEW dbo.pvtArCashReceipt
AS
SELECT dbo.tblArCashRcptHeader.BankID, dbo.tblArCashRcptHeader.DepositID, dbo.tblArCashRcptHeader.CheckNum, dbo.tblArCust.CustName
	, dbo.tblArCashRcptDetail.InvcNum, dbo.tblArCashRcptDetail.PmtAmt, dbo.tblArCashRcptHeader.PmtDate, dbo.tblArPmtMethod.[Desc]
	, dbo.tblArCashRcptHeader.RcptHeaderID
FROM dbo.tblArCashRcptHeader 
INNER JOIN dbo.tblArCashRcptDetail ON dbo.tblArCashRcptHeader.RcptHeaderID = dbo.tblArCashRcptDetail.RcptHeaderID 
INNER JOIN dbo.tblArCust ON dbo.tblArCashRcptHeader.CustId = dbo.tblArCust.CustId 
INNER JOIN dbo.tblArPmtMethod ON dbo.tblArCashRcptHeader.PmtMethodId = dbo.tblArPmtMethod.PmtMethodID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArCashReceipt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArCashReceipt';

